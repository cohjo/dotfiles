#!/usr/bin/env sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
dotfiles="${DOTFILES:-$repo_dir}"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

mkdir -p "$config_home"

backup_if_needed() {
  target="$1"
  if [ -L "$target" ]; then
    rm "$target"
    return
  fi

  if [ -e "$target" ]; then
    stamp="$(date +%Y%m%d-%H%M%S)"
    mv "$target" "$target.backup-$stamp"
  fi
}

backup_if_needed "$config_home/nvim"
ln -s "$dotfiles/nvim" "$config_home/nvim"

backup_if_needed "$HOME/.tmux.conf"
ln -s "$dotfiles/tmux/tmux.conf" "$HOME/.tmux.conf"

printf '%s\n' "Linked:"
printf '  %s -> %s\n' "$config_home/nvim" "$dotfiles/nvim"
printf '  %s -> %s\n' "$HOME/.tmux.conf" "$dotfiles/tmux/tmux.conf"
