#!/usr/bin/env python3
"""Search for and download open-access audio DSP & music-computing PDFs.

Organizes downloaded PDFs and metadata sidecars into the multi-corpus library:

    papers_library/
      originals/<Corpus>/<Corpus>-<year>/<paper-id>.pdf
      originals/<Corpus>/<Corpus>-<year>/<paper-id>.meta.json
      manifests/<corpus>_manifest.jsonl

Enforces a hard disk budget across `papers_library/originals/` (default: 95 GB,
well under the 100 GB cap).

Supported low-hanging-fruit sources:
  * smc      — Sound and Music Computing Conference (Zenodo `smc` community API)
  * nime     — New Interfaces for Musical Expression (official BibTeX archive + nime.org/Zenodo PDFs)
  * ismir    — International Society for Music Information Retrieval (official JSON archive + Zenodo PDFs)
  * waspaa   — IEEE Workshop on Applications of Signal Processing to Audio and Acoustics
               (OpenAlex OA harvesting + archived waspaa.com proceedings)
  * icassp   — IEEE ICASSP (OpenAlex OA harvesting filtered to audio/music/DSP mechanisms)
  * icmc     — International Computer Music Conference (OpenAlex OA + Zenodo harvesting)
  * aes      — Audio Engineering Society open-access papers (OpenAlex OA harvesting)
  * arxiv    — Targeted arXiv (`eess.AS`, `eess.SP`, `cs.SD`) search by DSP mechanism presets
               or custom queries (adaptive filters, WDF/Volterra, OFDM/channel, chirp/sonar,
               sparse/compressed sensing, quantization/coding, beamforming/spatial, phase/FM).

Usage:
    ./tools/fetch_papers.py --status
    ./tools/fetch_papers.py --source smc --limit 25
    ./tools/fetch_papers.py --source nime --year 2024 --limit 25
    ./tools/fetch_papers.py --source ismir --year 2023 --limit 25
    ./tools/fetch_papers.py --source waspaa --limit 25
    ./tools/fetch_papers.py --source icassp --query "nonlinear audio distortion" --limit 20
    ./tools/fetch_papers.py --source arxiv --preset all --limit 40
    ./tools/fetch_papers.py --source arxiv --query "wave digital filter nonlinear" --limit 15
    ./tools/fetch_papers.py --source all --limit 15
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LIBRARY = ROOT / "papers_library"
ORIGINALS = LIBRARY / "originals"
MANIFESTS = LIBRARY / "manifests"

DEFAULT_MAX_GB = 95.0
USER_AGENT = "sousa-fx-corpus/1.0 (https://github.com/sousa-fx; mailto:research@example.com)"
BROWSER_UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"

# Curated DSP mechanism queries from the Perplexity research notes for mining
# audio, speech, and telecom/radar/control papers in arXiv (eess.AS, eess.SP, cs.SD)
ARXIV_PRESETS: dict[str, str] = {
    "adaptive": '(cat:eess.AS OR cat:eess.SP OR cat:cs.SD) AND (abs:"adaptive filter" OR abs:"Kalman" OR abs:"RLS" OR abs:"system identification") AND (abs:audio OR abs:music OR abs:acoustic OR abs:nonlinear)',
    "virtual_analog": '(cat:eess.AS OR cat:eess.SP OR cat:cs.SD) AND (abs:"wave digital filter" OR abs:"Volterra" OR abs:"nonlinear state space" OR abs:"port-Hamiltonian" OR abs:"virtual analog" OR abs:"antiderivative antialiasing")',
    "modulation_spectral": '(cat:eess.AS OR cat:eess.SP OR cat:cs.SD) AND (abs:"phase distortion" OR abs:"frequency modulation" OR abs:"allpass" OR abs:"phase vocoder" OR abs:"Hilbert" OR abs:"spectral" OR abs:"formant") AND (abs:audio OR abs:synthesis OR abs:timbre)',
    "comms_channel": '(cat:eess.AS OR cat:eess.SP) AND (abs:"channel estimation" OR abs:"OFDM" OR abs:"equalization" OR abs:"companding") AND (abs:audio OR abs:acoustic OR abs:underwater OR abs:reverberation)',
    "radar_chirp": '(cat:eess.AS OR cat:eess.SP OR cat:cs.SD) AND (abs:"matched filter" OR abs:"pulse compression" OR abs:"chirp" OR abs:"dispersion" OR abs:"Doppler") AND (abs:audio OR abs:acoustic OR abs:sonar OR abs:synthesis)',
    "sparse_coding": '(cat:eess.AS OR cat:eess.SP OR cat:cs.SD) AND (abs:"sparse recovery" OR abs:"compressed sensing" OR abs:"dictionary learning" OR abs:"atomic decomposition") AND (abs:audio OR abs:music OR abs:speech)',
    "quantization_lofi": '(cat:eess.AS OR cat:eess.SP OR cat:cs.SD) AND (abs:"delta modulation" OR abs:"predictive coding" OR abs:"dither" OR abs:"noise shaping" OR abs:"quantization") AND (abs:audio OR abs:speech OR abs:music)',
    "spatial_array": '(cat:eess.AS OR cat:eess.SP OR cat:cs.SD) AND (abs:"beamforming" OR abs:"ambisonics" OR abs:"decorrelation" OR abs:"reverberation" OR abs:"feedback delay network") AND (abs:audio OR abs:music)',
}

# Strict DSP/effect phrase required for broad conferences (ICASSP, NIME, ISMIR)
STRICT_DSP_RE = re.compile(
    r"\b(audio effect|digital audio|sound synthesis|physical model|wave digital|"
    r"virtual analog|nonlinear filter|non-linear filter|distortion|overdrive|"
    r"waveshap|allpass|phaser|flanger|chorus|reverberation|feedback delay network|"
    r"phase vocoder|pitch shift|time stretch|formant|vocal tract|talkbox|vocoder|"
    r"dynamic range compress|limiter|transient|equalizer|biquad|state-space filter|"
    r"volterra|antialiasing|oversampling|frequency modulation|phase distortion|"
    r"granular synthesis|waveguide|modal synthesis|karplus-strong|hilbert transform|"
    r"frequency shifter|ring modulat|bitcrush|delta modulation|adaptive filter|"
    r"kalman filter|decorrelation|ambisonic|beamforming|tuba|brass instrument)\b",
    re.I,
)

OPENALEX_SOURCES = {
    "waspaa": ("WASPAA", "S7407087794"),
    "icassp": ("ICASSP", "S4363607879"),
    "icmc": ("ICMC", "S4306418977"),
    "aes": ("AES", "S62507282"),
}


def log(msg: str) -> None:
    print(msg, flush=True)


def slugify(text: str, max_len: int = 64) -> str:
    s = re.sub(r"[^A-Za-z0-9._-]+", "_", text.strip())
    s = re.sub(r"_+", "_", s).strip("._-")
    return (s[:max_len].rstrip("._-") or "paper")


def dir_size_bytes(path: Path) -> int:
    total = 0
    if not path.exists():
        return 0
    for root, _, files in os.walk(path, followlinks=False):
        for f in files:
            fp = Path(root) / f
            if not fp.is_symlink():
                try:
                    total += fp.stat().st_size
                except OSError:
                    pass
    return total


def check_budget(max_gb: float, incoming_bytes: int = 0) -> tuple[bool, float]:
    used = dir_size_bytes(ORIGINALS) + incoming_bytes
    used_gb = used / (1024 ** 3)
    return used_gb < max_gb, used_gb


def http_get_json(url: str, headers: dict[str, str] | None = None, timeout: int = 25) -> dict | list:
    hdrs = {"User-Agent": USER_AGENT, "Accept": "application/json, text/plain, */*"}
    if headers:
        hdrs.update(headers)
    for attempt in range(3):
        try:
            req = urllib.request.Request(url, headers=hdrs)
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                return json.loads(resp.read().decode("utf-8", errors="replace"))
        except urllib.error.HTTPError as exc:
            if exc.code == 429 and attempt < 2:
                time.sleep(2.5 * (attempt + 1))
                continue
            raise
        except Exception:
            if attempt < 2:
                time.sleep(1.5 * (attempt + 1))
                continue
            raise
    return {}


def http_get_text(url: str, timeout: int = 25) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": BROWSER_UA, "Accept": "*/*"})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.read().decode("utf-8", errors="replace")


def download_pdf(url: str, dest_pdf: Path, timeout: int = 25) -> tuple[bool, str]:
    """Download a PDF to dest_pdf, verifying the %PDF- magic header."""
    dest_pdf.parent.mkdir(parents=True, exist_ok=True)
    tmp_pdf = dest_pdf.with_suffix(".pdf.part")

    # Ensure URL path is properly percent-encoded (Zenodo keys may contain spaces)
    parts = urllib.parse.urlsplit(url)
    safe_path = urllib.parse.quote(urllib.parse.unquote(parts.path), safe="/:@+$,;=-_.~")
    safe_url = urllib.parse.urlunsplit((parts.scheme, parts.netloc, safe_path, parts.query, parts.fragment))

    # Try urllib with polite research User-Agent first (required by Zenodo)
    try:
        req = urllib.request.Request(safe_url, headers={
            "User-Agent": USER_AGENT,
            "Accept": "application/pdf,application/octet-stream;q=0.9,*/*;q=0.8",
        })
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            data = resp.read()
        if data[:16].find(b"%PDF-") != -1:
            tmp_pdf.write_bytes(data)
            tmp_pdf.rename(dest_pdf)
            return True, f"{len(data) / 1024:.0f} KB"
        if b"<html" in data[:512].lower() or b"<!doctype" in data[:512].lower():
            return False, "not a PDF file (HTML landing page)"
    except Exception:
        pass

    # Fallback to curl with browser UA for servers picky about TLS/UA (e.g. waspaa.com)
    try:
        proc = subprocess.run(
            ["curl", "-sSL", "--connect-timeout", "8", "--max-time", str(timeout), "-A", BROWSER_UA, "-o", str(tmp_pdf), safe_url],
            capture_output=True, text=True, timeout=timeout + 3,
        )
        if proc.returncode == 0 and tmp_pdf.exists():
            with tmp_pdf.open("rb") as fh:
                head = fh.read(1024)
            if b"%PDF-" in head[:16]:
                size = tmp_pdf.stat().st_size
                tmp_pdf.rename(dest_pdf)
                return True, f"{size / 1024:.0f} KB"
    except Exception:
        pass

    tmp_pdf.unlink(missing_ok=True)
    return False, "not a PDF file or download blocked"


def reconstruct_abstract(inv_idx: dict | None) -> str | None:
    if not inv_idx or not isinstance(inv_idx, dict):
        return None
    words: list[tuple[int, str]] = []
    for word, positions in inv_idx.items():
        if isinstance(positions, list):
            for pos in positions:
                if isinstance(pos, int):
                    words.append((pos, word))
    if not words:
        return None
    words.sort(key=lambda x: x[0])
    return " ".join(w for _, w in words)


def is_already_downloaded(corpus: str, year: int, pid: str) -> bool:
    year_dir = f"{corpus}-{year}" if year else f"{corpus}-unknown"
    dest_pdf = ORIGINALS / corpus / year_dir / f"{pid}.pdf"
    return dest_pdf.exists() and dest_pdf.stat().st_size > 1024


def save_candidate(cand: dict, max_gb: float, dry_run: bool = False) -> str:
    """Save candidate PDF + .meta.json sidecar + manifest line. Returns 'downloaded'|'cached'|'skipped'|'failed'."""
    ok_budget, used_gb = check_budget(max_gb)
    if not ok_budget:
        log(f"  [STOP] Disk budget reached ({used_gb:.2f} GB >= {max_gb:.2f} GB)")
        return "budget_exceeded"

    corpus = cand["corpus"]
    year = int(cand.get("year") or 0)
    year_dir = f"{corpus}-{year}" if year else f"{corpus}-unknown"
    pid = cand["id"]
    dest_dir = ORIGINALS / corpus / year_dir
    dest_pdf = dest_dir / f"{pid}.pdf"
    dest_meta = dest_dir / f"{pid}.meta.json"

    if dest_pdf.exists() and dest_pdf.stat().st_size > 1024:
        if not dest_meta.exists() and not dry_run:
            dest_meta.write_text(json.dumps(cand, indent=2, ensure_ascii=False), encoding="utf-8")
        return "cached"

    if dry_run:
        log(f"  [DRY-RUN] {corpus}/{year_dir}/{pid}.pdf <- {cand['pdf_url']}")
        log(f"            Title: {cand.get('title', '')[:85]}")
        return "skipped"

    ok, msg = download_pdf(cand["pdf_url"], dest_pdf)
    if not ok:
        log(f"  [SKIP] {pid}: {msg} ({cand['pdf_url']})")
        return "failed"

    cand["downloaded_at"] = time.strftime("%Y-%m-%d %H:%M:%S")
    cand["file_size_bytes"] = dest_pdf.stat().st_size
    dest_meta.write_text(json.dumps(cand, indent=2, ensure_ascii=False), encoding="utf-8")

    MANIFESTS.mkdir(parents=True, exist_ok=True)
    manifest_file = MANIFESTS / f"{corpus.lower()}_manifest.jsonl"
    with manifest_file.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(cand, ensure_ascii=False) + "\n")

    log(f"  [OK] {corpus}/{year_dir}/{pid}.pdf ({msg}) — {cand.get('title', '')[:72]}")
    return "downloaded"


# --------------------------------------------------------------------------- #
# Source 1: SMC (Sound and Music Computing via Zenodo community API)
# --------------------------------------------------------------------------- #
def discover_smc(year: int | None, query: str | None, limit: int, filter_fx: bool) -> list[dict]:
    log("==> Querying Zenodo community 'smc' (Sound and Music Computing)...")
    candidates: list[dict] = []
    page = 1
    page_size = 25  # Zenodo unauthenticated API caps size at 25
    while len(candidates) < limit and page <= 40:
        params = {"communities": "smc", "size": str(page_size), "page": str(page), "sort": "mostrecent"}
        if query:
            params["q"] = query
        url = "https://zenodo.org/api/records?" + urllib.parse.urlencode(params)
        try:
            data = http_get_json(url)
        except Exception as exc:
            log(f"  Zenodo SMC warning on page {page}: {exc}")
            break
        hits = (data.get("hits") or {}).get("hits") or []
        if not hits:
            break
        for h in hits:
            meta = h.get("metadata") or {}
            title = re.sub(r"\s+", " ", meta.get("title") or "").strip()
            # Skip monolithic full-proceedings books (>15 MB or titled "Proceedings of the...")
            if re.match(r"^Proceedings of the \d+", title, re.I):
                continue
            pub_date = meta.get("publication_date") or ""
            ym = re.match(r"(\d{4})", pub_date)
            yr = int(ym.group(1)) if ym else 0
            if year and yr != year:
                continue
            desc = re.sub(r"<[^>]+>", " ", meta.get("description") or "")
            desc = re.sub(r"\s+", " ", desc).strip()
            if filter_fx and not STRICT_DSP_RE.search(f"{title} {desc}"):
                continue
            files = h.get("files") or []
            pdf_file = next((f for f in files if (f.get("key") or "").lower().endswith(".pdf")), None)
            if not pdf_file:
                continue
            # Skip huge multi-paper volumes (>20 MB)
            if (pdf_file.get("size") or 0) > 20 * 1024 * 1024:
                continue
            pdf_url = (pdf_file.get("links") or {}).get("self")
            if not pdf_url:
                continue
            rec_id = h.get("id")
            authors = [c.get("name") for c in (meta.get("creators") or []) if c.get("name")]
            first_author = slugify((authors[0].split(",")[0] if authors else "author"), 20)
            pid = f"{yr}_SMC_{rec_id}_{first_author}"
            if is_already_downloaded("SMC", yr, pid):
                continue
            candidates.append({
                "id": pid,
                "corpus": "SMC",
                "venue": f"SMC {yr}" if yr else "SMC",
                "year": yr,
                "title": title,
                "authors": authors,
                "abstract": desc[:3000] if desc else None,
                "doi": meta.get("doi") or h.get("doi"),
                "pdf_url": pdf_url,
                "source_url": h.get("links", {}).get("html"),
            })
            if len(candidates) >= limit:
                break
        page += 1
        time.sleep(0.4)
    return candidates


# --------------------------------------------------------------------------- #
# Source 2: NIME (New Interfaces for Musical Expression official BibTeX archive)
# --------------------------------------------------------------------------- #
BIB_ENTRY_RE = re.compile(r"@inproceedings\s*\{\s*([^,\s]+)\s*,(.+?)\n\}", re.S | re.I)
BIB_FIELD_RE = re.compile(r"(\w+)\s*=\s*\{((?:[^{}]|\{[^{}]*\})*)\}", re.S)


def discover_nime(year: int | None, query: str | None, limit: int, filter_fx: bool) -> list[dict]:
    log("==> Querying NIME official proceedings archive (NIME-bibliography)...")
    try:
        items = http_get_json("https://api.github.com/repos/NIME-conference/NIME-bibliography/contents/paper_proceedings")
    except Exception as exc:
        log(f"  NIME github listing failed: {exc}")
        return []
    bib_files = [x for x in items if isinstance(x, dict) and (x.get("name") or "").endswith(".bib")]
    bib_files.sort(key=lambda x: x["name"], reverse=True)

    if year:
        bib_files = [x for x in bib_files if str(year) in x["name"]]

    candidates: list[dict] = []
    q_re = re.compile(re.escape(query), re.I) if query else None

    for bf in bib_files:
        if len(candidates) >= limit:
            break
        try:
            raw_bib = http_get_text(bf["download_url"])
        except Exception as exc:
            log(f"  NIME bib fetch error ({bf['name']}): {exc}")
            continue
        for m in BIB_ENTRY_RE.finditer(raw_bib):
            cite_key, body = m.group(1).strip(), m.group(2)
            fields = {k.lower(): re.sub(r"\s+", " ", v).strip() for k, v in BIB_FIELD_RE.findall(body)}
            pdf_url = fields.get("url") or ""
            if not pdf_url.lower().endswith(".pdf"):
                continue
            title = fields.get("title", "").strip("{}")
            abstract = fields.get("abstract", "")
            yr = int(fields.get("year", "0") or 0)
            blob = f"{title} {abstract} {fields.get('keywords', '')}"
            if q_re and not q_re.search(blob):
                continue
            if filter_fx and not STRICT_DSP_RE.search(blob):
                continue
            authors = [a.strip() for a in re.split(r"\s+and\s+", fields.get("author", "")) if a.strip()]
            pid = f"{yr}_{slugify(cite_key, 48)}" if not cite_key.startswith(str(yr)) else slugify(cite_key, 56)
            if is_already_downloaded("NIME", yr, pid):
                continue
            candidates.append({
                "id": pid,
                "corpus": "NIME",
                "venue": f"NIME {yr}" if yr else "NIME",
                "year": yr,
                "title": title,
                "authors": authors,
                "abstract": abstract[:3000] if abstract else None,
                "doi": fields.get("doi"),
                "pdf_url": pdf_url,
                "source_url": f"https://doi.org/{fields['doi']}" if fields.get("doi") else pdf_url,
            })
            if len(candidates) >= limit:
                break
    return candidates


# --------------------------------------------------------------------------- #
# Source 3: ISMIR (International Society for Music Information Retrieval)
# --------------------------------------------------------------------------- #
def discover_ismir(year: int | None, query: str | None, limit: int, filter_fx: bool) -> list[dict]:
    log("==> Querying ISMIR official conference-archive database...")
    years = [year] if year else list(range(2024, 1999, -1))
    candidates: list[dict] = []
    q_re = re.compile(re.escape(query), re.I) if query else None

    for yr in years:
        if len(candidates) >= limit:
            break
        url = f"https://raw.githubusercontent.com/ismir/conference-archive/master/database/proceedings/{yr}.json"
        try:
            papers = http_get_json(url)
        except Exception:
            continue
        if not isinstance(papers, list):
            continue
        for idx, p in enumerate(papers, 1):
            title = re.sub(r"\s+", " ", p.get("title") or "").strip()
            abstract = re.sub(r"\s+", " ", p.get("abstract") or "").strip()
            blob = f"{title} {abstract}"
            if q_re and not q_re.search(blob):
                continue
            if filter_fx and not STRICT_DSP_RE.search(blob):
                continue
            pdf_url = p.get("ee") or ""
            if not pdf_url:
                continue
            authors = p.get("author") or []
            first_author = slugify((authors[0].split()[-1] if authors else f"p{idx}"), 20)
            zid = p.get("zenodo_id") or idx
            pid = f"{yr}_ISMIR_{zid}_{first_author}"
            if is_already_downloaded("ISMIR", int(yr), pid):
                continue
            candidates.append({
                "id": pid,
                "corpus": "ISMIR",
                "venue": f"ISMIR {yr}",
                "year": int(yr),
                "title": title,
                "authors": authors,
                "abstract": abstract[:3000] if abstract else None,
                "doi": p.get("doi"),
                "pdf_url": pdf_url,
                "source_url": p.get("url") or pdf_url,
            })
            if len(candidates) >= limit:
                break
    return candidates


# --------------------------------------------------------------------------- #
# Source 4: OpenAlex Open-Access Harvester (WASPAA, ICASSP, ICMC, AES) + WASPAA archive
# --------------------------------------------------------------------------- #
def discover_waspaa_direct(year: int | None, limit: int) -> list[dict]:
    """Check direct proceedings PDFs hosted on waspaa.com (e.g. WASPAA 2025)."""
    if year and year != 2025:
        return []
    candidates: list[dict] = []
    try:
        proc = subprocess.run(
            ["curl", "-sL", "-A", BROWSER_UA, "https://waspaa.com/waspaa25/technical-program-schedule/"],
            capture_output=True, text=True, timeout=20,
        )
        html = proc.stdout
        for m in re.finditer(r'href=["\'](https?://[^"\']+/WASPAA2025-(\d+)\.pdf)["\'][^>]*>([^<]*)<', html, re.I):
            pdf_url, num, label = m.group(1), m.group(2), re.sub(r"\s+", " ", m.group(3)).strip()
            pid = f"2025_WASPAA_{num}"
            if is_already_downloaded("WASPAA", 2025, pid):
                continue
            candidates.append({
                "id": pid,
                "corpus": "WASPAA",
                "venue": "WASPAA 2025",
                "year": 2025,
                "title": label if len(label) > 12 else f"WASPAA 2025 Paper {num}",
                "authors": [],
                "abstract": None,
                "doi": None,
                "pdf_url": pdf_url,
                "source_url": "https://waspaa.com/waspaa25/technical-program-schedule/",
            })
            if len(candidates) >= limit:
                break
    except Exception:
        pass
    return candidates


def discover_openalex(source_key: str, year: int | None, query: str | None, limit: int, filter_fx: bool) -> list[dict]:
    corpus, source_id = OPENALEX_SOURCES[source_key]
    log(f"==> Querying OpenAlex Open-Access works for {corpus} ({source_id})...")
    candidates: list[dict] = []
    if source_key == "waspaa":
        candidates.extend(discover_waspaa_direct(year, limit))

    page = 1
    per_page = min(100, max(25, limit * 2))
    while len(candidates) < limit and page <= 10:
        filters = [f"primary_location.source.id:{source_id}", "is_oa:true"]
        if year:
            filters.append(f"publication_year:{year}")
        if query:
            q_clean = re.sub(r"[,:]", " ", query).strip()
            filters.append(f"title_and_abstract.search:{q_clean}")
        elif source_key == "icassp":
            # ICASSP has 58,000+ papers across image/comms/ML; default to audio/music/DSP filter
            filters.append("title_and_abstract.search:audio distortion OR reverberation OR sound synthesis OR wave digital filter OR phase vocoder OR virtual analog")

        params = {
            "filter": ",".join(filters),
            "per-page": str(per_page),
            "page": str(page),
            "sort": "publication_year:desc",
        }
        url = "https://api.openalex.org/works?" + urllib.parse.urlencode(params)
        try:
            data = http_get_json(url)
        except Exception as exc:
            log(f"  OpenAlex warning ({corpus} p.{page}): {exc}")
            break
        results = data.get("results") or []
        if not results:
            break

        for w in results:
            title = re.sub(r"\s+", " ", w.get("title") or "").strip()
            if not title or re.search(r"\b(program at a glance|cover page|table of contents|author index|front matter)\b", title, re.I):
                continue
            yr = int(w.get("publication_year") or 0)
            abstract = reconstruct_abstract(w.get("abstract_inverted_index"))
            if filter_fx and source_key in ("icassp", "aes") and not STRICT_DSP_RE.search(f"{title} {abstract or ''}"):
                continue

            # Find best direct OA PDF URL (prefer arxiv, zenodo, hal, institutional repos over ieeexplore)
            pdf_url = None
            locs = [w.get("best_oa_location") or {}] + (w.get("locations") or [])
            for loc in locs:
                u = loc.get("pdf_url") or ""
                if u and "ieeexplore.ieee.org" not in u and "aes.org/e-lib/download" not in u:
                    pdf_url = u
                    break
            if not pdf_url:
                oa_u = (w.get("open_access") or {}).get("oa_url") or ""
                if oa_u and "ieeexplore.ieee.org" not in oa_u and "aes.org/e-lib/download" not in oa_u:
                    if "arxiv.org/abs/" in oa_u:
                        oa_u = oa_u.replace("arxiv.org/abs/", "arxiv.org/pdf/")
                    pdf_url = oa_u
            if not pdf_url:
                continue

            authors = [
                (a.get("author") or {}).get("display_name")
                for a in (w.get("authorships") or [])
                if (a.get("author") or {}).get("display_name")
            ]
            oa_id = (w.get("id") or "").rsplit("/", 1)[-1]
            first_author = slugify((authors[0].split()[-1] if authors else "paper"), 18)
            pid = f"{yr}_{corpus}_{first_author}_{oa_id}"
            if is_already_downloaded(corpus, yr, pid):
                continue
            candidates.append({
                "id": pid,
                "corpus": corpus,
                "venue": f"{corpus} {yr}" if yr else corpus,
                "year": yr,
                "title": title,
                "authors": authors,
                "abstract": abstract[:3000] if abstract else None,
                "doi": w.get("doi"),
                "pdf_url": pdf_url,
                "source_url": w.get("id"),
            })
            if len(candidates) >= limit:
                break
        page += 1
        time.sleep(0.3)

    # For ICMC, also check Zenodo records mentioning International Computer Music Conference
    if source_key == "icmc" and len(candidates) < limit:
        try:
            z_url = "https://zenodo.org/api/records?" + urllib.parse.urlencode({
                "q": '"International Computer Music Conference"',
                "size": str(min(25, limit - len(candidates))),
            })
            z_data = http_get_json(z_url)
            for h in (z_data.get("hits") or {}).get("hits") or []:
                meta = h.get("metadata") or {}
                title = re.sub(r"\s+", " ", meta.get("title") or "").strip()
                pub_date = meta.get("publication_date") or ""
                ym = re.match(r"(\d{4})", pub_date)
                yr = int(ym.group(1)) if ym else 0
                if year and yr != year:
                    continue
                files = h.get("files") or []
                pdf_file = next((f for f in files if (f.get("key") or "").lower().endswith(".pdf")), None)
                if not pdf_file or (pdf_file.get("size") or 0) > 25 * 1024 * 1024:
                    continue
                pdf_url = (pdf_file.get("links") or {}).get("self")
                if not pdf_url:
                    continue
                authors = [c.get("name") for c in (meta.get("creators") or []) if c.get("name")]
                first_author = slugify((authors[0].split(",")[0] if authors else "author"), 18)
                pid = f"{yr}_ICMC_{h.get('id')}_{first_author}"
                if is_already_downloaded("ICMC", yr, pid):
                    continue
                candidates.append({
                    "id": pid,
                    "corpus": "ICMC",
                    "venue": f"ICMC {yr}" if yr else "ICMC",
                    "year": yr,
                    "title": title,
                    "authors": authors,
                    "abstract": re.sub(r"<[^>]+>", " ", meta.get("description") or "")[:3000] or None,
                    "doi": meta.get("doi"),
                    "pdf_url": pdf_url,
                    "source_url": h.get("links", {}).get("html"),
                })
                if len(candidates) >= limit:
                    break
        except Exception:
            pass

    return candidates


# --------------------------------------------------------------------------- #
# Source 5: arXiv API (eess.AS, eess.SP, cs.SD) with DSP mechanism presets
# --------------------------------------------------------------------------- #
ATOM_NS = {"atom": "http://www.w3.org/2005/Atom"}


def discover_arxiv(year: int | None, query: str | None, preset: str, limit: int) -> list[dict]:
    queries: list[tuple[str, str]] = []
    if query:
        q_str = f"(cat:eess.AS OR cat:eess.SP OR cat:cs.SD) AND ({query})"
        queries.append(("custom", q_str))
    elif preset == "all":
        queries.extend(list(ARXIV_PRESETS.items()))
    else:
        queries.append((preset, ARXIV_PRESETS[preset]))

    candidates: list[dict] = []
    seen_ids: set[str] = set()
    per_query_limit = max(5, (limit + len(queries) - 1) // len(queries))

    for tag, q_str in queries:
        if len(candidates) >= limit:
            break
        log(f"==> Querying arXiv [{tag}]: {q_str[:90]}...")
        params = {
            "search_query": q_str,
            "start": "0",
            "max_results": str(min(100, per_query_limit * 2)),
            "sortBy": "submittedDate",
            "sortOrder": "descending",
        }
        url = "http://export.arxiv.org/api/query?" + urllib.parse.urlencode(params)
        try:
            xml_text = http_get_text(url, timeout=30)
            root = ET.fromstring(xml_text)
        except Exception as exc:
            log(f"  arXiv query error ({tag}): {exc}")
            continue

        count_for_tag = 0
        for entry in root.findall("atom:entry", ATOM_NS):
            id_url = (entry.findtext("atom:id", "", ATOM_NS) or "").strip()
            if not id_url:
                continue
            arxiv_id = id_url.rsplit("/abs/", 1)[-1].split("v")[0]
            if arxiv_id in seen_ids:
                continue
            published = (entry.findtext("atom:published", "", ATOM_NS) or "").strip()
            yr = int(published[:4]) if len(published) >= 4 and published[:4].isdigit() else 0
            if year and yr != year:
                continue
            title = re.sub(r"\s+", " ", entry.findtext("atom:title", "", ATOM_NS) or "").strip()
            summary = re.sub(r"\s+", " ", entry.findtext("atom:summary", "", ATOM_NS) or "").strip()
            authors = [
                (a.findtext("atom:name", "", ATOM_NS) or "").strip()
                for a in entry.findall("atom:author", ATOM_NS)
            ]
            authors = [a for a in authors if a]
            first_author = slugify((authors[0].split()[-1] if authors else "arxiv"), 18)
            clean_aid = arxiv_id.replace("/", "_")
            pid = f"{yr}_arXiv_{clean_aid}_{first_author}"
            seen_ids.add(arxiv_id)
            if is_already_downloaded("arXiv", yr, pid):
                continue
            candidates.append({
                "id": pid,
                "corpus": "arXiv",
                "venue": f"arXiv {yr} ({tag})",
                "year": yr,
                "title": title,
                "authors": authors,
                "abstract": summary[:3000] if summary else None,
                "arxiv_id": arxiv_id,
                "doi": None,
                "pdf_url": f"https://arxiv.org/pdf/{arxiv_id}.pdf",
                "source_url": f"https://arxiv.org/abs/{arxiv_id}",
            })
            count_for_tag += 1
            if count_for_tag >= per_query_limit or len(candidates) >= limit:
                break
        time.sleep(1.0)
    return candidates


# --------------------------------------------------------------------------- #
# Status & CLI
# --------------------------------------------------------------------------- #
def print_status(max_gb: float) -> int:
    ORIGINALS.mkdir(parents=True, exist_ok=True)
    total_bytes = dir_size_bytes(ORIGINALS)
    total_gb = total_bytes / (1024 ** 3)
    log(f"==> Library root: {LIBRARY}")
    log(f"==> Originals disk usage: {total_gb:.2f} GB / {max_gb:.1f} GB cap ({100 * total_gb / max_gb:.1f}%)")
    log("")
    log(f"{'Corpus':10s}  {'PDFs':>7s}  {'Size (MB)':>10s}  {'Year Subdirs':>12s}")
    log("-" * 46)
    for cdir in sorted(p for p in ORIGINALS.iterdir() if p.is_dir() and not p.is_symlink()):
        pdfs = list(cdir.rglob("*.pdf"))
        sz_mb = sum(p.stat().st_size for p in pdfs if not p.is_symlink()) / (1024 ** 2)
        ydirs = [d for d in cdir.iterdir() if d.is_dir() and not d.is_symlink()]
        log(f"{cdir.name:10s}  {len(pdfs):7d}  {sz_mb:10.1f}  {len(ydirs):12d}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--source", choices=["smc", "nime", "ismir", "waspaa", "icassp", "icmc", "aes", "arxiv", "all"],
                    default="all", help="which corpus source to search & download (default: all)")
    ap.add_argument("--preset", choices=[*ARXIV_PRESETS.keys(), "all"], default="all",
                    help="for --source arxiv: DSP mechanism query preset (default: all)")
    ap.add_argument("--query", "-q", default=None, help="optional search query filter")
    ap.add_argument("--year", type=int, default=None, help="restrict to a specific publication year")
    ap.add_argument("--limit", type=int, default=20, help="max papers to fetch per source (default: 20)")
    ap.add_argument("--no-fx-filter", action="store_true",
                    help="disable audio-effect/DSP keyword filtering on broad venues (NIME/ISMIR/ICASSP)")
    ap.add_argument("--max-gb", type=float, default=DEFAULT_MAX_GB,
                    help=f"hard cap on papers_library/originals size in GB (default: {DEFAULT_MAX_GB})")
    ap.add_argument("--dry-run", action="store_true", help="list candidate papers without downloading PDFs")
    ap.add_argument("--status", action="store_true", help="show current library PDF counts and disk usage")
    args = ap.parse_args()

    if args.status:
        return print_status(args.max_gb)

    filter_fx = not args.no_fx_filter
    sources = (
        ["smc", "nime", "ismir", "waspaa", "aes", "icmc", "icassp", "arxiv"]
        if args.source == "all"
        else [args.source]
    )

    stats = {"downloaded": 0, "cached": 0, "failed": 0, "skipped": 0}
    for src in sources:
        ok_budget, used_gb = check_budget(args.max_gb)
        if not ok_gb_check(ok_budget, used_gb, args.max_gb):
            break

        if src == "smc":
            cands = discover_smc(args.year, args.query, args.limit, filter_fx=False if not args.query else filter_fx)
        elif src == "nime":
            cands = discover_nime(args.year, args.query, args.limit, filter_fx=filter_fx)
        elif src == "ismir":
            cands = discover_ismir(args.year, args.query, args.limit, filter_fx=filter_fx)
        elif src in OPENALEX_SOURCES:
            cands = discover_openalex(src, args.year, args.query, args.limit, filter_fx=filter_fx)
        elif src == "arxiv":
            cands = discover_arxiv(args.year, args.query, args.preset, args.limit)
        else:
            cands = []

        log(f"==> {src.upper()}: {len(cands)} candidate paper(s) found")
        for cand in cands:
            res = save_candidate(cand, args.max_gb, dry_run=args.dry_run)
            if res == "budget_exceeded":
                break
            stats[res] = stats.get(res, 0) + 1
            if res == "downloaded":
                time.sleep(0.25)

    log("")
    log(f"==> Fetch summary: {stats['downloaded']} downloaded, {stats['cached']} cached, "
        f"{stats['failed']} failed/skipped")
    print_status(args.max_gb)
    return 0


def ok_gb_check(ok: bool, used_gb: float, max_gb: float) -> bool:
    if not ok:
        log(f"==> Stopping: originals directory is at {used_gb:.2f} GB (cap {max_gb:.2f} GB)")
    return ok


if __name__ == "__main__":
    sys.exit(main())
