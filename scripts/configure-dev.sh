#!/usr/bin/env sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$repo_dir/scripts/dev-env.sh"
for tool in python3 git mise uv; do
  command -v "$tool" >/dev/null 2>&1 || { printf 'Missing %s; run make setup first.\n' "$tool" >&2; exit 1; }
done
python3 "$repo_dir/scripts/link-dev.py"
python3 "$repo_dir/scripts/install-fonts.py"
# Explicit trusted global config; no reliance on a caller's project configuration.
cd "$HOME"
export MISE_GLOBAL_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml"
MISE_YES=1 mise trust "$MISE_GLOBAL_CONFIG_FILE"
MISE_YES=1 mise install
mise reshim
uv python install --default 3.13
# Keep the Java editor server on a recent JDK even inside older-Java projects.
python3 - "$(mise where java)" <<'PYCODE'
from pathlib import Path
import os, shlex, sys
config = Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config'))
p = config / 'zsh/runtime.env.zsh'
p.parent.mkdir(parents=True, exist_ok=True)
p.write_text('export JDTLS_JAVA_HOME=' + shlex.quote(sys.argv[1]) + '\n')
PYCODE
# Run bootstrap within the managed environment, including non-interactive agents.
mise exec -- "$repo_dir/scripts/setup-nvim.sh"
# Link tmux as well; the editor linker backs up existing files.
"$repo_dir/scripts/link-editors.sh"
