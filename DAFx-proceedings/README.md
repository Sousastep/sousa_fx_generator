# DAFx proceedings corpus

Machine-readable version of the DAFx conference proceedings, prepared so an LLM
agent can **search cheaply, then read only what it needs**.

Built with [OpenDataLoader PDF](https://opendataloader.org/) (Java CLI + Python
wrapper) from the untouched PDFs in `originals/`.

## At a glance

| | |
|---|---|
| Papers | **1706** (all of DAFx 1998–2026, 2.0 GB of PDFs) |
| Extracted text | **7.9 M words** in 35 048 searchable chunks |
| Figures | 13 060 PNGs |
| Tables | 1 323 CSVs |
| Index size | 2.3 GB total (2.2 GB papers, 117 MB index) |
| Failed conversions | **0** |
| Papers needing OCR | **7** (all OCR'd automatically, see below) |

How each paper was extracted (`metadata.json` → `extractor`):

| Method | Papers |
|---|---|
| `opendataloader-pdf` | 1538 |
| `opendataloader-pdf (repaired copy)` — Java parser rejected the file, a PyMuPDF-rewritten copy parsed | 102 |
| `pymupdf-fallback` — text-only, no figures/tables/bboxes | 57 |
| `opendataloader-pdf + tesseract ocr` — no usable text layer, pages rendered and OCR'd | 7 |
| `opendataloader-pdf + pymupdf text` — parser found <200 words, readable PyMuPDF text used | 2 |

```
DAFx-proceedings/
  originals/                       the source PDFs, never modified
  papers/DAFx-<year>/<paper-id>/
    paper.md                       full text: front matter, headings, page anchors,
                                   images, extracted tables
    metadata.json                  title, authors, year, venue, pages, sections,
                                   keywords, abstract, tables, figures, paths
    structure.json                 raw parser output: bboxes, fonts, table cells
    figures/                       images lifted out of the PDF (PNG)
    tables/tableN.csv | tableN.md  one file per detected table
    source.pdf                     symlink to originals/... (the file is not copied)
  index/
    INDEX.jsonl                    one compact record per paper  <- tier 1
    INDEX.md                       the same records, readable
    search.sqlite                  SQLite FTS5 index over pages + tables <- tier 2
    build_report.json              failures, OCR-review flags, extractor counts
  tools/                           see the repository root
```

## How to query it

```bash
./tools/search.py "modal plate reverberation"        # full-text search
./tools/search.py "waveguide" --year 2010 --limit 5
./tools/search.py "amplitude modulation" --author Roebel
./tools/search.py "delay line" --kind table          # search only inside tables
./tools/search.py "residual" --json                  # machine-readable hits
./tools/search.py --list --year 2026                 # titles of one year
./tools/search.py --index 2010_Roebel_DAFx10_K3      # tier-1 record for a paper
./tools/search.py --read  2010_Roebel_DAFx10_K3      # full paper.md
./tools/search.py --read  2010_Roebel_DAFx10_K3 --page 3
```

Recommended agent loop: hit `--search`/`INDEX.jsonl` on keywords, read the
`abstract`/`keywords`/`sections` of the candidates, then `--read` (or `--page`)
only the papers that matter. Answers can cite `<paper-id>` plus a page anchor.

## Record schema

`index/INDEX.jsonl` (tier 1, one line per paper):

```json
{
  "id": "2010_Roebel_DAFx10_K3", "title": "...", "authors": ["..."],
  "year": 2010, "venue": "DAFx 2010", "pages": 12,
  "keywords": ["..."], "sections": ["1 Introduction", "..."],
  "figures": 1, "tables": 0, "abstract": "...",
  "path": "papers/DAFx-2010/2010_Roebel_DAFx10_K3/paper.md",
  "metadata": "papers/.../metadata.json", "source_pdf": "../../originals/..."
}
```

`metadata.json` (tier 2, per paper) adds `sections` with page numbers,
`tables`, `figures`, `word_count`, `extractor`, `structure_json` and
`authors_raw` (the unparsed page-1 author block, for tracing bad parses).

In `paper.md`, every page starts with `<!-- page: N -->`, so a citation can
point at an exact page; images are referenced as `figures/*.png`; tables that
the Markdown exporter could not lay out inline are appended under
`## Extracted tables` with their page number and the matching `tables/*.csv`.

## Rebuilding

```bash
./tools/setup_env.sh    # JDK 21 + Tesseract + .venv + opendataloader-pdf + PyMuPDF

./tools/build_corpus.py                  # convert everything (skips what is done)
./tools/build_corpus.py --year 2026      # one year
./tools/build_corpus.py --only 2000_Bonsi_Stanzial --force   # redo one paper
./tools/build_corpus.py --redo-fallbacks # retry the text-only fallback papers
./tools/build_corpus.py --redo-if-missing ocr_applied --force  # roll out a change
./tools/build_corpus.py --skip-convert   # rebuild only the index
```

Conversion runs one JVM per PDF, so `--workers N` parallelises it (~1.3 s per
paper on an M-series laptop, 4 workers by default; the full corpus takes about
6 minutes, plus OCR for the few unreadable papers).
When a PDF is rejected or comes back nearly empty, the pipeline retries in
order: a PyMuPDF-rewritten copy → readable PyMuPDF text → Tesseract OCR. Every
step is recorded in that paper's `metadata.json` (`extractor`,
`extraction_warning`).

## Known limits — check `index/build_report.json`

- **Equations.** Extracted as best-effort Unicode/LaTeX-ish text; a fraction of
  display math (and any equation that is an image) is garbled. Use
  `source.pdf` + the page anchor when an equation matters.
- **Figures are raster only.** PNGs come from embedded image objects; vector
  graphics (most line plots and block diagrams in these papers) are not
  re-rendered, so a figure may exist only in `source.pdf`. Decoder-noise images
  smaller than 48 px / 12 000 px² are dropped as junk.
- **OCR is the last resort, and it fires automatically.** A paper whose extracted
  text is under 200 words is retried, in order: (1) readable PyMuPDF text, (2)
  Tesseract on pages rendered at 300 dpi. Every alternative must pass a
  prose check (enough common words), so mojibake is refused rather than indexed.
  Seven papers needed OCR and now read cleanly; `metadata.json` marks them with
  `"ocr_applied": true` and an `extractor` ending in `+ tesseract ocr`, since
  OCR text has lower fidelity than a real text layer.

  The seven were `1998_ERN16`, `1998_ERN17`, `2003_dafx42` and `2007_p047`
  (subset fonts with broken `ToUnicode` maps), plus
  `2000_Pesce_realtime_stretching`, `2000_laurson` and `2000_savioja` (no text
  layer at all). `2000_laurson` is imposed rotated, so OCR falls back to
  Tesseract's orientation detection. A separate count of papers still needing a
  closer look is `needs_ocr_review` in the build report — currently empty.
- **Papers that failed conversion** are listed under `failed_papers`, with the
  parser error. A PyMuPDF text-only fallback runs automatically (marked
  `"extractor": "pymupdf-fallback"` in that paper's metadata).
- **Titles** are taken in order of trust: the PDF's own metadata title, then a
  title heading, then the largest text on page 1, then a clause of the first
  line. Candidates that are really something else are rejected — `Microsoft
  Word - d_ARF36.doc`, `INTRODUCTION`, `2. ALGORITHM OF ...`, `Figure 1: ...`,
  bare e-mail addresses and mojibake. About 0.7 % of papers (12) keep a title
  the heuristic could not clean up, because that PDF exposes no usable title at
  all; they are still searchable and readable.
- **Authors** come from the PDF metadata or the page-1 author block.
  `authors_raw` keeps that raw block, so a bad name split can always be traced
  back to the source text.
- **No invented content.** There are no generated summaries, topic tags or
  "key findings": the index carries only what the PDFs contain (abstract,
  headings, keywords counted from the abstract). Interpretation is left to the
  reading agent.
- **Empty pipe tables are removed.** Diagrams and screenshots are sometimes
  detected as tables; blocks where every cell is empty are stripped from the
  Markdown rather than left as noise.
- **One JVM per PDF.** With `--workers 4` and a 2 GB heap cap, the whole corpus
  converts in about 6 minutes on a 10-core machine.
