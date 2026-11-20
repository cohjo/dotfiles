#!/usr/bin/env sh
# Source from setup/doctor, not interactive shell startup.
if [ -d /opt/homebrew/bin ]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi
if [ -d /home/linuxbrew/.linuxbrew/bin ]; then
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
fi
export PATH="$HOME/.local/bin:${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims:$PATH"
if [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/mise/installs/neovim/latest/bin" ]; then
  export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/mise/installs/neovim/latest/bin:$PATH"
fi
