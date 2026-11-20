# Local fonts

Drop any `.otf` or `.ttf` font files (or subdirectories of font families) into
`fonts/`. All `.otf` and `.ttf` files under `fonts/` are gitignored so licensed
or custom-compiled typefaces are never committed to Git.

`make fonts` (and `make setup` / `make configure`) discovers every `.otf` and
`.ttf` file under `fonts/` and installs them into the current user's font
directory (`~/Library/Fonts` on macOS, `~/.local/share/fonts` on Linux).
When no font files are present, installation is skipped cleanly. Repeated runs
compare SHA-256 hashes so unchanged faces are a no-op, and updated builds back
up the previous file before replacement.

The terminal client chooses the font, including for terminal Neovim. On Rex for
Mac select **Settings → Terminal → Typography → Terminal font → Berkeley Mono**.
This client setting is not a Ghostty configuration-file setting and is not set
through Rex's Lua keybinding configuration. Select Regular; the family includes
Bold, Oblique and Bold Oblique. Restart/reopen the font picker if a newly installed
face is not listed. The font size is intentionally your preference.

Neovim sets `guifont=Berkeley Mono:h16` for GUI frontends that honor it. Terminal
Neovim inherits Rex's font. The config uses text labels rather than requiring
Nerd Font glyphs; your shell prompt already uses ordinary characters.

The font must be installed on the device rendering the terminal. Installing it
on a remote Mac/Linux host does not change an iPhone client's font. Choose a
readable available iPhone font (or import your licensed font only if that client
supports it); client-specific custom font import is not automated here.
