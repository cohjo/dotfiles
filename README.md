# Mobile-Friendly CLI Editor Dotfiles

This is a small terminal editor setup for SSHing into a MacBook from an iPhone.
It favors predictable rendering, low visual noise, and tools that survive small
screens better than full Neovim distributions.

## Recommendation

Use this order:

1. Neovim custom config if you already have Vim muscle memory.
2. Helix if you want the most mobile-friendly editor with the fewest plugins.
3. LazyVim only on desktop or tablet-sized terminals.

LazyVim is excellent, but on a phone it brings too many always-visible UI
surfaces. A mobile editor should prefer command palettes, fuzzy finders, and
pull-based diagnostics over sidebars, dashboards, tablines, breadcrumbs, and
large completion docs.

## Minimal Neovim Stack

This setup uses only four plugin entries:

- `nvim-mini/mini.nvim`: statusline, picker, comments, pairs, surround, textobjects.
- `neovim/nvim-lspconfig`: server configs for Neovim's built-in LSP client.
- `saghen/blink.cmp`: fast completion with LSP, path, and buffer sources.
- `stevearc/conform.nvim`: format-on-save and manual formatting.

It deliberately does not include:

- a file tree
- tabs/buffers UI
- dashboard
- breadcrumb/nav bar
- notification framework
- Mason tool installer
- Treesitter by default

Language servers and formatters should be installed as normal CLI tools on the
Mac. That keeps Neovim simple and makes the same tools usable from shell,
Helix, Codex, and scripts.

## Install Neovim Config

Back up your existing config first:

```sh
mv ~/.config/nvim ~/.config/nvim.lazyvim.backup
```

Symlink this config:

```sh
ln -s /Users/conorjohnston/github/dotfiles/nvim ~/.config/nvim
```

Start Neovim:

```sh
nvim
```

The first launch bootstraps `lazy.nvim` and installs plugins.

## Install Useful Language Tools

Pick only what you use:

```sh
brew install lua-language-server stylua
brew install pyright ruff
brew install marksman taplo shfmt
brew install go gopls
brew install rust-analyzer
npm install -g typescript typescript-language-server prettier @fsouza/prettierd
npm install -g bash-language-server vscode-langservers-extracted yaml-language-server
```

Inside Neovim:

```vim
:MobileLspMissing
:checkhealth vim.lsp
:ConformInfo
```

## Mobile Keybindings

Leader is Space.

```text
Space ff   find files
Space fg   live grep
Space fb   buffers
Space dd   diagnostic under cursor
Space dn   next diagnostic
Space dp   previous diagnostic
Space la   code action
Space lr   rename
Space lf   format
Space w    write
Space q    quit
```

Termius quick keys worth adding:

```text
Esc
Ctrl
Tab
Space
:
/
-
_
"
'
|
```

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
