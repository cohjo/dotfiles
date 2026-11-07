#!/usr/bin/env sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

for command in nvim git rg node npm python3 go java cc curl unzip tar gzip; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Missing prerequisite: %s. See nvim/README.md.\n' "$command" >&2
    exit 1
  fi
done
nvim --clean --headless '+lua if vim.fn.has("nvim-0.11.3") == 0 then vim.cmd("cquit") end' +qa
mkdir -p "$config_home"
if [ -L "$config_home/nvim" ] && [ "$(readlink "$config_home/nvim")" = "$repo_dir/nvim" ]; then
  :
elif [ -e "$config_home/nvim" ] || [ -L "$config_home/nvim" ]; then
  backup="$config_home/nvim.backup-$(date +%Y%m%d-%H%M%S)-$$"
  mv "$config_home/nvim" "$backup"
  printf 'Previous config saved to %s\n' "$backup"
  ln -s "$repo_dir/nvim" "$config_home/nvim"
else
  ln -s "$repo_dir/nvim" "$config_home/nvim"
fi
export DOTFILES_BOOTSTRAP=1
# Restore the checked-in plugin revisions rather than upgrading on a new machine.
nvim --headless '+Lazy! restore' +qa
export DOTFILES_NVIM_BOOTSTRAP="$repo_dir/scripts/bootstrap-nvim.lua"
nvim --headless '+lua local ok, err = pcall(dofile, vim.env.DOTFILES_NVIM_BOOTSTRAP); if not ok then vim.api.nvim_err_writeln(tostring(err)); vim.cmd("cquit") end'
