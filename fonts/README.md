# Licensed personal fonts

Berkeley Mono is a commercial typeface from U.S. Graphics Company and is not
redistributed in Git (`fonts/berkeley-mono/*.otf` is gitignored).

To enable automatic installation on a new machine, place your four licensed
unmodified OTF files (`BerkeleyMono-Regular.otf`, `BerkeleyMono-Oblique.otf`,
`BerkeleyMono-Bold.otf`, `BerkeleyMono-Bold-Oblique.otf`) into
`fonts/berkeley-mono/`. When those files are not present, `make setup`,
`make configure` and `make fonts` skip font installation cleanly.

`make fonts` verifies the SHA-256 checksums in `fonts/berkeley-mono/manifest.json`
and installs all four faces for the current user on macOS/Linux. Repeated
installation is a no-op, and different installed versions are backed up before
replacement.

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
