#!/usr/bin/env python3
"""Search and read the DAFx proceedings corpus.

The corpus is two-tier, so the agent can search cheaply and only then read:

    tier 1  DAFx-proceedings/index/INDEX.jsonl   compact record per paper
    tier 2  DAFx-proceedings/papers/DAFx-<year>/<id>/paper.md   full text

Examples
    ./tools/search.py "modal plate reverberation"
    ./tools/search.py "waveguide" --year 2010 --limit 5
    ./tools/search.py "Vocoder" --author Roebel
    ./tools/search.py --list --year 2026
    ./tools/search.py --index 2010_Roebel_DAFx10_K3      # tier-1 record
    ./tools/search.py --read  2010_Roebel_DAFx10_K3      # full paper.md
    ./tools/search.py --read  2010_Roebel_DAFx10_K3 --page 3
    ./tools/search.py "feedback delay" --json            # machine-readable
"""

from __future__ import annotations

import argparse
import json
import re
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
INDEX_DIR = ROOT / "DAFx-proceedings" / "index"
PAPERS = ROOT / "DAFx-proceedings" / "papers"
DB = INDEX_DIR / "search.sqlite"
INDEX_MD = INDEX_DIR / "INDEX.md"
PAGE_SEP = "<!-- page: %page-number% -->"


def die(msg: str, code: int = 1) -> int:
    print(msg, file=sys.stderr)
    return code


def connect() -> sqlite3.Connection:
    if not DB.exists():
        raise FileNotFoundError(f"{DB} not found - run ./tools/build_corpus.py first")
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    con.row_factory = sqlite3.Row
    return con


def fts_query(terms: list[str], mode: str) -> str:
    """Build a safe FTS5 query from raw user terms."""
    cleaned = [re.sub(r'["*()^:]', " ", t).strip() for t in terms]
    cleaned = [t for t in cleaned if t]
    if not cleaned:
        return ""
    if mode == "phrase":
        return '"' + " ".join(cleaned) + '"'
    quoted = [f'"{t}"' for t in cleaned]
    return (" OR " if mode == "or" else " AND ").join(quoted)


def rewrite_loose(terms: list[str]) -> str:
    """Retry helper: OR the terms together when the strict AND query matched nothing."""
    return fts_query(terms, "or")


def resolve_paper(name: str) -> Path | None:
    """Resolve a paper id: exact directory name first, then unique substring."""
    roots = PAPERS.glob("DAFx-*")
    for root in roots:
        exact = root / name
        if exact.is_dir():
            return exact
    matches = [p for p in PAPERS.glob("DAFx-*/*") if p.is_dir() and name in p.name]
    if len(matches) == 1:
        return matches[0]
    if len(matches) > 1:
        print(f"ambiguous '{name}', matches: " + ", ".join(m.name for m in matches),
              file=sys.stderr)
        return None
    return None


def snippet(text: str, terms: list[str], width: int = 320) -> str:
    flat = re.sub(r"\s+", " ", text).strip()
    low = flat.lower()
    pos = min([low.find(t.lower()) for t in terms if low.find(t.lower()) >= 0] or [0])
    start = max(0, pos - width // 3)
    out = flat[start:start + width].strip()
    return ("… " if start else "") + out + (" …" if start + width < len(flat) else "")


def paper_dirs() -> list[Path]:
    return sorted(p.parent for p in PAPERS.glob("DAFx-*/*/metadata.json"))


def cmd_search(args) -> int:
    con = connect()
    # argparse keeps each shell word (or quoted phrase) as one item: split them
    # into individual search terms so quoting does not turn into a phrase query.
    terms = " ".join(args.query).split()
    q = fts_query(terms, args.mode)
    if not q:
        return die("empty query")
    sql = """
        SELECT c.id, c.year, c.kind, c.page, c.section,
               snippet(chunks, 5, '[', ']', '…', 24) AS snip,
               bm25(chunks) AS score, c.text
        FROM chunks c
        WHERE chunks MATCH ?
    """
    params: list = [q]
    if args.year:
        sql += " AND c.year = ?"
        params.append(int(args.year))
    if args.author:
        sql += " AND c.id IN (SELECT id FROM papers WHERE authors LIKE ?)"
        params.append(f"%{args.author}%")
    if args.kind:
        sql += " AND c.kind = ?"
        params.append(args.kind)
    sql += " ORDER BY score, c.id, c.page LIMIT ?"
    params.append(args.limit)

    rows = con.execute(sql, params).fetchall()
    used = q
    if not rows and args.mode == "and":
        rows = con.execute(sql, [rewrite_loose(terms)] + params[1:]).fetchall()
        used = rewrite_loose(terms)

    if not rows:
        print(f"no matches for: {' '.join(args.query)}")
        return 1

    out = []
    for r in rows:
        rec = con.execute("SELECT title, authors, path, source_pdf FROM papers WHERE id = ?",
                          (r["id"],)).fetchone()
        out.append({
            "id": r["id"],
            "year": r["year"],
            "kind": r["kind"],
            "page": r["page"],
            "section": r["section"],
            "title": rec["title"] if rec else None,
            "authors": rec["authors"] if rec else None,
            "match": r["snip"] or snippet(r["text"], terms),
            "paper": rec["path"] if rec else None,
            "source_pdf": rec["source_pdf"] if rec else None,
        })

    if args.json:
        print(json.dumps({"query": " ".join(args.query), "fts_query": used, "hits": out},
                         indent=2, ensure_ascii=False))
        return 0

    by_paper: dict[str, list[dict]] = {}
    for h in out:
        by_paper.setdefault(h["id"], []).append(h)
    print(f'{len(out)} hit(s) in {len(by_paper)} paper(s)  [fts: {used}]\n')
    for pid, hits in by_paper.items():
        h = hits[0]
        print(f"● {pid} ({h['year']}) — {h['title']}")
        if h["authors"]:
            print(f"  {h['authors']}")
        for hit in hits[:3]:
            where = f"p.{hit['page']}" if hit["page"] else hit["kind"]
            sec = f" » {hit['section']}" if hit["section"] else ""
            print(f"  [{where}]{sec}")
            print(f"    {hit['match']}")
        print(f"  full text: {h['paper']}")
        print(f"  source pdf: {h['source_pdf']}")
        print()
    return 0


def cmd_index(args) -> int:
    paper = resolve_paper(args.index)
    if paper is None:
        return die(f"no unique paper matching '{args.index}'")
    meta_file = paper / "metadata.json"
    if not meta_file.exists():
        return die(f"{meta_file} not found")
    print(meta_file.read_text(encoding="utf-8"))
    return 0


def cmd_read(args) -> int:
    paper = resolve_paper(args.read)
    if paper is None:
        return die(f"no unique paper matching '{args.read}'")
    md_file = paper / "paper.md"
    if not md_file.exists():
        return die(f"{md_file} not found")
    text = md_file.read_text(encoding="utf-8", errors="replace")
    if args.page:
        parts = re.split(r"<!-- page: (\d+) -->", text)
        found = None
        for i in range(1, len(parts) - 1, 2):
            if int(parts[i]) == args.page:
                found = parts[i + 1]
                break
        if found is None:
            return die(f"page {args.page} not found in {paper.name}")
        text = f"<!-- page: {args.page} -->\n" + found.strip()
    if args.max_chars:
        text = text[:args.max_chars]
    print(text)
    return 0


def cmd_list(args) -> int:
    con = connect()
    sql = "SELECT id, year, title, authors, pages, figures, tables FROM papers"
    params: list = []
    if args.year:
        sql += " WHERE year = ?"
        params.append(int(args.year))
    if args.author:
        sql += (" AND" if args.year else " WHERE") + " authors LIKE ?"
        params.append(f"%{args.author}%")
    sql += " ORDER BY year, id"
    rows = con.execute(sql, params).fetchall()
    if args.json:
        print(json.dumps([dict(r) for r in rows], indent=2, ensure_ascii=False))
        return 0
    print(f"{len(rows)} paper(s)")
    for r in rows:
        print(f"  {r['id']:42s} {r['year']}  {r['pages']:>3}p  {(r['title'] or '')[:88]}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("query", nargs="*", help="search terms")
    ap.add_argument("--mode", choices=["and", "or", "phrase"], default="and",
                    help="term combination (falls back to 'or' when 'and' finds nothing)")
    ap.add_argument("--year", help="restrict to a conference year")
    ap.add_argument("--author", help="substring match on the author list")
    ap.add_argument("--kind", choices=["page", "table"], help="search only prose or only tables")
    ap.add_argument("--limit", type=int, default=12, help="max hits (default 12)")
    ap.add_argument("--json", action="store_true", help="machine-readable output")
    ap.add_argument("--list", action="store_true", help="list papers instead of searching")
    ap.add_argument("--index", metavar="ID", help="print the tier-1 record for a paper")
    ap.add_argument("--read", metavar="ID", help="print a paper's full Markdown")
    ap.add_argument("--page", type=int, help="with --read: only this page")
    ap.add_argument("--max-chars", type=int, help="with --read: truncate output")
    args = ap.parse_args()

    try:
        if args.read:
            return cmd_read(args)
        if args.index:
            return cmd_index(args)
        if args.list:
            return cmd_list(args)
        if not args.query:
            return die("nothing to do: pass search terms, --list, --index or --read")
        return cmd_search(args)
    except FileNotFoundError as exc:
        return die(str(exc))


if __name__ == "__main__":
    sys.exit(main())
