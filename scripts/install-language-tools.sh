#!/usr/bin/env sh
# Backward-compatible entry point for the original Neovim-only bootstrap.
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
exec "$repo_dir/scripts/setup-dev.sh" "${PROFILE:-core}"
