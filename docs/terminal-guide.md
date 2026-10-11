# Working in the terminal

A guide to this setup: what each piece is for, how a normal working session flows, and the keys worth remembering. The last section is a one-page quick reference.

[TOC]

## 1. The idea in one minute

The terminal now covers the jobs VS Code used to do. Each job has one short command.

| In VS Code you used | Here you use | Command |
|---|---|---|
| Explorer sidebar | yazi, a file explorer with previews | `y` |
| Search across files (`Ctrl-Shift-F`) | live search with preview | `ff` |
| Quick open (`Ctrl-P`) | fuzzy file picker | `Ctrl-T` |
| Diff editor | hunk, a live diff viewer | `hd` |
| Source Control panel | lazygit | `lg` |
| The editor | micro | `micro file` |
| Integrated terminal and splits | Windows Terminal panes | `work` |
| Task manager | btop | `btop` |

Almost every full-screen tool quits with `q`. When in doubt, `?` or `F1` usually shows that tool's keys.

> **After any change to the setup**, open a new tab or run `exec zsh`. A tab that was already open keeps its old settings.

## 2. Starting a work session

Run `work` from inside a project, or give it a project name from anywhere:

```
work              # use the folder you are in
work myproject    # jump to a project you have visited before
```

It opens a new tab laid out like this:

```
┌───────────────────────────┬──────────────────────┐
│                           │  hd                  │
│  Claude Code              │  live diff of what   │
│                           │  is changing         │
│                           ├──────────────────────┤
│                           │  a normal shell      │
│                           │  (lg, y, ff, tests)  │
└───────────────────────────┴──────────────────────┘
```

Claude works on the left. The top-right pane shows the diff and refreshes by itself as files change, so you review while the agent edits. The bottom-right pane is yours for everything else. Outside a git repository the diff pane is left out.

### Moving between panes

| Key | What it does |
|---|---|
| `Alt+arrow` | Move to the pane in that direction |
| `Alt+Shift+arrow` | Resize the current pane |
| `Alt+Shift++` | Split the current pane to the right |
| `Alt+Shift+-` | Split the current pane downward |
| `Alt+Shift+D` | Duplicate the current pane |
| `Ctrl+Shift+W` | Close the current pane |

Selecting text with the mouse copies it. `Ctrl+V` pastes.

## 3. Getting around

**Jump instead of typing paths.** The shell remembers every folder you visit.

| Command | What it does |
|---|---|
| `z proj` | Jump to the best match for "proj" among folders you have visited |
| `zi` | Pick a visited folder from a list |
| `Alt-C` | Pick a subfolder of where you are and jump into it |
| `cd -` | Go back to the previous folder |

**Look at what is here.**

| Command | What it does |
|---|---|
| `ls` | List files with icons, folders first |
| `ll` | The same with sizes, dates and git status |
| `la` | The same including hidden files |
| `lt` | A tree, two levels deep |
| `y` | Open the file explorer (section 7) |

**Let the shell type for you.**

| Key | What it does |
|---|---|
| `Tab` | Opens a fuzzy menu of completions. After `cd` or `ls` it previews folders; after `cat` it previews the file |
| `→` | Accept the grey suggestion taken from your history |
| `Ctrl-R` | Search every command you have run; type a few letters and press `Enter` |
| `Ctrl-T` | Pick a file by name and insert its path into the command you are typing |

## 4. Finding things

| You want | Do this |
|---|---|
| A file, by name | `Ctrl-T` and type part of the name |
| A piece of text, anywhere in the project | `ff` and type; the right side previews each match; `Enter` opens it in micro at that line |
| To start the search with a word | `ff useTenant` |
| A folder you were in last week | `z` plus part of its name |
| A command you ran before | `Ctrl-R` |

`ff` respects `.gitignore`, so `node_modules` and build output stay out of the results.

## 5. Reading and editing files

| Command | What it does |
|---|---|
| `cat file` | Print a file with syntax colours and line numbers |
| `glow README.md` | Read Markdown properly formatted |
| `micro file` | Edit a file |
| `tldr tar` | Short, example-based help for a command |

### micro, the editor

micro uses the keys you already know, and the mouse works for placing the cursor and selecting.

| Key | What it does |
|---|---|
| `Ctrl-S` | Save |
| `Ctrl-Q` | Close the file (asks if there are unsaved changes) |
| `Ctrl-Z` / `Ctrl-Y` | Undo and redo |
| `Ctrl-C` / `Ctrl-X` / `Ctrl-V` | Copy, cut, paste |
| `Ctrl-A` | Select everything |
| `Ctrl-F` | Find; `Ctrl-N` and `Ctrl-P` go to the next and previous match |
| `Ctrl-L` | Go to a line number |
| `Ctrl-D` | Duplicate the current line |
| `Ctrl-K` | Cut the current line |
| `Alt-↑` / `Alt-↓` | Move the current line up or down |
| `Ctrl-O` | Open another file |
| `Ctrl-T` | New tab; `Alt-,` and `Alt-.` switch tabs |
| `Ctrl-E` | Command bar (for example `replace old new`) |
| `Ctrl-G` | Help |

lazygit and yazi both open files in micro, and `Ctrl-Q` returns you to where you were.

## 6. Reviewing and committing changes

There are three views of a change, from quickest to most thorough.

| Command | Use it when |
|---|---|
| `git diff` | You want a quick look. Output is coloured with line numbers; `n` and `N` jump between files, `q` quits |
| `hd` | You want to review properly. Sidebar of changed files, split view, refreshes live |
| `lg` | You are ready to stage and commit |

### hunk, the diff viewer

| Command | What it shows |
|---|---|
| `hd` | Everything not yet committed, including new files, refreshing live |
| `hs` | The last commit |
| `hunk show HEAD~3` | An earlier commit |
| `hunk diff main` | Your branch compared with `main` |
| `hunk diff --staged` | Only what is staged |
| `hunk diff old.ts new.ts` | Two files against each other |
| `gh pr diff 123` | A pull request (GitHub refuses PRs with more than 300 files) |

Inside hunk the mouse works: click a file in the sidebar to jump to it and scroll the diff with the wheel. The menu bar along the top (File, View, Navigate, Agent, Help) is clickable and the Help menu lists every key. `t` opens the theme picker and `q` quits.

### lazygit, source control

`lg` opens five numbered panels on the left and the diff of whatever is highlighted on the right.

| Panel | What it holds |
|---|---|
| `1` Status | Repository and branch summary |
| `2` Files | Changed files; this is where you stage |
| `3` Branches | Local and remote branches |
| `4` Commits | History of the current branch |
| `5` Stash | Stashed work |

Press the number to jump to a panel, or use `←` and `→`. `↑` and `↓` move within a panel.

| Key | Where | What it does |
|---|---|---|
| `Space` | Files | Stage or unstage the highlighted file |
| `a` | Files | Stage or unstage everything |
| `Enter` | Files | Open the file's changes to stage single lines or blocks with `Space` |
| `d` | Files | Discard the changes to that file (asks first) |
| `e` | Files | Edit the file in micro |
| `c` | Files | Commit what is staged; type the message and press `Enter` |
| `A` | Files | Add the staged changes to the previous commit |
| `s` | Files | Stash all changes |
| `P` | Anywhere | Push |
| `p` | Anywhere | Pull |
| `f` | Anywhere | Fetch |
| `Space` | Branches | Switch to the highlighted branch |
| `n` | Branches | Create a new branch |
| `Enter` | Commits | See the files in that commit |
| `z` | Anywhere | Undo the last git action |
| `+` | Anywhere | Enlarge the current panel; press again to cycle back |
| `/` | Anywhere | Filter the current list |
| `Esc` | Anywhere | Go back or cancel |
| `?` | Anywhere | Show all keys for the current panel |
| `q` | Anywhere | Quit |

**A normal commit:** `lg`, press `2`, `Space` on each file you want (or `a` for all), `c`, type the message, `Enter`, then `P` to push.

## 7. The file explorer (yazi)

Type `y` in any folder. The screen has three columns: the parent folder on the left, the current folder in the middle, and a preview of whatever is highlighted on the right. Markers beside a name show its git state (modified, untracked, staged).

### Moving around

| Key | What it does |
|---|---|
| `↑` / `↓` | Move the highlight up or down |
| `→` | Go into the highlighted folder |
| `←` | Go back up to the parent folder |
| `Enter` | Open the highlighted item: a folder is entered, a file opens in micro |
| `Home` / `End` | Jump to the top or bottom of the list |
| `PageUp` / `PageDown` | Move a page at a time |
| `H` / `L` | Back and forward through folders you visited, like a browser |
| `g` then `h` | Go to your home folder |
| `g` then `Space` | Type a path to jump to |
| Mouse | Click an item to highlight it; the wheel scrolls the list |

### Opening and editing files

| Key | What it does |
|---|---|
| `Enter` | Open the file in micro |
| `Ctrl-S` (in micro) | Save |
| `Ctrl-Q` (in micro) | Close the file and return to yazi exactly where you were |
| `J` / `K` | Scroll the preview down or up without opening the file |
| `Tab` | Show details of the highlighted file (size, type, dates) |

### Finding things

| Key | What it does |
|---|---|
| `f` | Filter the current folder as you type; `Esc` clears it |
| `/` | Find a name in the current folder; `n` / `N` go to the next or previous match |
| `s` | Search file names in this folder and everything below it |
| `S` | Search inside files (by content) below this folder |
| `z` | Fuzzy-jump to any file or folder below this one |
| `Z` | Jump to a folder you have visited before |
| `.` | Show or hide hidden files (names starting with a dot) |

### Selecting, copying, moving, deleting

| Key | What it does |
|---|---|
| `Space` | Select or unselect the highlighted item and move down |
| `v` | Start selecting a range; move to extend it, `Esc` to stop |
| `Ctrl-A` | Select everything in the folder |
| `Esc` | Clear the selection |
| `y` | Copy the selected items (or the highlighted one) |
| `x` | Cut, to move them |
| `p` | Paste into the folder you are now in |
| `Y` or `X` | Cancel a copy or cut |
| `d` | Move to the trash (asks first) |
| `D` | Delete permanently (asks first) |

### Creating and renaming

| Key | What it does |
|---|---|
| `a` | Create a file; end the name with `/` to create a folder |
| `r` | Rename the highlighted item |
| `c` then `c` | Copy the full path to the clipboard |
| `c` then `f` | Copy just the file name |

### Sorting, tabs and quitting

| Key | What it does |
|---|---|
| `,` then `m` | Sort by last modified |
| `,` then `s` | Sort by size |
| `,` then `a` | Sort alphabetically |
| `t` then `t` | Open a new tab in the current folder |
| `1` to `9` | Switch to that tab |
| `[` / `]` | Previous or next tab |
| `;` | Run a shell command in the current folder |
| `~` or `F1` | Show every key binding |
| `q` | Quit; your shell ends up in the folder you were viewing |
| `Q` | Quit and stay in the folder you started from |

### Common tasks, step by step

| Task | Steps |
|---|---|
| Edit a file | `y`, arrow to the file, `Enter`, edit, `Ctrl-S`, `Ctrl-Q` |
| Move files to another folder | `Space` on each file, `x`, go to the target folder, `p` |
| Copy a file | Highlight it, `y`, go to the target folder, `p` |
| New folder with a file in it | `a`, type `name/`, `Enter`, `→` into it, `a`, type `file.ts` |
| Find a file you half remember | `z`, type part of the name, `Enter` |
| Find where some text is used | `S`, type the text, `Enter`, then `Enter` on a result |
| Jump your shell to a deep folder | `y`, navigate there, `q` |

## 8. Working with Claude Code

### The status line

The coloured bar at the bottom of Claude Code reads left to right:

| Segment | Meaning |
|---|---|
| Purple | The model in use |
| Orange | The folder Claude is working in |
| Yellow | The git branch |
| Green | How full the context window is, as a percentage |
| Blue | What the session has cost so far |

Watch the green number. As it climbs towards 100% the conversation gets summarised to make room, so a long task is better split before that point.

### Subagent rows

When Claude starts subagents they appear as rows under the prompt:

| Part | Meaning |
|---|---|
| Spinner, tick, cross or stop icon | Running, completed, failed or stopped |
| Purple label | The agent's name or type |
| Text | What it is doing right now |
| Grey text | Which model it runs on |
| Token count and percentage | How full that agent's own context is: green, yellow from 50%, red from 80% |
| Small bar chart | How fast its context has been growing |
| Clock | How long it has been running |

### Commands and keys

| Command or key | What it does |
|---|---|
| `/context` | Breakdown of what is filling the context window |
| `/usage` | Session cost and plan limits |
| `/tasks` | List subagents and background work; `Enter` opens one, `x` stops it |
| `/theme` | Change Claude Code's colours |
| `Ctrl+B` | Send the running command or agent to the background |
| `Ctrl+O` | Open the detailed transcript |
| `Ctrl+X Ctrl+K` | Stop all background subagents |
| `@agent-name` | Address a named background subagent in your message |

## 9. Reading the prompt

The prompt is two lines. The first is a row of coloured segments, the second is where you type.

| Segment | Meaning |
|---|---|
| Red | Your user name |
| Orange | The current folder |
| Yellow | Git branch, followed by status marks |
| Green | Language version for the project you are in (Node, Bun, Go and so on) |
| Purple | The time |
| `❯` | Green after a command that succeeded, red after one that failed |

Git status marks: `?` untracked files, `!` modified, `+` staged, `✘` deleted, `$` stashed, `⇡` commits to push, `⇣` commits to pull, `=` conflicts.

**A red `RAM 80%` on the right** means memory is running low. This machine crashes when it runs out, so stop starting heavy jobs, run `btop`, and close what you do not need. Below 75% the warning is hidden.

## 10. Keeping the setup healthy

| Command | What it does |
|---|---|
| `update-tools` | Updates every tool in this guide to its latest release. Run it every month or so |
| `dotsave "what changed"` | Saves the whole configuration, including the Windows Terminal settings, to the `~/dotfiles` git repository |
| `btop` | Shows what is using CPU and memory; `q` quits |
| `fnm install 22` | Installs a Node version; `fnm default 22` makes it the default |
| `fnm list` | Shows installed Node versions |

**Rebuilding on a new machine:** clone the `dotfiles` repository and run `./install.sh`. It links the configuration into place and installs the tools. The Nerd Font on Windows has to be installed by hand.

### Where the settings live

All of these are links into `~/dotfiles`, so editing either path edits the same file.

| File | What it controls |
|---|---|
| `~/.zshrc` | Shell setup, aliases and the `work`, `ff` and `y` commands |
| `~/.config/starship.toml` | The prompt and the RAM warning |
| `~/.config/yazi/` | File explorer theme and git markers |
| `~/.config/lazygit/config.yml` | lazygit theme and diff style |
| `~/.config/hunk/config.toml` | Diff viewer theme |
| `~/.config/micro/` | Editor settings and theme |
| `~/.config/btop/` | Task manager theme |
| `~/.claude/statusline.sh` | Claude Code status line |
| `~/.claude/subagent-statusline.sh` | Claude Code subagent rows |

## 11. If something looks wrong

| What you see | What to do |
|---|---|
| Boxes or question marks instead of icons | Windows Terminal is not using "JetBrainsMono Nerd Font". Check Settings, Defaults, Appearance, Font face |
| `command not found` for something in this guide | The tab is older than the change. Run `exec zsh` |
| `node` or `npm` not found in an old tab | Same cause. Run `exec zsh` |
| `hd` says there is nothing to show | There are no uncommitted changes. Use `hs` for the last commit |
| `hd` or `lg` complains about a repository | You are not inside a git project. `cd` into one first |
| `work` opens the wrong kind of tab | The profile ID in the `work` function of `~/.zshrc` no longer matches Windows Terminal |
| The prompt takes a moment in a huge repository | That is git checking status. It is normal on the first prompt after entering |
| A tool misbehaves after `update-tools` | Run `update-tools` again; if it reports a failure, the message names the tool |

## 12. Quick reference

### Commands

| Command | What it does |
|---|---|
| `work [project]` | Open the three-pane layout: Claude, live diff, shell |
| `hd` / `hs` | Live diff of uncommitted changes / diff of the last commit |
| `lg` | Stage, commit, push, branches |
| `y` | File explorer |
| `ff words` | Search text across the project |
| `z name` / `zi` | Jump to a visited folder / pick one from a list |
| `ls` `ll` `la` `lt` | List files: plain, detailed, with hidden, as a tree |
| `cat file` | Show a file with colours |
| `micro file` | Edit a file |
| `glow file.md` | Read Markdown |
| `git diff` | Quick coloured diff |
| `gh pr diff 123` | Review a pull request |
| `btop` | Task manager |
| `tldr command` | Examples for a command |
| `update-tools` | Update everything |
| `dotsave "note"` | Back up the configuration |

### Keys

| Where | Key | What it does |
|---|---|---|
| Shell | `Ctrl-R` | Search history |
| Shell | `Ctrl-T` | Pick a file |
| Shell | `Alt-C` | Jump to a subfolder |
| Shell | `Tab` | Completion menu with previews |
| Shell | `→` | Accept the grey suggestion |
| Terminal | `Alt+arrow` | Move between panes |
| Terminal | `Alt+Shift++` / `Alt+Shift+-` | Split right / split down |
| Terminal | `Ctrl+Shift+W` | Close the pane |
| micro | `Ctrl-S` / `Ctrl-Q` | Save / close |
| lazygit | `Space`, `c`, `P` | Stage, commit, push |
| yazi | `Enter`, `←`, `q` | Open, go up, quit |
| Claude Code | `/context`, `/tasks` | Context breakdown, subagents |
| Most tools | `q` | Quit |
