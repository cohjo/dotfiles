# Licensed personal fonts — keep this repository private

The four unmodified Berkeley Mono OTF files are the repository owner's licensed
personal copies. They are proprietary U.S. Graphics Company fonts, not open-source
assets, and are not licensed for redistribution to other users. Their original
copyright/trademark metadata remains embedded in the font files.

Do not make this repository public or share the fonts. Keep your purchase/license
records separately; this repository intentionally contains no purchase identifiers.
No Nerd Font patching, subsetting or other modification is performed.

`make fonts` installs all four faces for the current user on macOS/Linux. Full
`make setup` / `make configure` also install them. The checksum manifest verifies
the files and makes repeated installation a no-op. Different installed versions
are backed up before replacement. The trial font is not included.

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
