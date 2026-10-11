#!/usr/bin/env bash
# Render docs/terminal-guide.md to a PDF in the Windows Downloads folder (via headless Edge).
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

downloads="$(wslpath "$(cd /mnt/c && cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")/Downloads"
edge='/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe'
[[ -d $downloads && -x $edge ]] || { echo "Windows Downloads folder or Edge not found" >&2; exit 1; }
html="$downloads/terminal-guide.tmp.html"
trap 'rm -f "$html"' EXIT

uv run -q --with markdown python - "$html" <<'PY'
import sys, pathlib, markdown
body = markdown.markdown(
    pathlib.Path("terminal-guide.md").read_text(encoding="utf-8"),
    extensions=["tables", "fenced_code", "sane_lists", "toc"],
    extension_configs={"toc": {"toc_depth": "2-2"}},
)
css = pathlib.Path("guide.css").read_text(encoding="utf-8")
pathlib.Path(sys.argv[1]).write_text(
    f'<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Working in the terminal</title>'
    f"<style>{css}</style></head><body>{body}</body></html>",
    encoding="utf-8",
)
PY

cp terminal-guide.md "$downloads/terminal-guide.md"
(cd /mnt/c && "$edge" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$(wslpath -w "$downloads/terminal-guide.pdf")" "$(wslpath -w "$html")" 2>&1 \
  | grep -o '[0-9]* bytes written.*')
