#!/usr/bin/env sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if command -v brew >/dev/null 2>&1; then
  brew bundle --file="$repo_dir/Brewfile"
else
  printf '%s\n' 'Install Neovim 0.11.3+, Git, ripgrep, Node.js/npm, Python 3, Go, a current JDK, a C compiler, curl, unzip, tar and gzip using your system package manager.'
  printf '%s\n' 'Then run make nvim. See nvim/README.md for details.'
  exit 1
fi
"$repo_dir/scripts/setup-nvim.sh"
