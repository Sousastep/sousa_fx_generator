# Audio DSP & Music Computing Papers Library

Multi-corpus machine-readable library of audio signal processing, music
computing, and transferable signal-processing papers, prepared so an LLM agent
can **search cheaply across venues, then read only what it needs**.

Built with [OpenDataLoader PDF](https://opendataloader.org/) (Java CLI + Python
wrapper) from the untouched PDFs in `originals/`.

## Library directory structure

```
papers_library/                  (also reachable via ./DAFx-proceedings symlink)
  originals/                     the source PDFs + .meta.json sidecars (never modified)
    DAFx/DAFx-<year>/*.pdf       1,706 DAFx papers (1998–2026)
    WASPAA/WASPAA-<year>/*.pdf   IEEE Workshop on Applications of Signal Processing to Audio & Acoustics
    SMC/SMC-<year>/*.pdf         Sound and Music Computing Conference (Zenodo community)
    NIME/NIME-<year>/*.pdf       New Interfaces for Musical Expression (official BibTeX archive)
    ISMIR/ISMIR-<year>/*.pdf     Int. Society for Music Information Retrieval (official archive)
    ICASSP/ICASSP-<year>/*.pdf   IEEE ICASSP (filtered to audio/DSP/synthesis open-access papers)
    ICMC/ICMC-<year>/*.pdf       International Computer Music Conference (open-access subset)
    AES/AES-<year>/*.pdf         Audio Engineering Society open-access papers
    arXiv/arXiv-<year>/*.pdf     arXiv eess.AS / eess.SP / cs.SD (mined by DSP mechanism presets)
  papers/
    <Corpus>/<Corpus>-<year>/<paper-id>/
      paper.md                   full text: front matter, headings, page anchors, images, tables
      metadata.json              id, corpus, title, authors, year, venue, pages, sections, keywords
      structure.json             raw parser output: bboxes, fonts, table cells
      figures/                   images lifted out of the PDF (PNG)
      tables/tableN.csv | .md    one file per detected table
      source.pdf                 symlink to originals/<Corpus>/<Corpus>-<year>/...
  manifests/
    <corpus>_manifest.jsonl      download log and upstream metadata per fetched paper
  index/
    INDEX.jsonl                  one compact record per paper  <- tier 1
    INDEX.md                     the same records, readable
    search.sqlite                SQLite FTS5 index over pages + tables <- tier 2
    build_report.json            failures, OCR-review flags, extractor counts
```

## 1. Searching and downloading new PDFs (`tools/fetch_papers.py`)

`tools/fetch_papers.py` searches open-access repositories (Zenodo API, NIME &
ISMIR official archives, WASPAA archives, OpenAlex open-access endpoints, and
the arXiv API) and downloads verified PDFs along with `.meta.json` sidecars.
It enforces a hard disk cap across `originals/` (default **95 GB**, keeping the
corpus well under 100 GB).

```bash
./tools/fetch_papers.py --status                                     # disk usage & counts per corpus
./tools/fetch_papers.py --source all --limit 25                      # fetch across all low-hanging-fruit sources
./tools/fetch_papers.py --source smc --limit 50                      # Sound and Music Computing (Zenodo)
./tools/fetch_papers.py --source nime --year 2025 --limit 30         # NIME (filtered to DSP/synthesis/instrument papers)
./tools/fetch_papers.py --source ismir --year 2024 --limit 30        # ISMIR (filtered to DSP/audio effects papers)
./tools/fetch_papers.py --source waspaa --limit 50                   # WASPAA open-access papers
./tools/fetch_papers.py --source aes --limit 30                      # AES open-access papers
./tools/fetch_papers.py --source icassp --query "nonlinear filter"   # targeted ICASSP search
./tools/fetch_papers.py --source arxiv --preset virtual_analog       # arXiv mechanism preset
./tools/fetch_papers.py --source arxiv --preset all --limit 80       # all 8 DSP/telecom mechanism presets
```

Available `--preset` values for `--source arxiv`:
- `adaptive` — adaptive filters, Kalman, RLS, system identification
- `virtual_analog` — wave digital filters, Volterra series, nonlinear state-space, port-Hamiltonian, ADAA
- `modulation_spectral` — phase distortion, FM, allpass, phase vocoder, Hilbert, formant
- `comms_channel` — channel estimation, OFDM, equalization, companding
- `radar_chirp` — matched filters, pulse compression, chirps, dispersion, Doppler
- `sparse_coding` — sparse recovery, compressed sensing, dictionary learning
- `quantization_lofi` — delta modulation, predictive coding, dither, noise shaping, quantization
- `spatial_array` — beamforming, ambisonics, decorrelation, feedback delay networks

## 2. Building / updating the index (`tools/build_corpus.py`)

Conversion is incremental and merges newly converted papers with all existing
converted papers on disk:

```bash
./tools/build_corpus.py                          # convert all unindexed PDFs across all corpora
./tools/build_corpus.py --corpus WASPAA          # convert only WASPAA PDFs and update index
./tools/build_corpus.py --corpus arXiv --limit 5 # smoke test on 5 papers
./tools/build_corpus.py --skip-convert           # rebuild only INDEX.jsonl / search.sqlite
```

## 3. Querying the library (`tools/search.py`)

```bash
./tools/search.py "modal plate reverberation"                  # full-text search across all corpora
./tools/search.py "waveguide" --corpus DAFx --year 2010        # filter by corpus and year
./tools/search.py "modulation" --corpus AES                    # search only AES papers
./tools/search.py "Volterra" --corpus arXiv                    # search only arXiv papers
./tools/search.py --list --corpus WASPAA                       # list indexed papers in a corpus
./tools/search.py --index 2026_AES_Carson_W7169774185          # tier-1 metadata record
./tools/search.py --read  2026_AES_Carson_W7169774185 --page 1 # read a specific page
```
