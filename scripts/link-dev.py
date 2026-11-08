#!/usr/bin/env python3
"""Back up config files, retain local environment/aliases, and link shared defaults."""
from pathlib import Path
import datetime
import os
import re
import shutil
import shlex
import subprocess

repo = Path(__file__).resolve().parent.parent
home = Path.home()
config = Path(os.environ.get('XDG_CONFIG_HOME', home / '.config'))
backup = config / 'dotfiles-backups' / (datetime.datetime.now().strftime('%Y%m%d-%H%M%S') + f'-{os.getpid()}')

def save(path):
    backup.mkdir(parents=True, exist_ok=True, mode=0o700)
    destination = backup / path.name
    if path.is_symlink():
        # Copy contents so a later repo edit cannot change the backup.
        if path.exists(): shutil.copy2(path, destination)
        else: destination.write_text(f'Previous symlink target: {os.readlink(path)}\n')
        path.unlink()
    else:
        shutil.move(str(path), str(destination))
    destination.chmod(0o600)

def link(source, target):
    if target.is_symlink() and target.resolve() == source.resolve(): return
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists() or target.is_symlink(): save(target)
    target.symlink_to(source)

# Migrate simple exports/aliases only, never old shell frameworks/version managers.
# Preserve original complete files in the private backup for any custom functions.
managed = (home / '.zshrc').is_symlink() and (home / '.zshrc').resolve() == repo / 'shell/zshrc'
if not managed:
    local_dir = config / 'zsh'
    local_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
    exports, aliases = [], []
    old_env = home / '.zshenv'
    if old_env.exists() and old_env.resolve() != repo / 'shell/zshenv': exports.append(old_env.read_text())
    for file in [home / '.zprofile', home / '.zshrc']:
        if not file.exists() or file.resolve() in {repo / 'shell/zprofile', repo / 'shell/zshrc'}: continue
        for line in file.read_text().splitlines():
            # Multiline/dynamic constructs stay in the backup for manual migration.
            try:
                tokens = shlex.split(line)
            except ValueError:
                continue
            if '$(' in line or '`' in line or line.rstrip().endswith('\\'):
                continue
            m = re.match(r'^export\s+([A-Za-z_][A-Za-z_0-9]*)=', line)
            if m and m[1] not in {'ZSH', 'ZSH_THEME', 'PYENV_ROOT', 'NVM_DIR', 'CONDA_PREFIX', 'CONDA_DEFAULT_ENV', 'CONDA_SHLVL', 'CONDA_EXE', 'CONDA_PYTHON_EXE', 'VIRTUAL_ENV', 'PYENV_VERSION', 'JAVA_HOME', 'GOROOT'}:
                if not any(x in line for x in ('PYENV_ROOT', 'NVM_DIR', '/miniconda3/bin', '/miniforge3/bin')):
                    exports.append(line)
            if re.match(r'^alias\s+[A-Za-z_][A-Za-z_0-9]*=', line): aliases.append(line)
    for name, lines in [('env.local.zsh', exports), ('local.zsh', aliases)]:
        target = local_dir / name
        if lines and not target.exists():
            fd = os.open(target, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
            with os.fdopen(fd, 'w') as stream:
                stream.write('# Private machine settings migrated from the previous shell.\n' + '\n'.join(lines) + '\n')
            print(f'Preserved machine settings in {target} (contents not printed)')
for name in ['zshenv', 'zprofile', 'zshrc']:
    link(repo / 'shell' / name, home / f'.{name}')
link(repo / 'mise/config.toml', config / 'mise/config.toml')
link(repo / 'uv/uv.toml', config / 'uv/uv.toml')
# Keep identity, credentials, signing and existing config; append a defaults include once.
includes = subprocess.run(['git', 'config', '--global', '--get-all', 'include.path'], capture_output=True, text=True).stdout.splitlines()
include = str(repo / 'git/config')
if include not in includes:
    gitconfig = home / '.gitconfig'
    if gitconfig.exists():
        backup.mkdir(parents=True, exist_ok=True, mode=0o700)
        shutil.copy2(gitconfig, backup / '.gitconfig')
        (backup / '.gitconfig').chmod(0o600)
    subprocess.run(['git', 'config', '--global', '--add', 'include.path', include], check=True)
if backup.exists(): print(f'Previous configuration backed up to {backup}')
print('Linked shell, runtime and editor defaults. Git identity/authentication remain local.')
