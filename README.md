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

With Homebrew installed, this installs the system runtimes from `Brewfile`,
backs up an existing Neovim config, links this repo's config, restores locked
plugin revisions, and installs all declared Mason tools and Treesitter parsers.
On macOS, install Apple's command line tools first (`xcode-select --install`).

On Linux, install the prerequisites listed in [nvim/README.md](nvim/README.md)
with your package manager, then run `make nvim`. You can also use `make nvim`
on a Mac whose runtimes are already installed. The command is safe to rerun;
it exits with a failure if tool installation fails.

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

- `make setup` / `make tools`: install Homebrew prerequisites and bootstrap Neovim.
- `make nvim`: link and bootstrap Neovim using already-installed runtimes.
- `make link`: link Neovim, Helix and tmux configs without installing tools.
- `make doctor`: print Neovim version and active config path.
- Inside Neovim: `:Mason`, `:MasonToolsInstall`, `:ConformInfo`, `:checkhealth vim.lsp`.

Leader is Space: `Space f` finds files, `Space b` switches buffers, `Space /`
searches the project, `Space ca` opens code actions, `Space rn` renames,
`Space lf` formats, and `Space tf` toggles format on save for the buffer.

The on-demand code explorer adds `Space ci/co` for callers/callees, `Space ct/cT`
for parent/child types, `Space s` for symbols, and `Space j/k` for history.
`Space ?` searches normal-mode shortcut descriptions; `Space H` searches all modes.

## Helix Alternative

Helix is likely the better pure mobile editor if you are willing to learn its
selection-first modal model. It has built-in language support, tree-sitter
integration, LSP integration, pickers, and formatting configuration with far
less plugin machinery.

Install:

```sh
brew install helix
```

Symlink the included config:

```sh
mkdir -p ~/.config
ln -s /Users/conorjohnston/github/dotfiles/helix ~/.config/helix
```

Check language tooling:

```sh
hx --health
```

## Tmux Pairing

Use either editor inside tmux:

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
