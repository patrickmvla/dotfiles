# ── oh-my-zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
# Prompt is drawn by starship (initialised at the end of this file).
ZSH_THEME=""
# fzf-tab must come before zsh-autosuggestions and zsh-syntax-highlighting.
plugins=(git fzf-tab zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# ── PATH and toolchains ──────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# bocek
export PATH="$HOME/.bocek/bin:$PATH"

# fnm (node version manager); switches version on cd into a dir with .nvmrc / .node-version
eval "$(fnm env --use-on-cd --shell zsh)"

# go
for d in /usr/local/go/bin "$HOME/go/bin"; do
  case ":$PATH:" in
    *":$d:"*) ;;
    *) export PATH="$PATH:$d" ;;
  esac
done
unset d

# adb talks to the server running on the Windows host
export ADB_SERVER_SOCKET=tcp:$(ip route show default | awk '{print $3}'):5037

# ── tools ────────────────────────────────────────────────────────────────────
export EDITOR=micro VISUAL=micro
export BAT_THEME="Catppuccin Mocha"

alias ls='eza --icons --group-directories-first'
alias ll='eza --icons --group-directories-first -l --git'
alias la='eza --icons --group-directories-first -la --git'
alias lt='eza --icons --group-directories-first --tree --level=2'
alias cat='bat --paging=never'
alias lg='lazygit'
alias hd='hunk diff --watch'
alias hs='hunk show'
alias dotsave="$HOME/dotfiles/save.sh"
alias update-tools="$HOME/dotfiles/update-tools.sh"

# ff [query]: live-grep the current directory tree; enter opens the match in $EDITOR at that line
ff() {
  local reload='reload:rg --column --line-number --no-heading --color=always --smart-case --hidden --glob "!.git" -- {q} || :'
  fzf --disabled --ansi --delimiter : --query "$*" \
    --bind "start:$reload" --bind "change:$reload" \
    --bind 'enter:become:${EDITOR:-micro} +{2} {1}' \
    --preview 'bat --color=always --style=numbers --highlight-line {2} -- {1}' \
    --preview-window 'right,55%,border-left,+{2}+3/3,~3'
}

# yazi file manager; `y` changes the shell's directory to wherever you quit
y() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [[ -n $cwd && $cwd != $PWD ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# work [dir|name]: new Windows Terminal tab with Claude Code on the left, the live diff
# top right and a shell bottom right. A name that is not a path is resolved by zoxide.
work() {
  local dir=${1:-$PWD}
  [[ -d $dir ]] || dir=$(zoxide query -- "$1") || return
  dir=${dir:A}
  local profile='{f3ae1e4f-9c97-5f7b-830b-e470b01b3cd6}'  # Ubuntu profile in Windows Terminal
  local -a pane=(-p $profile wsl.exe -d $WSL_DISTRO_NAME --cd $dir)
  local -a layout=(new-tab --title ${dir:t} $pane -- zsh -ic claude)
  if git -C $dir rev-parse --is-inside-work-tree &>/dev/null; then
    layout+=(';' split-pane -V -s 0.45 $pane -- zsh -ic 'hunk diff --watch')
    layout+=(';' split-pane -H -s 0.35 $pane)
  else
    layout+=(';' split-pane -V -s 0.4 $pane)
  fi
  (cd /mnt/c && wt.exe -w 0 $layout ';' move-focus first)
}

eval "$(zoxide init zsh)"

# ── fzf ──────────────────────────────────────────────────────────────────────
# ctrl-t picks files, alt-c jumps to a directory (ctrl-r stays with atuin, initialised below)
export FZF_DEFAULT_OPTS="\
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A,border:#6C7086,label:#CDD6F4"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
[[ -t 0 ]] && source <(fzf --zsh)  # key bindings need a terminal
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:complete:(cd|z|ls|ll|la|lt):*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath'
zstyle ':fzf-tab:complete:(cat|bat):*' fzf-preview 'bat --color=always --style=numbers --line-range=:200 $realpath'

# ── history and prompt ───────────────────────────────────────────────────────
eval "$(atuin init zsh --disable-up-arrow)"
eval "$(starship init zsh)"  # config: ~/.config/starship.toml
