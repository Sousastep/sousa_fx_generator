#!/usr/bin/env python3
"""Convert the audio DSP & music-computing library PDFs into a searchable corpus.

For every PDF in papers_library/originals/<Corpus>/<Corpus>-<year>/ this writes:

    papers_library/papers/<Corpus>/<Corpus>-<year>/<paper-id>/
        paper.md        full text as Markdown: YAML front matter, real headings,
                        <!-- page: N --> anchors, in-text images, extracted tables
        metadata.json   id/title/authors/year/venue/corpus/pages/sections/keywords/paths
        structure.json  raw opendataloader-pdf output (bboxes, fonts, table cells)
        figures/        images pulled out of the PDF (PNG)
        tables/         one CSV (+ Markdown twin) per detected table
        source.pdf      symlink back to the untouched file in originals/

and then builds the retrieval layer over all converted papers in the library:

    papers_library/index/INDEX.jsonl      one compact record per paper
    papers_library/index/INDEX.md         same records, human/agent readable
    papers_library/index/search.sqlite    SQLite FTS5 index over pages + tables
    papers_library/index/build_report.json

(`DAFx-proceedings` is symlinked to `papers_library`, and `papers/DAFx-<year>`
symlinks to `papers/DAFx/DAFx-<year>`, preserving backwards compatibility.)

Usage:
    ./tools/build_corpus.py                       # convert everything (parallel)
    ./tools/build_corpus.py --corpus WASPAA       # one corpus
    ./tools/build_corpus.py --year 2026           # one year (across or within corpus)
    ./tools/build_corpus.py --limit 10            # smoke test
    ./tools/build_corpus.py --force               # redo papers already converted
    ./tools/build_corpus.py --skip-convert        # only rebuild the index
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import shutil
import sqlite3
import struct
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LIBRARY = ROOT / "papers_library" if (ROOT / "papers_library").exists() else ROOT / "DAFx-proceedings"
ORIGINALS = LIBRARY / "originals"
PAPERS = LIBRARY / "papers"
INDEX = LIBRARY / "index"
CLI = ROOT / ".venv" / "bin" / "opendataloader-pdf"
PAGE_SEP = "<!-- page: %page-number% -->"
PAGE_RE = re.compile(r"^<!-- page: (\d+) -->\s*$", re.M)
JAVA_HOME_CANDIDATE = "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
MIN_FIGURE_PX = 48      # scanned pages yield hundreds of sub-icon strip fragments
MIN_FIGURE_AREA = 12000
MIN_FIGURE_BYTES = 1024

STOPWORDS = {
    "the", "a", "an", "and", "or", "of", "to", "in", "for", "on", "with", "is",
    "are", "was", "were", "be", "been", "this", "that", "these", "those", "it",
    "its", "as", "at", "by", "from", "we", "our", "can", "which", "such", "than",
    "then", "also", "not", "but", "has", "have", "had", "using", "used", "use",
    "into", "over", "between", "two", "one", "more", "most", "may", "shown",
    "paper", "present", "presented", "results", "result", "however", "both",
    "all", "any", "each", "they", "their", "there", "here", "when", "where",
    "how", "what", "some", "other", "only", "very", "well", "way", "based",
}


def log(msg: str) -> None:
    print(msg, flush=True)


def ensure_venv() -> None:
    """Re-exec under ./.venv so the optional PyMuPDF fallback is importable."""
    venv_py = ROOT / ".venv" / "bin" / "python"
    if not venv_py.exists() or os.environ.get("DAFX_VENV_REEXEC") == "1":
        return
    try:
        if Path(sys.executable).resolve() == venv_py.resolve():
            return
    except OSError:
        pass
    os.environ["DAFX_VENV_REEXEC"] = "1"
    os.execv(str(venv_py), [str(venv_py), str(Path(__file__).resolve()), *sys.argv[1:]])


# --------------------------------------------------------------------------- #
# environment
# --------------------------------------------------------------------------- #
def java_env() -> dict:
    """Return an env with a usable java on PATH (opendataloader-pdf needs Java 11+)."""
    env = dict(os.environ)
    # Bound the heap: the JVM defaults to a quarter of physical RAM per process,
    # which would overcommit with several parallel conversions on a 16 GB machine.
    env.setdefault("JAVA_TOOL_OPTIONS", "-Xmx2g")
    candidates = [
        env.get("JAVA_HOME", ""),
        JAVA_HOME_CANDIDATE,
        "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home",
        "/usr/local/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home",
    ]
    for home in candidates:
        if home and Path(home, "bin", "java").exists():
            env["JAVA_HOME"] = home
            env["PATH"] = f"{home}/bin:" + env.get("PATH", "")
            return env
    return env


# --------------------------------------------------------------------------- #
# discovery
# --------------------------------------------------------------------------- #
def paper_id(filename: str) -> str:
    """1998_ARF36.PS.pdf -> 1998_ARF36 ; 2026_DAFx26_challenge_76.pdf -> 2026_DAFx26_challenge_76"""
    stem = re.sub(r"\.pdf$", "", filename, flags=re.I)
    stem = re.sub(r"\.ps$", "", stem, flags=re.I)          # PostScript source suffix
    return stem.strip("._-") or stem


def discover(originals: Path, corpora: set[str] | None, years: set[str] | None) -> list[dict]:
    recs = []
    corpus_dirs = sorted(
        p for p in originals.iterdir()
        if p.is_dir() and not p.is_symlink()
    )
    for c_dir in corpus_dirs:
        corpus = c_dir.name
        if corpora and corpus.lower() not in corpora:
            continue
        for year_dir in sorted(p for p in c_dir.iterdir() if p.is_dir() and not p.is_symlink()):
            m = re.search(r"(\d{4})", year_dir.name)
            year = int(m.group(1)) if m else 0
            if years and year_dir.name.lower() not in years and str(year) not in years:
                continue
            pdfs = sorted((p for p in year_dir.iterdir() if p.suffix.lower() == ".pdf"),
                          key=lambda p: p.name.lower())
            for pdf in pdfs:
                pid = paper_id(pdf.name)
                sidecar_path = year_dir / f"{pid}.meta.json"
                sidecar = {}
                if sidecar_path.exists():
                    try:
                        sidecar = json.loads(sidecar_path.read_text(encoding="utf-8"))
                    except Exception:
                        sidecar = {}
                recs.append({
                    "pid": pid,
                    "corpus": corpus,
                    "year": year or int(sidecar.get("year") or 0),
                    "year_dir": year_dir.name,
                    "pdf": pdf,
                    "filename": pdf.name,
                    "sidecar": sidecar,
                })
    return recs


# --------------------------------------------------------------------------- #
# conversion
# --------------------------------------------------------------------------- #
def run_cli(pdf: Path, outdir: Path, env: dict, timeout: int) -> tuple[bool, str]:
    outdir.mkdir(parents=True, exist_ok=True)
    cmd = [
        str(CLI), str(pdf),
        "-o", str(outdir),
        "-f", "markdown,json",
        "--quiet",
        "--markdown-page-separator", PAGE_SEP,
        "--image-output", "external",
        "--image-dir", str(outdir / "figures"),
    ]
    try:
        proc = subprocess.run(cmd, env=env, capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return False, f"timeout after {timeout}s"
    if proc.returncode != 0:
        tail = (proc.stderr or proc.stdout or "").strip().splitlines()
        return False, " | ".join(tail[-3:])[:400] if tail else f"exit {proc.returncode}"
    return True, ""


def pdf_metadata(pdf: Path) -> dict:
    """Title/author/date from the PDF's own document information, via PyMuPDF."""
    try:
        import pymupdf
        with pymupdf.open(pdf) as doc:
            info = doc.metadata or {}
            return {"title": info.get("title"), "author": info.get("author"),
                    "creation date": info.get("creationDate")}
    except Exception:  # noqa: BLE001
        return {}


def repair_pdf(pdf: Path, workdir: Path) -> Path | None:
    """Re-save through PyMuPDF when the Java parser rejects a structurally odd PDF.

    All of DAFx-2022 and DAFx-2025 are rejected as "not a valid PDF file" by the
    Java side while being perfectly readable elsewhere; rewriting the file makes
    them parse normally (and keeps figures/tables/bboxes, unlike the text-only
    fallback).
    """
    try:
        import pymupdf
    except ImportError:
        return None
    out = workdir / "repaired.pdf"
    try:
        doc = pymupdf.open(pdf)
        if doc.needs_pass:
            doc.close()
            return None
        doc.save(str(out), garbage=4, deflate=True, clean=True)
        doc.close()
    except Exception:  # noqa: BLE001 - any repair failure just falls through
        return None
    return out if out.exists() and out.stat().st_size > 0 else None


def pymupdf_pages_text(pdf: Path) -> list[str] | None:
    """Per-page text via PyMuPDF, or None if it is unavailable/cannot open the file."""
    try:
        import pymupdf
    except ImportError:
        return None
    try:
        with pymupdf.open(pdf) as doc:
            return [page.get_text("text") for page in doc]
    except Exception:  # noqa: BLE001 - depends on the broken file
        return None


def pages_to_md(pages: list[str]) -> str:
    return "\n".join(f"<!-- page: {i} -->\n\n{t.strip()}\n" for i, t in enumerate(pages, 1))


FUNCTION_WORDS = {
    "the", "and", "of", "to", "in", "a", "is", "for", "with", "that", "this", "on",
    "are", "as", "be", "by", "we", "it", "from", "an", "at", "or", "can", "which",
    "not", "has", "have", "was", "were", "been", "its", "their", "than", "then",
}


def text_looks_like_prose(text: str) -> bool:
    """Reject mojibake: PDFs with broken font encodings decode to letters but no words.

    A few DAFx PDFs use subset fonts with a broken ToUnicode map, so extractors
    return text like "(PEHGGHG" instead of "Embedded". Such text has letters but
    almost no function words, which prose always has in abundance.
    """
    if len(text) < 500:
        return False
    words = re.findall(r"[A-Za-z]{2,}", text.lower())
    if len(words) < 120:
        return False
    return sum(1 for w in words if w in FUNCTION_WORDS) / len(words) > 0.10


def tesseract_env() -> dict:
    env = dict(os.environ)
    if "TESSDATA_PREFIX" not in env:
        for cand in ("/opt/homebrew/share/tessdata", "/usr/local/share/tessdata",
                     "/usr/share/tessdata"):
            if Path(cand, "eng.traineddata").exists():
                env["TESSDATA_PREFIX"] = cand
                break
    return env


def ocr_pdf_pages(pdf: Path, dpi: int = 300) -> list[str] | None:
    """Render each page and OCR it with Tesseract (last resort for unreadable PDFs).

    Needed for pages with no text layer and for PDFs whose subset fonts have a
    broken ToUnicode map - rendering sidesteps the encoding entirely.
    """
    if not shutil.which("tesseract"):
        return None
    try:
        import pymupdf
    except ImportError:
        return None
    env = tesseract_env()
    work = Path(tempfile.mkdtemp(prefix="dafx-ocr-"))

    def recognise(png: Path, extra: tuple[str, ...]) -> str | None:
        try:
            proc = subprocess.run(["tesseract", str(png), "stdout", *extra],
                                  env=env, capture_output=True, text=True, timeout=180)
        except (OSError, subprocess.TimeoutExpired):
            return None
        return proc.stdout if proc.returncode == 0 else None

    try:
        pngs = []
        with pymupdf.open(pdf) as doc:
            for i, page in enumerate(doc, 1):
                png = work / f"page{i}.png"
                page.get_pixmap(dpi=dpi).save(png)
                pngs.append(png)
        # Plain segmentation first; if the text is not prose (some pages are
        # imposed rotated, e.g. 2000_laurson), retry with orientation detection.
        last: list[str] | None = None
        for extra in ((), ("--psm", "1")):
            pages = []
            for png in pngs:
                text = recognise(png, extra)
                if text is None:
                    return last
                pages.append(text)
            last = pages
            if text_looks_like_prose("\n".join(pages)):
                return pages
        return last
    except Exception:  # noqa: BLE001 - OCR failure just means "still unreadable"
        return None
    finally:
        shutil.rmtree(work, ignore_errors=True)


def fallback_extract(pdf: Path, outdir: Path) -> tuple[bool, str]:
    """Last-resort text extraction for PDFs the Java parser rejects (PyMuPDF)."""
    pages = pymupdf_pages_text(pdf)
    if pages is None:
        return False, "opendataloader-pdf failed and PyMuPDF could not open the file"
    try:
        (outdir / "fallback.md").write_text(pages_to_md(pages), encoding="utf-8")
    except OSError as exc:
        return False, f"PyMuPDF fallback could not write output: {exc}"
    return True, "extracted with PyMuPDF fallback"


# --------------------------------------------------------------------------- #
# markdown / metadata helpers
# --------------------------------------------------------------------------- #
def yaml_str(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def split_pages(md: str) -> list[tuple[int, str]]:
    """Split on the page separator into [(page_number, text), ...].

    PAGE_RE has one capture group, so re.split returns
    [preamble, num, body, num, body, ...] - the pairs are (1,2), (3,4), ...
    """
    parts = PAGE_RE.split(md)
    if len(parts) < 3:                       # no separators found
        return [(1, md)]
    pages = []
    for i in range(1, len(parts) - 1, 2):
        try:
            num = int(parts[i])
        except (TypeError, ValueError):
            continue
        pages.append((num, parts[i + 1].strip()))
    return pages or [(1, md)]


def heading_list(structure: dict) -> list[dict]:
    out = []
    for el in structure.get("kids", []):
        if el.get("type") == "heading" and el.get("content"):
            text = re.sub(r"\s+", " ", el["content"]).strip()
            if text:
                out.append({
                    "level": el.get("heading level") or el.get("level"),
                    "title": text,
                    "page": el.get("page number"),
                })
    return out


JUNK_TITLE_RE = re.compile(
    r"^(microsoft word\b|untitled|document\d*$|print$|slides?$|paper$|final$|draft\b|"
    r"thesis\b|article\b|manuscript\b|layout\b|msword\b|"
    r"d_[a-z0-9]+\b|"
    r".*\.(doc|docx|pdf|tex|dvi|ps|eps|rtf|txt|ppt|pptx|xls|xlsx|qxd|indd|pages|odt|"
    r"md|html?|bak|log)\s*$)", re.I)

# Document metadata frequently carries a section heading (or the numbering of
# one) instead of the title: "INTRODUCTION", "2. ALGORITHM OF ...".
SECTION_TITLE_RE = re.compile(
    r"^\s*(?:\d+\.\s+.*|"
    r"\d+(?:\.\d+)+\.?\s+.*|"
    r"(?:introduction|abstract|summary|contents|references|bibliography|appendix|preface|"
    r"acknowledg\w*|conclusion\w*|discussion|results|methods|experiments|background|"
    r"motivation)\s*(?:[.:]\s*.*)?)$", re.I)
NON_TEXT_TITLE_RE = re.compile(r"^[\W_\d\s]+$")


def plausible_title(text: str | None, pid: str) -> bool:
    """PDF metadata titles are frequently the authoring file name, not the real title."""
    if not text:
        return False
    t = re.sub(r"\s+", " ", text).strip()
    if len(t) < 12 or len(t) > 400:
        return False
    if JUNK_TITLE_RE.match(t) or SECTION_TITLE_RE.match(t) or NON_TEXT_TITLE_RE.match(t):
        return False
    if " " not in t and "." in t:      # a bare file name, not a title
        return False
    if "_" in t:                       # file-name-ish; paper titles do not use underscores
        return False
    if "@" in t:                       # an email address, e.g. an author contact line
        return False
    if re.match(r"^(figure|table|equation|eq\.?|listing|algorithm)\s*\d+", t, re.I):
        return False
    printable = sum(1 for c in t if 32 <= ord(c) < 127)
    if printable / len(t) < 0.75:       # private-use glyphs from a broken font map
        return False
    if norm_for_match(t) == norm_for_match(pid) or norm_for_match(pid) in norm_for_match(t):
        return False
    letters = sum(c.isalpha() for c in t)
    return letters >= 10 and letters / len(t) > 0.6


def title_from_font(structure: dict, pid: str) -> str | None:
    """Fall back to the largest text on page 1, which is usually the title.

    Needed when the document metadata carries a section heading and the parser
    did not mark the title as a heading at all (common in DAFx 2020/2021).
    """
    best_size, best_text = 0.0, None
    for el in structure.get("kids", []):
        if el.get("page number") != 1 or el.get("type") not in ("heading", "paragraph"):
            continue
        size = el.get("font size") or 0
        text = re.sub(r"\s+", " ", el.get("content") or "").strip()
        if size <= best_size or not plausible_title(text, pid):
            continue
        best_size, best_text = size, text
    return best_text


def pick_title(structure: dict, pages: list[tuple[int, str]], pid: str) -> str:
    meta_title = re.sub(r"\s+", " ", structure.get("title") or "").strip()
    if plausible_title(meta_title, pid):
        return meta_title
    for h in heading_list(structure):
        if str(h["level"]).lower() in ("doctitle", "1", "title") and plausible_title(h["title"], pid):
            return h["title"]
    by_font = title_from_font(structure, pid)
    if by_font:
        return by_font
    for h in heading_list(structure):
        if plausible_title(h["title"], pid):
            return h["title"]
    # Last resort: page 1 sometimes yields one blob of "title + authors +
    # affiliation". Take the first clause of the first usable line that still
    # looks like a title; otherwise keep the line as-is (never worse than before).
    for _, body in pages:
        for line in body.splitlines():
            line = line.strip()
            if not line or line.startswith(("<!--", "!", "#", "|", ">")):
                continue
            if len(line) <= 12 or line[0].isdigit():
                continue
            for candidate in (line, line.split("@")[0], line.split(",")[0],
                              line.split(" and ")[0], line.split(". ")[0],
                              line.split(" - ")[0]):
                candidate = candidate.strip(" .,;:-–")
                if len(candidate) >= 20 and plausible_title(candidate, pid):
                    return candidate
            return line
    return pid


NAME_RE = re.compile(r"^[A-ZÀ-Þ][\w'’.\-]+(?:\s+[A-ZÀ-Þ][\w'’.\-]+){0,4}$")


def looks_like_name(line: str) -> bool:
    line = line.strip()
    if not line or len(line) > 60 or any(c in line for c in "@:;,|/(),"):
        return False
    if any(tok in line.lower() for tok in
           ("abstract", "copyright", "university", "institute", "dept", "department",
            "conference", "proceedings", "http", "www", "laboratory", "centre", "center",
            "lab", "labs", "school", "foundation", "group", "research", "academy",
            "college", "faculty", "division", "studio", "inc", "ltd", "gmbh")):
        return False
    words = line.split()
    if not 1 < len(words) <= 6:
        return False
    caps = sum(1 for w in words if w[:1].isupper())
    return caps >= max(1, len(words) - 1) and NAME_RE.match(line) is not None


def pick_authors(structure: dict, pages: list[tuple[int, str]]) -> tuple[str | None, list[str], str | None]:
    """Return (authors_string, authors_list, raw_block)."""
    if structure.get("author"):
        raw = re.sub(r"\s+", " ", structure["author"]).strip()
        return raw, [raw], None

    if not pages:
        return None, [], None
    _, body = pages[0]
    body = PAGE_RE.sub("", body)

    # the author block is whatever sits between the title and the abstract
    lines = [l.strip() for l in body.splitlines()]
    abstract_at = next((i for i, l in enumerate(lines)
                        if re.match(r"^_{0,2}#{0,4}\s*_*\s*\**\s*abstract\b", l, re.I)), None)
    region = lines[1:abstract_at] if abstract_at else lines[1:14]

    plausible = [l for l in region if l and not l.startswith(("#", "!", "|", ">", "*", "["))
                 and not re.match(r"^\d+(\.\d+)*\.?\s", l)]
    names: list[str] = []
    for line in plausible:
        for chunk in re.split(r"\s{2,}|\s*[;,]\s*(?=[A-ZÀ-Þ])|\band\b", line):
            if looks_like_name(chunk):
                names.append(chunk.strip(" ,;*"))

    deduped, seen = [], set()
    for n in names:
        key = n.lower()
        if key not in seen:
            seen.add(key)
            deduped.append(n)

    raw = " ".join(x for x in plausible[:4] if x)[:600] or None
    joined = ", ".join(deduped) if deduped else (re.sub(r"\s+", " ", " ".join(plausible[:2]))[:300] or None)
    return joined, deduped, raw


def pick_abstract(md: str) -> str | None:
    m = re.search(r"^#{1,6}\s*\**\s*(abstract|summary)\s*\**\s*$", md, re.I | re.M)
    if not m:
        return None
    rest = md[m.end():]
    nxt = re.search(r"^#{1,6}\s+\S", rest, re.M)
    body = rest[:nxt.start()] if nxt else rest[:4000]
    body = re.sub(r"^\s*<!-- page: \d+ -->\s*$", "", body, flags=re.M)
    body = re.sub(r"\s+", " ", body).strip()
    return body[:3000] or None


def keywords_from(text: str, limit: int = 20) -> list[str]:
    words = re.findall(r"[A-Za-z][A-Za-z\-]{2,}", (text or "").lower())
    freq: dict[str, int] = {}
    for w in words:
        if w in STOPWORDS or len(w) < 4:
            continue
        freq[w] = freq.get(w, 0) + 1
    ranked = sorted(freq.items(), key=lambda kv: (-kv[1], kv[0]))
    return [w for w, _ in ranked[:limit]]


def expand_table(el: dict) -> tuple[list[list[str]], list[str]]:
    """Expand a structure.json table element into a rectangular grid of strings."""
    rows = el.get("rows", []) or []
    ncols = max([c.get("column number", 1) + c.get("column span", 1) - 1
                 for r in rows for c in r.get("cells", [])] or [1])
    nrows = max([r.get("row number", i + 1) for i, r in enumerate(rows)] or [1])
    grid = [["" for _ in range(ncols)] for _ in range(nrows)]
    headers: list[str] = []

    def cell_text(cell: dict) -> str:
        chunks = []
        for kid in cell.get("kids", []) or []:
            if kid.get("content"):
                chunks.append(kid["content"])
            for sub in kid.get("kids", []) or []:
                if sub.get("content"):
                    chunks.append(sub["content"])
        if not chunks and cell.get("content"):
            chunks.append(cell["content"])
        return re.sub(r"\s+", " ", " ".join(chunks)).strip()

    for r in rows:
        rnum = r.get("row number", 1) - 1
        for cell in r.get("cells", []):
            cnum = cell.get("column number", 1) - 1
            text = cell_text(cell)
            for dr in range(cell.get("row span", 1) or 1):
                for dc in range(cell.get("column span", 1) or 1):
                    rr, cc = rnum + dr, cnum + dc
                    if 0 <= rr < nrows and 0 <= cc < ncols and not grid[rr][cc]:
                        grid[rr][cc] = text
            if cell.get("is_header") and rnum == 0 and text:
                headers.append(text)
    return grid, headers


def table_is_useful(grid: list[list[str]]) -> bool:
    cells = [c for row in grid for c in row if c.strip()]
    if len(cells) < 4:
        return False
    return len("\n".join(cells)) >= 40


def md_table(grid: list[list[str]]) -> str:
    ncols = max(len(r) for r in grid)
    rows = [[c.replace("|", "\\|").replace("\n", " ") for c in r] + [""] * (ncols - len(r))
            for r in grid]
    out = ["| " + " | ".join(rows[0]) + " |",
           "|" + "---|" * ncols]
    out += ["| " + " | ".join(r) + " |" for r in rows[1:]]
    return "\n".join(out)


def norm_for_match(s: str) -> str:
    return re.sub(r"[^a-z0-9]+", "", s.lower())


TABLE_BLOCK_RE = re.compile(r"(?:^\|[^\n]*\|[ \t]*\n?)+", re.M)
SEP_CELL_RE = re.compile(r"^:?-{2,}:?$")


def strip_empty_tables(md: str) -> tuple[str, int]:
    """Remove pipe tables with no text in any cell.

    Diagrams and screenshots are often detected as tables; the result is a block
    of empty cells that carries no information and only adds noise for a reader.
    """
    removed = 0

    def cells_of(row: str) -> list[str]:
        return [c.strip() for c in row.strip("|").split("|")]

    def is_separator(row: str) -> bool:
        cells = cells_of(row)
        dashes = [c for c in cells if SEP_CELL_RE.match(c)]
        return bool(dashes) and all(c == "" or SEP_CELL_RE.match(c) for c in cells)

    def repl(match: re.Match) -> str:
        nonlocal removed
        block = match.group(0)
        rows = [l.strip() for l in block.splitlines() if l.strip()]
        if len(rows) < 2 or not any(is_separator(r) for r in rows):
            return block                       # not a pipe table, leave it alone
        for row in rows:
            if is_separator(row):
                continue
            if any(cells_of(row)):
                return block                   # some cell has text: keep
        removed += 1
        return ""

    cleaned = TABLE_BLOCK_RE.sub(repl, md)
    return re.sub(r"\n{3,}", "\n\n", cleaned), removed


def png_dims(path: Path) -> tuple[int, int] | None:
    try:
        with path.open("rb") as fh:
            head = fh.read(24)
    except OSError:
        return None
    if len(head) >= 24 and head[:8] == b"\x89PNG\r\n\x1a\n" and head[12:16] == b"IHDR":
        return struct.unpack(">II", head[16:24])
    return None


def prune_figures(figdir: Path) -> list[str]:
    """Drop sub-icon image XObjects that some PDFs are full of (blank strips, noise)."""
    removed: list[str] = []
    if not figdir.is_dir():
        return removed
    for p in sorted(figdir.iterdir()):
        if not p.is_file():
            continue
        dims = png_dims(p)
        size = p.stat().st_size
        if dims is not None:
            tiny = (min(dims) < MIN_FIGURE_PX or dims[0] * dims[1] < MIN_FIGURE_AREA
                    or size < MIN_FIGURE_BYTES)
        else:
            tiny = size < MIN_FIGURE_BYTES
        if tiny:
            p.unlink()
            removed.append(p.name)
    return removed


def strip_dead_image_refs(md: str, removed: list[str]) -> str:
    """Remove Markdown image links whose file we just deleted."""
    for name in removed:
        md = re.sub(r"!\[[^\]]*\]\(<*[^)]*" + re.escape(name) + r">*\)\s*", "", md)
    return md


# --------------------------------------------------------------------------- #
# per-paper build
# --------------------------------------------------------------------------- #
def build_paper(rec: dict, env: dict, force: bool, timeout: int) -> dict:
    pid, year = rec["pid"], rec["year"]
    corpus = rec.get("corpus", "DAFx")
    sidecar = rec.get("sidecar") or {}
    dest = PAPERS / corpus / rec["year_dir"] / pid
    md_path = dest / "paper.md"
    meta_path = dest / "metadata.json"

    if md_path.exists() and meta_path.exists() and not force:
        try:
            meta = json.loads(meta_path.read_text(encoding="utf-8"))
            meta["_cached"] = True
            return meta
        except json.JSONDecodeError:
            pass

    if dest.exists() and (force or md_path.exists() != meta_path.exists()):
        # force, or a previous run was interrupted between the markdown and the
        # metadata: start from a clean directory so nothing stale survives.
        shutil.rmtree(dest, ignore_errors=True)
    dest.mkdir(parents=True, exist_ok=True)

    ok, err = run_cli(rec["pdf"], dest, env, timeout)
    extractor = "opendataloader-pdf"
    if not ok:
        # second chance: hand the Java CLI a rewritten copy of the same PDF
        work = Path(tempfile.mkdtemp(prefix="dafx-repair-"))
        repaired = repair_pdf(rec["pdf"], work)
        if repaired is not None:
            ok2, err2 = run_cli(repaired, dest, env, timeout)
            if ok2:
                extractor = "opendataloader-pdf (repaired copy)"
                err = f"original rejected ({err[:120]}); parsed a PyMuPDF-rewritten copy"
            else:
                err = f"{err} ;; repaired copy also failed: {err2}"
        shutil.rmtree(work, ignore_errors=True)
    if not ok and extractor == "opendataloader-pdf":
        fb_ok, fb_msg = fallback_extract(rec["pdf"], dest)
        if not fb_ok:
            return {**rec_base(rec), "status": "failed", "error": f"{err} ;; {fb_msg}"}
        extractor, err = "pymupdf-fallback", f"{err} ;; {fb_msg}"

    md_candidates = [p for p in dest.glob("*.md") if p.name != "paper.md"]
    json_candidates = [p for p in dest.glob("*.json") if p.name != "metadata.json"]
    if not md_candidates:
        return {**rec_base(rec), "status": "failed", "error": f"no markdown produced ({err})"}

    md = md_candidates[0].read_text(encoding="utf-8", errors="replace")
    md_candidates[0].unlink()

    structure: dict = {}
    if json_candidates:
        try:
            structure = json.loads(json_candidates[0].read_text(encoding="utf-8", errors="replace"))
        except json.JSONDecodeError:
            structure = {}
        json_candidates[0].rename(dest / "structure.json")
    if not structure.get("title"):
        # the Markdown-only fallback has no structure; the PDF's own document
        # info is still worth having for the title/author fields
        for key, value in pdf_metadata(rec["pdf"]).items():
            structure.setdefault(key, value)

    removed_figs = prune_figures(dest / "figures")
    if removed_figs:
        md = strip_dead_image_refs(md, removed_figs)
    md, empty_tables = strip_empty_tables(md)

    ocr_applied = False
    if len(re.findall(r"\S+", md)) < 200:
        # Nearly no text: either another reader can still see it, or the page has
        # to be rendered and OCR'd. Both paths must produce prose, so broken-font
        # PDFs never get filled with mojibake.
        alt = pymupdf_pages_text(rec["pdf"])
        if alt and text_looks_like_prose("\n".join(alt)):
            md = pages_to_md(alt)
            extractor = f"{extractor} + pymupdf text"
            note = (f"parser produced <200 words; used PyMuPDF text instead "
                    f"({len(' '.join(alt))} chars)")
            err = f"{err} ;; {note}" if err else note
        else:
            ocr = ocr_pdf_pages(rec["pdf"])
            if ocr and text_looks_like_prose("\n".join(ocr)):
                md = pages_to_md(ocr)
                extractor = f"{extractor} + tesseract ocr"
                ocr_applied = True
                note = (f"no usable text layer; OCR'd {len(ocr)} page(s) with Tesseract "
                        f"at 300 dpi")
                err = f"{err} ;; {note}" if err else note

    pages = split_pages(md)
    body = PAGE_RE.sub("", md)
    title = sidecar.get("title") or pick_title(structure, pages, pid)
    authors, author_list, authors_raw = pick_authors(structure, pages)
    if sidecar.get("authors"):
        author_list = sidecar["authors"]
        authors = ", ".join(author_list)
    abstract = pick_abstract(md) or sidecar.get("abstract")
    venue = sidecar.get("venue") or f"{corpus} {year}"
    sections = heading_list(structure) or [
        {"level": len(m.group(1)), "title": m.group(2).strip(), "page": None}
        for m in re.finditer(r"^(#{1,6})\s+(.+)$", md, re.M)
    ]
    anchored = len(PAGE_RE.findall(md))
    page_count = max(structure.get("number of pages") or 0, anchored or len(pages))

    # ---- tables ---------------------------------------------------------- #
    tables_dir = dest / "tables"
    tables_meta: list[dict] = []
    appendix: list[str] = []
    md_norm = norm_for_match(md)
    for i, el in enumerate([k for k in structure.get("kids", []) if k.get("type") == "table"], 1):
        grid, _ = expand_table(el)
        if not table_is_useful(grid):
            continue
        tables_dir.mkdir(exist_ok=True)
        name = f"table{i}"
        with (tables_dir / f"{name}.csv").open("w", newline="", encoding="utf-8") as fh:
            csv.writer(fh).writerows(grid)
        rendered = md_table(grid)
        (tables_dir / f"{name}.md").write_text(
            f"<!-- extracted from structure.json: page {el.get('page number')} -->\n\n{rendered}\n",
            encoding="utf-8")
        page_no = el.get("page number")
        tables_meta.append({
            "id": name,
            "page": page_no,
            "rows": len(grid),
            "columns": max(len(r) for r in grid),
            "csv": f"tables/{name}.csv",
            "markdown": f"tables/{name}.md",
        })
        # only inline tables the Markdown export did not already contain
        if norm_for_match(rendered)[:120] not in md_norm:
            appendix.append(
                f"<!-- generated by build_corpus.py: table `{name}` extracted from page {page_no} -->\n\n"
                f"**Table (page {page_no})**\n\n{rendered}\n")

    if appendix:
        md = md.rstrip() + "\n\n---\n\n## Extracted tables\n\n" + "\n".join(appendix) + "\n"

    # ---- figures --------------------------------------------------------- #
    figures = sorted(p.name for p in (dest / "figures").glob("*") if p.is_file()) \
        if (dest / "figures").is_dir() else []

    # ---- front matter + paper.md ----------------------------------------- #
    kw = keywords_from((abstract or "") + " " + title)
    front = [
        "---",
        f"id: {yaml_str(pid)}",
        f"title: {yaml_str(title)}",
        f"authors: {json.dumps(author_list or ([authors] if authors else []), ensure_ascii=False)}",
        f"year: {year}",
        f"corpus: {yaml_str(corpus)}",
        f"venue: {yaml_str(venue)}",
        f"pages: {page_count}",
        f"paper_file: {yaml_str(rec['filename'])}",
        f"source_pdf: {yaml_str(os.path.relpath(rec['pdf'], dest))}",
        f"extractor: {yaml_str(extractor)}",
        f"keywords: {json.dumps(kw[:12], ensure_ascii=False)}",
        "---",
        "",
    ]
    md_path.write_text("\n".join(front) + md.lstrip("\n"), encoding="utf-8")

    if not (dest / "source.pdf").exists():
        try:
            os.symlink(os.path.relpath(rec['pdf'], dest), dest / "source.pdf")
        except OSError:
            pass

    words = len(re.findall(r"\S+", body))
    meta = {
        "id": pid,
        "corpus": corpus,
        "title": title,
        "authors": author_list,
        "author_string": authors,
        "authors_raw": authors_raw,
        "year": year,
        "year_dir": rec["year_dir"],
        "venue": venue,
        "doi": sidecar.get("doi"),
        "arxiv_id": sidecar.get("arxiv_id"),
        "paper_file": rec["filename"],
        "page_count": page_count,
        "language": "en",
        "abstract": abstract,
        "keywords": kw,
        "sections": sections,
        "figures": figures,
        "figure_count": len(figures),
        "figures_dropped_tiny": len(removed_figs),
        "empty_tables_dropped": empty_tables,
        "tables": tables_meta,
        "word_count": words,
        "source_pdf": os.path.relpath(rec["pdf"], dest),
        "full_text": "paper.md",
        "structure_json": "structure.json" if (dest / "structure.json").exists() else None,
        "extractor": extractor,
        "extraction_warning": err or None,
        "ocr_applied": ocr_applied,
        # still unreadable and not recovered by OCR -> worth a human/OCR look
        "needs_ocr_review": (words < max(200, 40 * max(page_count, 1)) // 4) and not ocr_applied,
        "status": "ok",
    }
    meta_path.write_text(json.dumps(meta, indent=2, ensure_ascii=False), encoding="utf-8")
    return meta


def rec_base(rec: dict) -> dict:
    return {"id": rec["pid"], "corpus": rec.get("corpus", "DAFx"), "year": rec["year"],
            "year_dir": rec.get("year_dir"), "paper_file": rec["filename"],
            "title": None, "authors": [], "abstract": None}


# --------------------------------------------------------------------------- #
# index layer
# --------------------------------------------------------------------------- #
def infer_corpus_and_ydir(m: dict) -> tuple[str, str]:
    corpus = m.get("corpus")
    if not corpus:
        v = (m.get("venue") or "DAFx").split()[0]
        corpus = v if v else "DAFx"
    ydir = m.get("year_dir") or f"{corpus}-{m.get('year', 0)}"
    return corpus, ydir


def all_saved_metas() -> list[dict]:
    """Load metadata.json for every converted paper across all corpora in PAPERS."""
    out: list[dict] = []
    for c_dir in sorted(p for p in PAPERS.iterdir() if p.is_dir() and not p.is_symlink()):
        for mf in sorted(c_dir.glob("*/*/metadata.json")):
            try:
                m = json.loads(mf.read_text(encoding="utf-8"))
                m.setdefault("corpus", c_dir.name)
                m.setdefault("year_dir", mf.parent.parent.name)
                out.append(m)
            except Exception:
                pass
    return out


def write_indexes(metas: list[dict]) -> dict:
    INDEX.mkdir(parents=True, exist_ok=True)
    ok = sorted([m for m in metas if m.get("status") == "ok"],
                key=lambda m: (m.get("corpus", "DAFx"), m["year"], m["id"]))
    bad = [m for m in metas if m.get("status") != "ok"]

    records = []
    for m in ok:
        corpus, ydir = infer_corpus_and_ydir(m)
        rel_prefix = f"papers/{corpus}/{ydir}/{m['id']}" if corpus != "DAFx" else f"papers/DAFx-{m['year']}/{m['id']}"
        records.append({
            "id": m["id"],
            "corpus": corpus,
            "title": m["title"],
            "authors": m["authors"] or ([m["author_string"]] if m.get("author_string") else []),
            "year": m["year"],
            "venue": m["venue"],
            "pages": m["page_count"],
            "keywords": m.get("keywords", [])[:12],
            "sections": [s["title"] for s in m.get("sections", [])][:40],
            "figures": m.get("figure_count", 0),
            "tables": len(m.get("tables", [])),
            "abstract": m.get("abstract"),
            "path": f"{rel_prefix}/paper.md",
            "metadata": f"{rel_prefix}/metadata.json",
            "source_pdf": m["source_pdf"],
        })

    with (INDEX / "INDEX.jsonl").open("w", encoding="utf-8") as fh:
        for r in records:
            fh.write(json.dumps(r, ensure_ascii=False) + "\n")

    lines = [f"# Audio DSP & Music Computing Library Index ({len(records)} papers)", "",
             "Compact record per paper. Full text: `papers/<Corpus>/<Corpus>-<year>/<id>/paper.md`.",
             "Machine-readable: `INDEX.jsonl`. Search: `tools/search.py \"terms\"`.", ""]
    for r in records:
        authors = ", ".join(r["authors"][:4]) if r["authors"] else "?"
        lines.append(f"## [{r['corpus']}] {r['id']} — {r['title']}")
        lines.append(f"- **Year/Venue**: {r['year']} ({r['venue']})")
        lines.append(f"- **Authors**: {authors}")
        lines.append(f"- **Pages**: {r['pages']} · **Figures**: {r['figures']} · **Tables**: {r['tables']}")
        if r["keywords"]:
            lines.append(f"- **Keywords**: {', '.join(r['keywords'][:10])}")
        if r["sections"]:
            lines.append(f"- **Sections**: {'; '.join(r['sections'][:14])}")
        if r["abstract"]:
            lines.append(f"- **Abstract**: {r['abstract'][:600]}")
        lines.append(f"- **Text**: `{r['path']}` · **PDF**: `{r['source_pdf']}`")
        lines.append("")
    (INDEX / "INDEX.md").write_text("\n".join(lines), encoding="utf-8")

    build_fts(records, ok)
    return {"papers_indexed": len(records), "failures": bad}


def build_fts(records: list[dict], metas: list[dict]) -> None:
    db_path = INDEX / "search.sqlite"
    if db_path.exists():
        db_path.unlink()
    con = sqlite3.connect(db_path)
    con.executescript(
        """
        PRAGMA journal_mode=OFF;
        CREATE TABLE papers(
            id TEXT PRIMARY KEY, corpus TEXT, title TEXT, authors TEXT, year INT,
            venue TEXT, pages INT, keywords TEXT, abstract TEXT,
            path TEXT, source_pdf TEXT, tables INT, figures INT);
        CREATE VIRTUAL TABLE chunks USING fts5(
            id UNINDEXED, corpus UNINDEXED, year UNINDEXED, kind UNINDEXED, page UNINDEXED,
            section, text, tokenize='porter unicode61');
        """
    )
    con.executemany(
        "INSERT INTO papers VALUES(:id,:corpus,:title,:authors,:year,:venue,:pages,:keywords,"
        ":abstract,:path,:source_pdf,:tables_v,:figures_v)",
        [{**r, "authors": ", ".join(r["authors"]), "keywords": ", ".join(r["keywords"]),
          "tables_v": r["tables"], "figures_v": r["figures"]} for r in records],
    )

    rows = []
    for m in metas:
        corpus, ydir = infer_corpus_and_ydir(m)
        paper_dir = PAPERS / corpus / ydir / m["id"]
        md_file = paper_dir / "paper.md"
        if not md_file.exists():
            continue
        md = md_file.read_text(encoding="utf-8", errors="replace")
        body = re.sub(r"\A---\n.*?\n---\n", "", md, flags=re.S)
        current = None
        for page, text in split_pages(body):
            for block in re.split(r"\n(?=#{1,6}\s)", text):
                block = block.strip()
                if not block:
                    continue
                hm = re.match(r"^(#{1,6})\s+(.*)$", block)
                section = current
                if hm:
                    section = re.sub(r"\s+", " ", hm.group(2)).strip()
                    current = section
                rows.append((m["id"], corpus, m["year"], "page", page,
                             section or "", re.sub(r"\s+", " ", block)[:20000]))
        for t in m.get("tables", []):
            csv_file = paper_dir / t["csv"]
            if csv_file.exists():
                rows.append((m["id"], corpus, m["year"], "table", t["page"] or 0, f"table {t['id']}",
                             csv_file.read_text(encoding="utf-8", errors="replace")[:20000]))
    con.executemany("INSERT INTO chunks VALUES(?,?,?,?,?,?,?)", rows)
    con.commit()
    con.execute("INSERT INTO chunks(chunks) VALUES('optimize')")
    con.commit()
    con.close()
    log(f"    index: {len(records)} papers, {len(rows)} searchable chunks -> {db_path.name}")


# --------------------------------------------------------------------------- #
# main
# --------------------------------------------------------------------------- #
def main() -> int:
    ensure_venv()
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--corpus", action="append", default=None,
                    help="only this corpus, e.g. --corpus WASPAA --corpus SMC (repeatable)")
    ap.add_argument("--year", action="append", default=None,
                    help="only this year or year dir, e.g. --year 2026 or --year DAFx-2026 (repeatable)")
    ap.add_argument("--limit", type=int, default=None, help="only the first N papers")
    ap.add_argument("--only", action="append", default=None, metavar="SUBSTRING",
                    help="only papers whose id contains SUBSTRING (repeatable)")
    ap.add_argument("--workers", type=int, default=min(4, (os.cpu_count() or 2)),
                    help="parallel conversions (default 4)")
    ap.add_argument("--force", action="store_true", help="reconvert papers already done")
    ap.add_argument("--skip-convert", action="store_true", help="only rebuild the index")
    ap.add_argument("--redo-fallbacks", action="store_true",
                    help="reconvert only papers that needed the PyMuPDF text-only fallback "
                         "(implies --force); the repaired-copy retry may parse them fully")
    ap.add_argument("--redo-if-missing", metavar="FIELD",
                    help="reconvert only papers whose metadata.json lacks FIELD (implies "
                         "--force); useful to roll out a change without redoing everything")
    ap.add_argument("--timeout", type=int, default=300, help="per-PDF timeout in seconds")
    args = ap.parse_args()

    if not CLI.exists():
        log(f"error: {CLI} not found. Run ./tools/setup_env.sh first.")
        return 1

    corpora = {c.lower() for c in args.corpus} if args.corpus else None
    years = None
    if args.year:
        years = {y.lower() for y in args.year}

    env = java_env()
    PAPERS.mkdir(parents=True, exist_ok=True)
    INDEX.mkdir(parents=True, exist_ok=True)

    recs = discover(ORIGINALS, corpora, years)
    if args.redo_fallbacks or args.redo_if_missing:
        field = args.redo_if_missing
        weak = []
        for r in recs:
            mf = PAPERS / r["corpus"] / r["year_dir"] / r["pid"] / "metadata.json"
            try:
                meta = json.loads(mf.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError):
                weak.append(r)          # missing or unreadable: rebuild it
                continue
            if field is not None:
                if field not in meta:
                    weak.append(r)
            elif meta.get("extractor") == "pymupdf-fallback":
                weak.append(r)
        log(f"==> --redo-if-missing {field}: {len(weak)} of {len(recs)} papers selected"
            if field else f"==> --redo-fallbacks: {len(weak)} of {len(recs)} papers selected")
        recs, args.force = weak, True
    if args.only:
        needles = [n.lower() for n in args.only]
        recs = [r for r in recs if any(n in r["pid"].lower() for n in needles)]
    if args.limit is not None:
        recs = recs[:args.limit]
    log(f"==> {len(recs)} PDFs to process "
        f"({len(set(r['corpus'] for r in recs))} corpora, {len(set(r['year'] for r in recs))} years, {args.workers} workers)")

    run_metas: dict[str, dict] = {}
    started = time.time()
    if not args.skip_convert:
        done = 0
        with ThreadPoolExecutor(max_workers=max(1, args.workers)) as pool:
            futures = {pool.submit(build_paper, r, env, args.force, args.timeout): r for r in recs}
            for fut in as_completed(futures):
                r = futures[fut]
                try:
                    meta = fut.result()
                except Exception as exc:                     # noqa: BLE001
                    meta = {**rec_base(r), "status": "failed", "error": f"crash: {exc}"}
                run_metas[meta["id"]] = meta
                done += 1
                if meta.get("status") == "ok":
                    if meta.get("_cached"):
                        continue
                    warn = f"  [{meta['extraction_warning']}]" if meta.get("extraction_warning") else ""
                    log(f"  [{done}/{len(recs)}] [{meta.get('corpus', 'DAFx')}] {meta['id']} "
                        f"p{meta['page_count']} {meta['word_count']}w "
                        f"fig{meta['figure_count']} tab{len(meta['tables'])}{warn}")
                else:
                    log(f"  [{done}/{len(recs)}] FAILED {meta['id']}: {meta.get('error')}")

    elapsed = time.time() - started
    if not args.skip_convert:
        log(f"==> conversion finished in {elapsed/60:.1f} min")

    # Merge newly converted papers with all previously converted papers on disk so
    # partial runs (--corpus, --year, --limit) never wipe out the rest of the index.
    by_id = {m["id"]: m for m in all_saved_metas()}
    by_id.update(run_metas)
    metas = list(by_id.values())

    report = write_indexes(metas)
    report.update({
        "generated": time.strftime("%Y-%m-%d %H:%M:%S"),
        "conversion_seconds": round(elapsed, 1),
        "failed_papers": [
            {"id": m["id"], "year": m.get("year"), "file": m.get("paper_file"),
             "error": m.get("error")} for m in report["failures"]],
        "needs_ocr_review": [
            {"id": m["id"], "year": m["year"], "words": m.get("word_count")}
            for m in metas if m.get("status") == "ok" and m.get("needs_ocr_review")],
        "extractors": {k: sum(1 for m in metas if m.get("extractor") == k)
                       for k in {m.get("extractor") for m in metas if m.get("extractor")}},
    })
    (INDEX / "build_report.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")

    log(f"==> indexed {report['papers_indexed']} papers; "
        f"{len(report['failed_papers'])} failures; "
        f"{len(report['needs_ocr_review'])} flagged for OCR review")
    log(f"==> index/INDEX.jsonl, index/INDEX.md, index/search.sqlite, index/build_report.json")
    return 0


if __name__ == "__main__":
    sys.exit(main())
