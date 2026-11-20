#!/usr/bin/env python3
"""Install any local .otf/.ttf font files under fonts/ into the user's font directory."""
from pathlib import Path
import datetime
import hashlib
import os
import shutil
import subprocess
import sys

repo = Path(__file__).resolve().parent.parent
source = repo / 'fonts'
files = sorted(
    p for p in source.rglob('*')
    if p.is_file() and p.suffix.lower() in {'.otf', '.ttf'}
) if source.is_dir() else []
if not files:
    print(f'Fonts: skipped (no local .otf/.ttf files in {source}; see fonts/README.md).')
    raise SystemExit(0)
if sys.platform == 'darwin':
    destination = Path.home() / 'Library/Fonts'
elif sys.platform.startswith('linux'):
    destination = Path(os.environ.get('XDG_DATA_HOME', Path.home() / '.local/share')) / 'fonts'
else:
    raise SystemExit('Automatic font installation supports macOS and Linux.')
destination.mkdir(parents=True, exist_ok=True)
changed = 0
for file in files:
    digest = hashlib.sha256(file.read_bytes()).hexdigest()
    target = destination / file.name
    if target.exists() and hashlib.sha256(target.read_bytes()).hexdigest() == digest:
        continue
    if target.exists():
        stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
        shutil.copy2(target, target.with_name(target.name + f'.backup-{stamp}-{os.getpid()}'))
    shutil.copy2(file, target)
    changed += 1
if sys.platform.startswith('linux') and changed and shutil.which('fc-cache'):
    subprocess.run(['fc-cache', '-f', str(destination)], check=True)
print(f'Fonts: {len(files)} face(s) available in {destination} ({changed} installed/updated).')
