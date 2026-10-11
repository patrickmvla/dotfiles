#!/usr/bin/env bash
# Set up a fresh WSL machine from this repo: link the configs into $HOME, install the tools,
# and apply the git, gh, Claude Code and Windows Terminal settings.
set -euo pipefail
repo=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)

echo "Linking configs:"
(cd "$repo/home" && find . -type f -printf '%P\n') | while read -r file; do
  target="$HOME/$file"
  mkdir -p "$(dirname "$target")"
  if [[ -e $target && ! -L $target ]]; then
    mv "$target" "$target.pre-dotfiles"
    echo "  kept your existing $file as $file.pre-dotfiles"
  fi
  ln -sfn "$repo/home/$file" "$target"
done

[[ -d $HOME/.oh-my-zsh ]] || git clone -q --depth 1 https://github.com/ohmyzsh/ohmyzsh "$HOME/.oh-my-zsh"

export PATH="$HOME/.local/bin:$PATH"
if ! command -v node >/dev/null; then
  "$repo/update-tools.sh" || true  # first pass installs fnm; hunk needs node, so it is retried below
  fnm install --lts
  eval "$(fnm env --shell bash)"
fi
"$repo/update-tools.sh"

git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.line-numbers true
git config --global delta.syntax-theme 'Catppuccin Mocha'
command -v gh >/dev/null && gh config set pager 'hunk pager'

claude_settings="$HOME/.claude/settings.json"
[[ -f $claude_settings ]] || echo '{}' > "$claude_settings"
jq '.statusLine = {type: "command", command: "~/.claude/statusline.sh"}
    | .subagentStatusLine = {type: "command", command: "~/.claude/subagent-statusline.sh"}' \
  "$claude_settings" > "$claude_settings.tmp" && mv "$claude_settings.tmp" "$claude_settings"

wt_dirs=(/mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState)
if [[ -d ${wt_dirs[0]} ]]; then
  [[ -f ${wt_dirs[0]}/settings.json ]] && cp "${wt_dirs[0]}/settings.json" "${wt_dirs[0]}/settings.pre-dotfiles.json"
  cp "$repo/windows-terminal/settings.json" "${wt_dirs[0]}/settings.json"
fi

cat <<'NOTE'

Done. Two manual steps remain:
  1. Install "JetBrainsMono Nerd Font" on Windows (https://www.nerdfonts.com/font-downloads).
  2. Make zsh your login shell if it is not already: chsh -s "$(command -v zsh)"
The Windows Terminal profile GUIDs in windows-terminal/settings.json and in the `work`
function of .zshrc are per-machine; check them if `work` opens the wrong profile.
NOTE
