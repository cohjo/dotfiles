# CLI Editor Dotfiles

Lightweight Neovim with Vim bindings, Tokyo Night, Mason-managed full-stack
language support, completion, formatting, fuzzy pickers and Git signs.
The setup also works in SSH/tmux sessions.

## Fresh machine

Clone this repository anywhere, then run from its root:

```sh
git clone https://github.com/cohjo/dotfiles.git
cd dotfiles
make setup
```

`make setup` now prepares the shell, core CLI tools, managed language runtimes,
and Neovim—not just the editor. It supports Homebrew and Debian/Ubuntu apt.
On macOS, install Homebrew and Apple's command line tools first.

```sh
make setup PROFILE=containers       # Colima + Docker CLI on macOS
make setup PROFILE=data             # optional Miniforge/Conda
make setup PROFILE=containers,data  # combine profiles
make doctor PROFILE=containers
```

Core defaults use **uv for Python**, **mise for Node/Go/Java/Neovim**, a lean Zsh
configuration, Git defaults and tmux. Existing configs are backed up, and local
credentials/aliases are retained outside Git. Container VMs are started explicitly,
not on shell startup. See [development setup and recovery](docs/development.md)
for requirements, profiles, version policy and machine-specific overrides.

## Fonts and iPhone editing

This private repository includes the owner's four licensed Berkeley Mono faces.
`make setup` installs them; `make fonts` installs/rechecks them separately. Keep the
repository private. In Rex choose **Settings → Terminal → Typography → Berkeley
Mono** once: terminal Neovim and the shell inherit the client's font. Neovim also
sets Berkeley Mono for GUI frontends, and does not require a Nerd Font. See
[font setup](fonts/README.md).

Run **`nvimm`** on the host for phone-friendly editing with the same tools and keys:
wrapped lines, narrow-screen pickers, quiet diagnostics and manual completion.
Desktop `nvim` stays as before. See [iPhone workflow and key bar](docs/mobile.md).

## Toolchain

[nvim/lua/toolchain.lua](nvim/lua/toolchain.lua) declares all language servers,
linters, formatters and parsers. Mason installs missing tools on normal startup
as well. You do not need to install language servers globally with npm or brew.
`nvim/lazy-lock.json` records plugin revisions; Mason installs available tool
versions on a new machine, and does not automatically upgrade existing tools.
Project dependency versions and CI lint/typecheck commands belong in each project.

| Area | Tools |
| --- | --- |
| TypeScript, JavaScript, React | TypeScript language server, Oxlint, Prettier |
| Python | ty, Ruff linting and formatting |
| Java | jdtls |
| HTML, CSS, SCSS, Less | VS Code HTML/CSS language servers, Prettier |
| JSON/JSONC, YAML | JSON/YAML language servers, SchemaStore, Prettier |
| SQL | sqls, manual sql-formatter |
| Shell | Bash language server, ShellCheck, shfmt |
| Docker / Compose | Dockerfile and Compose language servers |
| TOML, Markdown, Lua | Taplo, Marksman, Lua language server; StyLua/Prettier |

See [Neovim usage and project configuration](nvim/README.md) for keys, SQL
connections/dialects, Java runtime selection, and adding languages.

## Commands

- `make setup` / `make tools`: bootstrap the development environment (`PROFILE=...` optional).
- `make nvim`: link and bootstrap Neovim using already-installed runtimes.
- `make configure`: configure existing system tools, runtimes, shell and editor.
- `make link`: link configurations without installing tools.
- `make doctor`: check tools, runtime versions, links and Neovim packages.
- Inside Neovim: `:Mason`, `:MasonToolsInstall`, `:ConformInfo`, `:checkhealth vim.lsp`.

Leader is Space: `Space f` finds files, `Space b` switches buffers, `Space /`
searches the project, `Space ca` opens code actions, `Space rn` renames,
`Space lf` formats, and `Space tf` toggles format on save for the buffer.

The on-demand code explorer adds `Space ci/co` for callers/callees, `Space ct/cT`
for parent/child types, `Space s` for symbols, and `Space j/k` for history.
`Space ?` searches normal-mode shortcut descriptions; `Space H` searches all modes.

## Tmux Pairing

Use Neovim inside tmux:

```sh
tmux attach -d -t agents || tmux new -s agents
```

Phone disconnects then stop mattering. Reconnect with SSH, reattach tmux, and
your editor session is still there.

This repo also includes a mobile-friendly tmux config at `tmux/tmux.conf`.
Install all editor links with:

```sh
cd ~/github/dotfiles
make link
```

The tmux config enables mouse mode, so Termius can scroll tmux history with a
normal swipe without manually entering copy mode. It also keeps the status line
short and adds easy window navigation:

```text
Alt-h      previous window
Alt-l      next window
Alt-Left   previous window
Alt-Right  next window
Ctrl-b r   reload tmux config
Ctrl-b |   split horizontally
Ctrl-b -   split vertically
```

If mobile text selection gets awkward, temporarily toggle mouse mode:

```sh
tmux set -g mouse off
tmux set -g mouse on
```
