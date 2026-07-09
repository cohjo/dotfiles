#!/usr/bin/env sh
set -eu

if ! command -v brew >/dev/null 2>&1; then
  printf '%s\n' "Homebrew is required for native tools."
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  printf '%s\n' "npm is required for Node-based language servers."
  exit 1
fi

brew install \
  lua-language-server \
  marksman \
  taplo \
  gopls \
  stylua \
  shfmt \
  ruff

npm install -g \
  typescript \
  typescript-language-server \
  bash-language-server \
  vscode-langservers-extracted \
  yaml-language-server \
  pyright \
  prettier \
  @fsouza/prettierd

printf '%s\n' "Done. In Neovim, run :MobileLspMissing, :checkhealth vim.lsp, and :ConformInfo."
