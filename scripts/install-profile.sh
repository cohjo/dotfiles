#!/usr/bin/env sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$repo_dir/scripts/dev-env.sh"
case "${1:-}" in
  containers)
    if [ "$(uname -s)" = Darwin ]; then
      command -v brew >/dev/null 2>&1 || { printf '%s\n' 'Install Homebrew first.' >&2; exit 1; }
      HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --no-upgrade --file="$repo_dir/profiles/containers.Brewfile"
      # Discover plugins without rewriting Docker config (which may contain credentials).
      plugin_dir="${DOCKER_CONFIG:-$HOME/.docker}/cli-plugins"
      mkdir -p "$plugin_dir"
      prefix=$(brew --prefix)
      for plugin in docker-compose docker-buildx; do
        target="$prefix/lib/docker/cli-plugins/$plugin"
        if [ ! -x "$target" ]; then target="$prefix/bin/$plugin"; fi
        if [ ! -x "$target" ]; then printf 'Missing plugin: %s\n' "$plugin" >&2; exit 1; fi
        if [ -e "$plugin_dir/$plugin" ] || [ -L "$plugin_dir/$plugin" ]; then
          if [ "$(readlink "$plugin_dir/$plugin" 2>/dev/null || true)" = "$target" ]; then continue; fi
          mv "$plugin_dir/$plugin" "$plugin_dir/$plugin.backup-$(date +%Y%m%d-%H%M%S)-$$"
        fi
        ln -s "$target" "$plugin_dir/$plugin"
      done
      printf '%s\n' 'Colima installed; VM remains stopped. Use make containers-start to start it.'
    elif [ "$(uname -s)" = Linux ] && command -v apt-get >/dev/null 2>&1; then
      if [ "$(id -u)" -eq 0 ]; then elevate=''; else elevate='sudo'; fi
      $elevate apt-get update
      $elevate apt-get install -y docker.io
      # Ubuntu/Debian package names vary. Never install Docker Desktop.
      if apt-cache show docker-compose-v2 >/dev/null 2>&1; then
        $elevate apt-get install -y docker-compose-v2
      elif apt-cache show docker-compose >/dev/null 2>&1; then
        $elevate apt-get install -y docker-compose
      fi
      printf '%s\n' 'Native Docker Engine installed. Configure daemon access per your host policy (or use sudo docker). No user groups or service settings were changed.'
    else
      printf '%s\n' 'Use native Docker Engine on this Linux distribution; automatic installation supports Debian/Ubuntu.' >&2
      exit 1
    fi
    ;;
  data)
    if [ -x "$HOME/miniforge3/bin/conda" ] || [ -x "$HOME/miniconda3/bin/conda" ]; then
      printf '%s\n' 'Existing Conda installation retained.'
      exit 0
    fi
    case "$(uname -s)-$(uname -m)" in
      Darwin-arm64) asset=Miniforge3-MacOSX-arm64.sh ;;
      Darwin-x86_64) asset=Miniforge3-MacOSX-x86_64.sh ;;
      Linux-x86_64) asset=Miniforge3-Linux-x86_64.sh ;;
      Linux-aarch64|Linux-arm64) asset=Miniforge3-Linux-aarch64.sh ;;
      *) printf '%s\n' 'Unsupported Miniforge platform.' >&2; exit 1 ;;
    esac
    stage=$(mktemp -d)
    trap 'rm -rf "$stage"' EXIT HUP INT TERM
    url="https://github.com/conda-forge/miniforge/releases/latest/download/$asset"
    curl -fsSL "$url" -o "$stage/$asset"
    curl -fsSL "$url.sha256" -o "$stage/checksum"
    python3 - "$stage/$asset" "$stage/checksum" <<'PY'
import hashlib, pathlib, sys
if hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest() != pathlib.Path(sys.argv[2]).read_text().split()[0]:
    raise SystemExit('Miniforge checksum mismatch')
PY
    bash "$stage/$asset" -b -p "$HOME/miniforge3"
    "$HOME/miniforge3/bin/conda" config --set auto_activate_base false
    printf '%s\n' 'Miniforge installed. Run conda activate <environment> when needed.'
    ;;
  cloud)
    if command -v brew >/dev/null 2>&1; then
      HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --no-upgrade --file="$repo_dir/profiles/cloud.Brewfile"
    else
      # Install user-local CLIs with mise, preserving the core global manifest.
      MISE_YES=1 mise install awscli@2 kubectl@1
      mise reshim
      mkdir -p "$HOME/.local/bin"
      for tool in aws kubectl; do
        case "$tool" in aws) spec=awscli@2 ;; kubectl) spec=kubectl@1 ;; esac
        wrapper="$HOME/.local/bin/$tool"
        if [ -e "$wrapper" ] && ! grep -q 'dotfiles-managed-cloud-wrapper' "$wrapper"; then
          mv "$wrapper" "$wrapper.backup-$(date +%Y%m%d-%H%M%S)-$$"
        fi
        printf '#!/bin/sh\n# dotfiles-managed-cloud-wrapper\nexec mise exec %s -- %s "$@"\n' "$spec" "$tool" > "$wrapper"
        chmod +x "$wrapper"
      done
    fi
    printf '%s\n' 'Cloud CLIs installed. Authenticate separately with your own accounts.'
    ;;
  *) printf '%s\n' 'Usage: install-profile.sh containers|data|cloud' >&2; exit 1 ;;
esac
