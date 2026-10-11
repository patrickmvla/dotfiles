#!/usr/bin/env bash
# Install or update the standalone CLI tools in ~/.local/bin from their latest GitHub
# releases, then the zsh plugins, yazi packages and hunk. Safe to re-run: a tool is only
# downloaded when its release tag differs from the one recorded on the last run.
set -uo pipefail

bin_dir="$HOME/.local/bin"
state_dir="$HOME/.local/state/update-tools"
plugin_dir="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$bin_dir" "$state_dir"

# name | github repo | release asset regex | binaries (archive-name:installed-name when they differ)
tools=(
  'starship|starship/starship|^starship-x86_64-unknown-linux-musl\.tar\.gz$|starship'
  'fzf|junegunn/fzf|^fzf-.*-linux_amd64\.tar\.gz$|fzf'
  'eza|eza-community/eza|^eza_x86_64-unknown-linux-musl\.tar\.gz$|eza'
  'bat|sharkdp/bat|^bat-.*-x86_64-unknown-linux-musl\.tar\.gz$|bat'
  'fd|sharkdp/fd|^fd-.*-x86_64-unknown-linux-musl\.tar\.gz$|fd'
  'ripgrep|BurntSushi/ripgrep|^ripgrep-.*-x86_64-unknown-linux-musl\.tar\.gz$|rg'
  'zoxide|ajeetdsouza/zoxide|^zoxide-.*-x86_64-unknown-linux-musl\.tar\.gz$|zoxide'
  'atuin|atuinsh/atuin|^atuin-x86_64-unknown-linux-musl\.tar\.gz$|atuin'
  'delta|dandavison/delta|^delta-.*-x86_64-unknown-linux-musl\.tar\.gz$|delta'
  'lazygit|jesseduffield/lazygit|^lazygit_.*_linux_x86_64\.tar\.gz$|lazygit'
  'yazi|sxyazi/yazi|^yazi-x86_64-unknown-linux-musl\.zip$|yazi ya'
  'micro|micro-editor/micro|^micro-.*-linux64-static\.tar\.gz$|micro'
  'btop|aristocratos/btop|^btop-x86_64-unknown-linux-musl\.tar\.gz$|btop'
  'glow|charmbracelet/glow|^glow_.*_Linux_x86_64\.tar\.gz$|glow'
  'tealdeer|tealdeer-rs/tealdeer|^tealdeer-linux-x86_64-musl$|tealdeer-linux-x86_64-musl:tldr'
  'fnm|Schniz/fnm|^fnm-linux\.zip$|fnm'
)

zsh_plugins=(
  'fzf-tab|https://github.com/Aloxaf/fzf-tab'
  'zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions'
  'zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting'
)

failed=()

# Prints "<tag>\t<download url>" for the asset matching regex $2 in the latest release of repo $1.
latest_release() {
  local json
  if gh auth token >/dev/null 2>&1; then
    json=$(gh api "repos/$1/releases/latest") || return 1
  else
    json=$(curl -fsSL "https://api.github.com/repos/$1/releases/latest") || return 1
  fi
  jq -er --arg re "$2" '.tag_name as $t | first(.assets[] | select(.name | test($re))) | "\($t)\t\(.browser_download_url)"' <<<"$json"
}

update_tool() {
  local name=$1 repo=$2 pattern=$3 bins=$4 release tag url tmp bin src found
  release=$(latest_release "$repo" "$pattern") || { echo "x $name: no release asset matches $pattern" >&2; return 1; }
  tag=${release%%$'\t'*} url=${release#*$'\t'}
  if [[ -f $state_dir/$name && $(<"$state_dir/$name") == "$tag" ]]; then
    echo "  $name $tag"
    return 0
  fi
  tmp=$(mktemp -d)
  curl -fsSL --retry 3 -o "$tmp/asset" "$url" || { rm -rf "$tmp"; echo "x $name: download failed" >&2; return 1; }
  case $url in
    *.tar.gz) tar -xzf "$tmp/asset" -C "$tmp" ;;
    *.zip) unzip -q "$tmp/asset" -d "$tmp" ;;
    *) mv "$tmp/asset" "$tmp/${url##*/}" ;;
  esac || { rm -rf "$tmp"; echo "x $name: could not unpack ${url##*/}" >&2; return 1; }
  for bin in $bins; do
    src=${bin%%:*}
    found=$(find "$tmp" -type f -name "$src" | head -1)
    [[ -n $found ]] || { rm -rf "$tmp"; echo "x $name: $src not found in ${url##*/}" >&2; return 1; }
    install -m755 "$found" "$bin_dir/${bin##*:}"
  done
  rm -rf "$tmp"
  echo "$tag" > "$state_dir/$name"
  echo "+ $name $tag (updated)"
}

echo "CLI tools:"
for tool in "${tools[@]}"; do
  IFS='|' read -r name repo pattern bins <<<"$tool"
  update_tool "$name" "$repo" "$pattern" "$bins" || failed+=("$name")
done

if [[ -d $HOME/.oh-my-zsh ]]; then
  echo "zsh plugins:"
  for plugin in "${zsh_plugins[@]}"; do
    name=${plugin%%|*} url=${plugin#*|}
    if [[ -d $plugin_dir/$name/.git ]]; then
      git -C "$plugin_dir/$name" pull -q --ff-only && echo "  $name" || failed+=("$name")
    else
      git clone -q --depth 1 "$url" "$plugin_dir/$name" && echo "+ $name (installed)" || failed+=("$name")
    fi
  done
fi

echo "yazi packages:"
"$bin_dir/ya" pkg install >/dev/null 2>&1 && "$bin_dir/ya" pkg upgrade >/dev/null 2>&1 && echo "  flavors and plugins" || failed+=("yazi packages")

echo "hunk:"
if command -v npm >/dev/null; then
  npm install -g --silent hunkdiff@latest && echo "  hunkdiff $(npm ls -g --depth=0 2>/dev/null | sed -n 's/.*hunkdiff@//p')" || failed+=("hunkdiff")
else
  echo "  skipped: npm is not on PATH (install node with: fnm install --lts)"
fi

"$bin_dir/tldr" --update >/dev/null 2>&1 || failed+=("tldr pages")

if (( ${#failed[@]} )); then
  echo "FAILED: ${failed[*]}" >&2
  exit 1
fi
echo "All up to date."
