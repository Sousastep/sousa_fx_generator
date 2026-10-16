#!/usr/bin/env bash
# Set up the toolchain used to turn DAFx-proceedings/originals/*.pdf into an
# agent-readable corpus (see build_corpus.py).
#
# Installs:
#   * OpenJDK 21      - opendataloader-pdf ships a Java CLI and needs Java 11+
#   * uv              - fast venv + installer
#   * opendataloader-pdf (in ./.venv) plus PyMuPDF as a fallback extractor
#   * Tesseract       - last-resort OCR for pages with no usable text layer
#
# Safe to re-run.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> project root: $ROOT"

if ! command -v brew >/dev/null 2>&1; then
  echo "ERROR: Homebrew not found. Install a JDK 11+ manually, then re-run." >&2
  exit 1
fi

# ---------------------------------------------------------------- Java 11+ ---
JAVA_HOME_CANDIDATE="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
if [ ! -x "$JAVA_HOME_CANDIDATE/bin/java" ]; then
  echo "==> installing OpenJDK 21 (opendataloader-pdf requires Java 11+)"
  brew install openjdk@21
fi
if [ ! -x "$JAVA_HOME_CANDIDATE/bin/java" ]; then
  echo "ERROR: expected a JDK at $JAVA_HOME_CANDIDATE after install." >&2
  exit 1
fi
echo "==> java: $("$JAVA_HOME_CANDIDATE/bin/java" -version 2>&1 | head -1)"

# ------------------------------------------------------------------- OCR ---
if ! command -v tesseract >/dev/null 2>&1; then
  echo "==> installing tesseract (OCR fallback for unreadable pages)"
  brew install tesseract
fi
echo "==> tesseract: $(tesseract --version 2>&1 | head -1)"

# ------------------------------------------------------------------ Python ---
if ! command -v uv >/dev/null 2>&1; then
  echo "ERROR: uv not found (https://docs.astral.sh/uv/)." >&2
  exit 1
fi

if [ ! -x "$ROOT/.venv/bin/python" ]; then
  echo "==> creating ./.venv (python 3.12)"
  uv venv "$ROOT/.venv" --python 3.12
fi

echo "==> installing python packages"
uv pip install --python "$ROOT/.venv/bin/python" -U opendataloader-pdf pymupdf

echo
echo "==> done. Extract with:"
echo "      ./tools/build_corpus.py            # full run"
echo "      ./tools/build_corpus.py --year 2026  # one year"
echo "    Search with:"
echo "      ./tools/search.py \"waveguide filter\""
