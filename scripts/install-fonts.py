#!/usr/bin/env python3
"""Install the licensed font files unchanged in the current user's font directory."""
from pathlib import Path
import datetime
import hashlib
import json
import os
import shutil
import subprocess
import sys

repo = Path(__file__).resolve().parent.parent
source = repo / 'fonts/berkeley-mono'
manifest = json.loads((source / 'manifest.json').read_text())
if sys.platform == 'darwin':
    destination = Path.home() / 'Library/Fonts'
elif sys.platform.startswith('linux'):
    destination = Path(os.environ.get('XDG_DATA_HOME', Path.home() / '.local/share')) / 'fonts/BerkeleyMono'
else:
    raise SystemExit('Automatic font installation supports macOS and Linux.')
# Verify every source before modifying any installed files.
for entry in manifest['fonts']:
    file = source / entry['file']
    if file.parent != source or hashlib.sha256(file.read_bytes()).hexdigest() != entry['sha256']:
        raise SystemExit('Font checksum failed: ' + entry['file'])
destination.mkdir(parents=True, exist_ok=True)
changed = 0
for entry in manifest['fonts']:
    target = destination / entry['file']
    if target.exists() and hashlib.sha256(target.read_bytes()).hexdigest() == entry['sha256']:
        continue
    if target.exists():
        stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
        shutil.copy2(target, target.with_name(target.name + f'.backup-{stamp}-{os.getpid()}'))
    shutil.copy2(source / entry['file'], target)
    changed += 1
if sys.platform.startswith('linux') and changed and shutil.which('fc-cache'):
    subprocess.run(['fc-cache', '-f', str(destination)], check=True)
print(f'Berkeley Mono: 4 faces available in {destination} ({changed} installed/updated).')
