#!/usr/bin/env bash
# Snapshot the Windows Terminal settings into the repo, commit everything, and push when a
# remote is configured. Usage: dotsave ["commit message"]
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

wt_settings=(/mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json)
[[ -f ${wt_settings[0]} ]] || { echo "Windows Terminal settings not found" >&2; exit 1; }
cp "${wt_settings[0]}" windows-terminal/settings.json

git add -A
if git diff --cached --quiet; then
  echo "Nothing to save."
  exit 0
fi
git commit -q -m "${1:-Update dotfiles}"
if git remote get-url origin >/dev/null 2>&1; then
  git push -q
fi
git log --oneline -1
