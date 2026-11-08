# Development-machine bootstrap

## Install

Clone the repository wherever you keep code:

```sh
git clone https://github.com/cohjo/dotfiles.git
cd dotfiles
make setup
```

Automatic system-package installation supports Homebrew (macOS/Linux) and
Debian/Ubuntu apt. On macOS install Homebrew and Apple's command line tools
(`xcode-select --install`) first. apt installation requires root/sudo. Other Linux
distributions can install the listed dependencies manually, then use `make configure`.
This is intended for a personal development account, not a shared production host.

| Command | Purpose |
| --- | --- |
| `make setup` | Install core packages, link configs, install runtimes and Neovim tools |
| `make setup PROFILE=containers` | Core plus container tools |
| `make setup PROFILE=data` | Core plus Miniforge (retain existing Miniconda/Miniforge) |
| `make setup PROFILE=cloud` | Core plus AWS CLI and kubectl |
| `make setup PROFILE=containers,data` | Combine profiles |
| `make configure` | Link/configure using system packages already installed |
| `make doctor` | Check core commands, links, runtimes and Mason packages |
| `make doctor PROFILE=containers,data` | Also check optional profiles |
| `make nvim` | Original Neovim-only bootstrap with existing prerequisites |
| `make link` | Link shell, runtime, Git defaults, Neovim and tmux; do not install packages |

## Package ownership

- Homebrew / apt: system tools, compiler prerequisites and bootstrap Python.
- mise: Neovim 0.11.6, Node 24, Go 1.25 and Temurin Java 25 defaults.
- uv: Python 3.13, project virtual environments, lockfiles and isolated Python CLIs.
- Mason: editor language servers, lint tools and formatters.
- Miniforge/Conda: optional projects needing Conda/native scientific dependencies.

`mise/config.toml` declares global fallback release lines; Node/Go/Java patch
versions resolve when explicitly running setup/install. Pin exact versions in each
project's `mise.toml`, `.python-version`, dependency manifests and lockfiles.
Neovim's patch version is fixed because this config uses the 0.11 Treesitter API.
Shell startup never installs or upgrades packages. Homebrew setup uses
`--no-upgrade`; update system tools deliberately. Missing project runtime versions
must be installed with `mise install`, rather than surprise downloads at a prompt.

Python project example:

```sh
uv init
uv python pin 3.13
uv add fastapi
uv run python --version
# Existing checkout:
uv sync
```

Node project example:

```sh
mise use node@24
npm ci
```

The global runtime config selects defaults only. Project config takes precedence.
The editor's Java server gets a separately generated `JDTLS_JAVA_HOME` so a project
can use an older JDK while jdtls continues running on the bootstrap JDK.
No nvm/pyenv startup hooks are installed. Existing installations are not deleted.

## Shell and local settings

The managed `.zshenv`, `.zprofile` and `.zshrc` provide PATH/shims, Neovim editor
variables, history, cached completion, a simple prompt and a few aliases (`v`,
`gs`, `gd`, `gl`, `ll`, `..`). mise shims resolve runtime versions per project on
command invocation; there is no mise activation subprocess on every prompt. Use
`mise exec -- <command>` for project-defined environment variables as well.
There are no shell frameworks, prompt Git subprocesses or network/update hooks.
The login shell itself is not changed; select Zsh with your OS account settings
if you normally use a different shell. Existing Bash configuration is not changed.

Before replacement, previous configs go under
`~/.config/dotfiles-backups/<timestamp>-<pid>/` (or `$XDG_CONFIG_HOME`). These
backups and migrated private files use restrictive permissions. On the first
migration, simple environment exports and aliases are copied to:

- `~/.config/zsh/env.local.zsh`: private exports and machine paths.
- `~/.config/zsh/local.zsh`: private aliases.

Existing `.zshrc.local` / `.zprofile.local` are also supported. Custom multiline
functions from an old shell remain in the backup for selective migration.
Existing private override files are never overwritten by the migration.
The original files are not blindly sourced: that would reintroduce competing
version managers/framework startup. Do not move private files into this repo.

The Git defaults are appended as an include in your existing `.gitconfig`;
identity, authentication, signing settings and work/personal `includeIf` rules
remain machine-local. Later includes/settings can override these defaults.
Log in separately with `gh auth login` and cloud-provider tools. Credentials,
SSH keys, `.env` files and cloud state are not installed from Git.

Non-interactive Zsh sessions get PATH/shims through `.zshenv`. Other shells and
agents should inherit that PATH or use `mise exec -- <command>`; a clean `sh -c`
that does not read Zsh configuration cannot activate it automatically.

## Containers

On macOS the profile installs Colima, the Docker CLI, Compose and Buildx.
It installs no Docker Desktop app and does not start a VM or login service.
CLI plugin symlinks are configured without rewriting Docker's credential config.

```sh
make containers-start       # 2 CPUs, 2 GiB RAM, 40 GiB virtual disk
make containers-status
docker context use colima   # if another Docker context is selected
docker compose up -d
make containers-stop
```

Override sizing when starting:

```sh
COLIMA_CPU=4 COLIMA_MEMORY=4 COLIMA_DISK=60 make containers-start
```

The defaults are modest; databases and larger builds may need more RAM. An
existing Colima profile can retain its previous settings. Colima is not launched
from the shell, so opening terminals does not start a VM. Existing Docker
contexts and Docker Desktop data/apps are not removed; choose the Colima context
explicitly. A `DOCKER_HOST` override can supersede context selection.

On apt-based Linux the profile installs native Docker Engine and available Compose
packages. It does not create a VM, change user-group membership, or explicitly
manage daemon services. Package-manager postinstall scripts may start the service.
Use your host's rootless Docker/service policy or `sudo docker` as appropriate.
Older Debian releases may provide the standalone `docker-compose` command rather
than `docker compose`.

## Conda and cloud

The data profile installs Miniforge into `~/miniforge3` using its published SHA256
checksum, unless a home-directory Miniconda/Miniforge installation already exists.
Conda loads only when `conda` is invoked; its base environment is not auto-activated.
Create environments explicitly and commit their dependency files to the project.

The cloud profile installs AWS CLI and kubectl. Homebrew provides them where
available; other Linux hosts use explicit mise-backed wrappers in `~/.local/bin`.
No cloud accounts, kubeconfig, clusters, credentials or default regions are created.

## Recovery

Close affected applications, move managed symlinks aside, and copy the original
files from the private backup directory into place. To undo the Git include, run
`git config --global --fixed-value --unset-all include.path /absolute/path/to/dotfiles/git/config`.
Installed tools and old environment managers are not deleted by setup or recovery.

Official references: [mise shims](https://mise.jdx.dev/dev-tools/shims.html),
[uv](https://docs.astral.sh/uv/), [Colima](https://github.com/abiosoft/colima),
and [Miniforge](https://github.com/conda-forge/miniforge).
