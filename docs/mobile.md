# Phone editing: the same Neovim, with a compact interface

Use `nvimm path/to/project` (or `nvimm path/to/file`) on the machine holding the
code. It runs the existing Neovim configuration with `NVIM_MOBILE=1`: no duplicate
plugin installation, runtime, language-server setup or unfamiliar editing model.
Plain `nvim` keeps the desktop interface. Open a separate terminal/session for the
phone rather than sharing a live terminal with your desktop: different screen
sizes otherwise compete to resize the same PTY.

## Recommended connection

If your Rex beta includes the iOS client, use its native connection to your existing
Rex server over Tailscale. Pair through Rex for Mac's **Settings → Server → Remote
Address** and use the phone client to open a dedicated session, then launch `nvimm`.
Rex itself manages sessions, so there is no need to nest tmux merely for its native
client connection. This setup does not change your tailnet, ACLs, SSH settings or
Rex authentication.

If you use an ordinary SSH client instead, Blink Shell or Termius over your tailnet
works with the same profile. Use tmux to preserve the editor when iOS suspends the
SSH app or the connection drops:

```sh
ssh your-host-on-your-tailnet
cd path/to/project
tmux new-session -A -s phone
nvimm .
```

Avoid `tmux attach -d` for the phone: it can disconnect the desktop. Mosh can help
on unreliable mobile connections if your client supports it and you separately
install/configure mosh on the host. It is not needed for the native Rex connection,
and no new network ports or remote services are opened by this bootstrap.

## Compact profile

- Long lines wrap at word boundaries, with indentation retained. `j`/`k` move by
  displayed lines; numbered motions still use logical lines.
- Line numbers, sign gutter and status bar are hidden; `Space n` toggles numbers.
- Diagnostics remain available with `Space d` / `Space D`, without inline text.
- File, buffer, symbol, Git and cheatsheet pickers retain your existing shortcuts.
  Their window uses almost the full width of a narrow terminal.
- Autocomplete and documentation popups do not appear automatically. In insert
  mode, Tab requests completion/cycles candidates and Enter accepts a visible item.
  If there are no candidates, normal Tab/newline behavior remains available.
- Format on save starts disabled per buffer to keep quick changes small. `Space tf`
  enables it for that buffer; `Space lf` formats explicitly.
- Mouse support allows terminal clients that forward taps to position the cursor.
  Host OS clipboard integration is disabled: use the client's native copy/paste.
- `jk` leaves insert mode if your keyboard has no convenient Esc. The client Esc
  button is preferable when typing those literal characters. The mapping has the
  normal mapping timeout, so a lone `j` may briefly wait to see whether `k` follows.
- `Space z` / `Space u` page down/up. `Space w` saves. `Space m` shows daily keys.
- The hierarchy explorer still loads only when requested. Which-key's extra popup
  is suppressed on mobile; the searchable cheatsheets remain available.

Language servers execute on the host. You retain definitions, references, rename
and diagnostics for supported languages. Do the full bootstrap on that host first;
mobile editing does not automatically run package installers.

## iPhone ergonomics

Start in portrait at a readable font size (roughly 14–16 pt, adjusted for your
screen). Switch to landscape for inspecting a long expression or a diff; don't
shrink all code just to fit 100 columns. Use one code pane at a time. A small
physical keyboard helps for longer edits, but the profile is usable with touch.

In Rex iOS **Settings → Terminal**:

- Put Esc, Tab, arrows, Home/End and Page Up/Down where they are easy to reach in
  the Key Bar. Add useful punctuation (`/`, `:`, quotes, brackets, underscore, pipe)
  through Characters/shortcut groups.
- Disable autocorrect for code. Use the client's paste action for multi-line text.
- Use a readable available monospaced font. Your remote host's Berkeley Mono
  installation does not install that font on iOS or change its client font choice.
- If rotation/keyboard resizing feels distracting, adjust Smooth terminal resizing
  in the client's settings. These device preferences are not changed by dotfiles.

For agent-driven changes, `Space gs` is a useful entry point. Reopen it for a fresh
status list; opening a file checks for external edits. Don't maintain conflicting
unsaved edits to the same file in separate desktop and phone editors.

Rex references: [iOS settings](https://www.superlogical.com/rex/docs/reference/ios-settings)
and [remote access](https://www.superlogical.com/rex/docs/reference/mac-settings#remote-address).
