# dotfiles

Terminal setup for WSL2 (Ubuntu) + Windows Terminal: zsh with oh-my-zsh, starship, and the
tools described in `docs/terminal-guide.md`.

- `home/` mirrors `$HOME`; every file in it is symlinked into place.
- `windows-terminal/settings.json` is a snapshot of the Windows Terminal settings, refreshed by `save.sh`.
- `install.sh` sets up a fresh machine: links `home/`, installs the tools, applies git, gh, Claude Code and Windows Terminal settings.
- `update-tools.sh` installs or updates the CLI tools from their latest GitHub releases (alias: `update-tools`).
- `save.sh` commits everything and pushes if a remote is configured (alias: `dotsave "message"`).
- `docs/build-pdf.sh` renders the guide to a PDF in the Windows Downloads folder.

Not tracked: `~/.claude/settings.json` (machine-specific; `install.sh` adds the two status line keys),
`~/.gitconfig` (identity; `install.sh` sets the delta keys), and anything holding credentials.
