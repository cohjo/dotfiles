#!/usr/bin/env sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
profiles=$(printf '%s' "${1:-core}" | tr ',' ' ')
for profile in $profiles; do
  case "$profile" in core|containers|data|cloud) ;; *) printf 'Unknown profile: %s\n' "$profile" >&2; exit 1 ;; esac
done
"$repo_dir/scripts/install-core.sh"
"$repo_dir/scripts/configure-dev.sh"
for profile in $profiles; do
  if [ "$profile" != core ]; then "$repo_dir/scripts/install-profile.sh" "$profile"; fi
done
printf '%s\n' 'Development environment configured. Open a new terminal, then run make doctor.'
