# Neovim

Small Neovim 0.11.3+ configuration with Tokyo Night (night), Mason, ty + Ruff,
jdtls, full-stack language servers, Blink completion, Treesitter, Mini pickers, Which-key and Git signs.

See the fresh-machine installation section below for system prerequisites.
Link this directory to ~/.config/nvim with the dotfiles editor-link script.
Plugins, declared language servers, linters and formatters install automatically. Use `:Lazy`
for plugins, `:Mason` for tools, and `:checkhealth` for troubleshooting.
Treesitter stays on its Neovim 0.11-compatible master branch.

## Keys

Space is the leader. Space f finds files; Space b switches buffers; Space /
searches project contents. Shift h/l switch buffers, Space x closes a buffer,
Space e opens the built-in file explorer. Run `nvim .` from a project root.

`gd`: definition; `gr`: references; `gi`: implementation; `K`: documentation.
Space rn renames; Space ca opens code actions; Space d shows line diagnostics;
Space D lists diagnostics. `[d` / `]d` move between diagnostics.
Space lf formats; Space tf toggles formatting on save for the current buffer.
Completion: Ctrl Space opens, Ctrl n/p selects, Ctrl y accepts, Ctrl e dismisses.
Ctrl Space in normal/visual mode expands Treesitter selections, Backspace shrinks.
`gcc` / `gc` use Neovim's built-in commenting.

Space hp previews a Git hunk; Space hs stages it; Space hr resets it.
`[h` / `]h` navigate Git hunks. Persistent undo and system clipboard are enabled.

## Explore code and search shortcuts

`Space m` opens a curated daily essentials sheet: file finding, buffer switching,
code navigation, editing, search, diagnostics and Git. It includes useful built-in
Vim commands as well as your custom shortcuts. This is a recommended set, not
measured usage tracking. Type to filter, Up/Down to select, Enter to run, Esc to close.

`Space ?` opens a searchable popup of current normal-mode mappings, including
buffer-local plugin bindings. `Space H` searches mappings across all modes.
Type words such as "caller", "rename" or "format" to filter descriptions;
use Up/Down to select, Enter to run the selected mapping, Escape to close.
Tab toggles the preview. These lists reflect live mappings, so plugin-local
shortcuts appear while that plugin's window is focused. They list mappings,
not every built-in Vim command. Which-key still shows available Space sequences.

| Keys | Action |
| --- | --- |
| `gd` / `gi` / `gr` | Definition / implementations / references |
| `Space ci` | Incoming calls: who calls this function? |
| `Space co` | Outgoing calls: what does this function call? |
| `Space ct` / `Space cT` | Parent / child type hierarchy |
| `Space cl` | Reopen last hierarchy |
| `Space s` | Search symbols in the current file |
| `Space j` / `Space k` | Back / forward through navigation history |

The meow.yarn hierarchy popup loads on demand and queries your language server.
Use `j/k` to move, `l/h` to expand/collapse, Enter to jump, `/` to filter,
`K/J` to explore callers/callees (or parent/child types) from the selected node,
and Backspace to retrace that exploration. `m` marks nodes, `Q` sends them to
quickfix, PageUp/PageDown scroll the source preview, and `q` closes the popup.
Space remains available for your leader shortcuts, including `Space ?`.

Availability depends on the language server: references, calls and type
hierarchies are different capabilities. Unsupported hierarchy requests show a
message suggesting references or symbols. A symbol with no known callers may
legitimately produce an empty hierarchy. These are static relationships, not
runtime traces, so reflection/framework dispatch can be incomplete.

## Languages

Python uses ty for completion, types and navigation; Ruff provides linting,
code actions and formatting on save. Keep `.venv` in the project root for
automatic discovery; pyproject.toml configures project tools. For a differently
located environment, activate it before starting Neovim (VIRTUAL_ENV).

Java uses jdtls for completion, diagnostics, navigation and formatting. Open
Neovim from a Maven/Gradle project; each project gets a separate server workspace.
The server requires a recent JDK even when your project targets an older Java.
Set JDTLS_JAVA_HOME to override the server JDK. Otherwise the config prefers
Homebrew openjdk on macOS when available, then your normal Java executable.
Dynamic LSP file watchers are disabled to avoid macOS watcher exhaustion.

TypeScript/JavaScript/React uses the TypeScript language server for completion,
navigation, rename and type errors; Oxlint supplies lint diagnostics/code actions;
Prettier formats on save. Project-local Oxlint and Prettier are preferred. Configure
rules with `.oxlintrc.json`, formatting with Prettier config, and types with
`tsconfig.json`/`jsconfig.json`. `:LspOxlintFixAll` applies lint fixes.

JSON and YAML use SchemaStore for common config schemas (package.json,
GitHub Actions, etc.). Schema downloads need network access; custom schemas can
be supplied using `$schema` in JSON or a `yaml-language-server` modeline in YAML.
HTML/CSS (including SCSS/Less), Dockerfiles/Compose, TOML, Markdown, Lua and
shell scripts have language servers too. Bash uses ShellCheck from Mason.
Prettier formats web/config/Markdown files; StyLua formats Lua; shfmt formats sh.
Java and TOML use LSP formatting. Formatting follows the project's tool config.

SQL uses sqls. Schema/table completion needs project-specific connections;
configure sqls using its documented config file or `settings.sqls.connections`.
Keep credentials in local files/environment, outside version control. SQL dialects
vary, so SQL format-on-save is off. Space lf invokes sql-formatter manually;
use `.sql-formatter.json` in your project to select a dialect (e.g. postgresql).
No database connections or query execution commands are configured automatically.

## Fresh-machine installation

Run `make setup` from the repository root on a Homebrew machine; it installs
system runtimes and runs the Neovim bootstrap. With prerequisites already
installed, run `make nvim` instead. The checkout can live anywhere.
Existing configs are backed up before linking. Both commands restore locked
plugin revisions, wait for Mason tools, and install parsers before finishing.

Prerequisites: Neovim 0.11.3+, Git, ripgrep, Node.js/npm (current LTS recommended),
Python 3, Go (for sqls), a current JDK (Homebrew openjdk recommended), a C compiler,
curl, unzip, tar and gzip. Install these with your system package manager on Linux;
distro Neovim packages may be older than the required version. Install Apple's
command line tools on macOS. This setup targets macOS/Linux.

`lua/toolchain.lua` is the install manifest: add an lspconfig-name/Mason-package
pair to `servers`, an external formatter to `formatters`, or a parser to `parsers`.
Then add any server settings and Conform formatting rules in `lua/plugins.lua`.
`:MasonToolsInstall` installs missing packages; `make nvim` waits for completion.
Only servers relevant to open files run, even though all tools are installed.
Use `:Mason` for explicit updates; automatic tool upgrades are disabled. Plugin
revisions are locked, while fresh machines receive current Mason package versions.
For consistent team/CI checks, pin tools in the project's own dependency files.

The initial configuration was backed up under ~/.config/nvim-backups/20261101-204354.
No plugin data, undo history or Mason packages were removed during migration.

## Performance policy

Empty startup defers LSP setup, completion, Treesitter and formatting until their
file/insert/save events. The schema catalog loads only for JSON/YAML servers.
When all declared Mason tools are installed, automatic installer runs are skipped; missing tools still
install when the language setup loads. The explicit bootstrap always checks all tools.
The hierarchy explorer loads only on request and expands one level initially.
Config file watchers are disabled; restart after changing configuration.

Startup timing does not measure typing, project indexing or format-on-save latency.
Language-server cost depends on the language and project; only relevant servers run.

## Review Git changes and agent work

`Space gs` opens a fresh Git status picker including staged, unstaged and untracked
files, plus renames/deletions. Type to filter, Up/Down to select, Tab for staged
and unstaged diff previews (new files preview their contents), Enter to open.
The two status columns are Git's index/worktree codes; `??` means untracked.
Deleted files can be previewed but are not opened as empty buffers.
Reopen the picker to refresh after an agent changes files. File opening checks
for external edits; Neovim retains its normal protection for unsaved buffers.

`Space gd` browses unstaged hunks across files; `Space gD` browses staged hunks.
Existing keys: `]h`/`[h` next/previous hunk in the file, `Space hp` preview hunk,
`Space hs` stage hunk, and `Space hr` reset hunk (discards that hunk's changes).
The pickers themselves only inspect/open files and perform no staging or resets.
