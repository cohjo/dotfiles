#!/usr/bin/env sh
set -u
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$repo_dir/scripts/dev-env.sh"
failed=0
for tool in git rg fd jq fzf tmux gh zsh mise uv python3 node npm go java nvim cc curl unzip; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'OK    %-9s %s\n' "$tool" "$(command -v "$tool")"
  else
    printf 'FAIL  %s missing\n' "$tool"
    failed=1
  fi
done
if command -v mise >/dev/null 2>&1; then
  (cd "$HOME" && mise ls --installed)
fi
if command -v python3 >/dev/null 2>&1; then
  python3 - "$repo_dir" <<'PY'
from pathlib import Path
import sys
repo = Path(sys.argv[1])
for name in ['zshenv', 'zprofile', 'zshrc']:
    target = Path.home() / f'.{name}'
    ok = target.is_symlink() and target.resolve() == repo / 'shell' / name
    print(('OK    ' if ok else 'FAIL  ') + f'.{name} linked')
    if not ok: sys.exit(1)
PY
  [ "$?" -eq 0 ] || failed=1
fi
if command -v nvim >/dev/null 2>&1; then
  DOTFILES_BOOTSTRAP=1 nvim --headless '+lua local missing = {}; for _, name in ipairs(require("toolchain").packages()) do if vim.fn.filereadable(vim.fn.stdpath("data") .. "/mason/packages/" .. name .. "/mason-receipt.json") == 0 then table.insert(missing, name) end end; if #missing > 0 then print("Missing Mason tools: " .. table.concat(missing, ", ")); vim.cmd("cquit") else print("OK    Neovim toolchain installed") end' +qa || failed=1
fi
for profile in $(printf '%s' "${1:-core}" | tr ',' ' '); do
  case "$profile" in
    containers)
      for tool in docker; do
        command -v "$tool" >/dev/null 2>&1 || { printf 'FAIL  %s missing\n' "$tool"; failed=1; }
      done
      if [ "$(uname -s)" = Darwin ]; then
        if command -v colima >/dev/null 2>&1; then
          colima status 2>/dev/null || printf '%s\n' 'INFO  Colima stopped; start explicitly with make containers-start.'
        else printf '%s\n' 'FAIL  Colima missing'; failed=1; fi
      fi
      docker compose version 2>/dev/null || docker-compose version 2>/dev/null || { printf '%s\n' 'FAIL  Compose missing'; failed=1; }
      if [ "$(uname -s)" = Darwin ]; then docker buildx version || failed=1; fi
      ;;
    data) [ -x "$HOME/miniforge3/bin/conda" ] || [ -x "$HOME/miniconda3/bin/conda" ] || { printf '%s\n' 'FAIL  Conda missing'; failed=1; } ;;
    cloud) for tool in aws kubectl; do command -v "$tool" >/dev/null 2>&1 || { printf 'FAIL  %s missing\n' "$tool"; failed=1; }; done ;;
    core) ;;
    *) printf 'FAIL  Unknown profile: %s\n' "$profile"; failed=1 ;;
  esac
done
if ! git config --get user.name >/dev/null 2>&1 || ! git config --get user.email >/dev/null 2>&1; then
  printf '%s\n' 'INFO  Set your local Git user.name/user.email before committing.'
fi
printf '%s\n' 'Authentication stays local: use gh auth login / your cloud provider login as needed.'
exit "$failed"
