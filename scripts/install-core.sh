#!/usr/bin/env sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$repo_dir/scripts/dev-env.sh"
if command -v brew >/dev/null 2>&1; then
  HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --no-upgrade --file="$repo_dir/Brewfile"
elif [ "$(uname -s)" = Linux ] && command -v apt-get >/dev/null 2>&1; then
  if [ "$(id -u)" -eq 0 ]; then elevate=''; else elevate='sudo'; fi
  $elevate apt-get update
  $elevate apt-get install -y build-essential curl ca-certificates git ripgrep fd-find jq fzf tmux zsh python3 unzip xz-utils
  mkdir -p "$HOME/.local/bin"
  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
  # Download to a temporary file so network errors cannot silently run partial scripts.
  stage=$(mktemp -d)
  trap 'rm -rf "$stage"' EXIT HUP INT TERM
  if ! command -v mise >/dev/null 2>&1; then
    curl -fsSL https://mise.run -o "$stage/mise.sh"
    MISE_INSTALL_PATH="$HOME/.local/bin/mise" sh "$stage/mise.sh"
  fi
  if ! command -v uv >/dev/null 2>&1; then
    curl -fsSL https://astral.sh/uv/install.sh -o "$stage/uv.sh"
    UV_NO_MODIFY_PATH=1 sh "$stage/uv.sh"
  fi
  # GitHub CLI's official apt repository, scoped signing key.
  if ! command -v gh >/dev/null 2>&1; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o "$stage/githubcli.gpg"
    $elevate install -m 0644 "$stage/githubcli.gpg" /usr/share/keyrings/githubcli-archive-keyring.gpg
    printf 'deb [arch=%s signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\n' "$(dpkg --print-architecture)" > "$stage/github-cli.list"
    $elevate install -m 0644 "$stage/github-cli.list" /etc/apt/sources.list.d/github-cli.list
    $elevate apt-get update
    $elevate apt-get install -y gh
  fi
else
  printf '%s\n' 'Automatic core installation supports Homebrew and Debian/Ubuntu apt.' >&2
  printf '%s\n' 'Install mise, uv, git, rg, fd, jq, fzf, tmux, gh, zsh, python3, curl, a C compiler, unzip and xz with your package manager, then run make configure.' >&2
  exit 1
fi
