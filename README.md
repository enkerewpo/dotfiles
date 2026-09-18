# dotfiles

Personal machine configuration, kept in git so it can be replayed.

## macOS

`macos/install.sh` applies everything below. Run it once on a new machine.

### iKBC keyboard (Windows layout) — swap ⌘ / ⌥

A Windows-layout keyboard puts `Ctrl / Win / Alt` left of the spacebar, which
macOS reads as `Ctrl / ⌘ / ⌥` — so the key under the thumb ends up as ⌥, the
opposite of a Mac keyboard. `macos/ikbc-remap.sh` swaps ⌘ and ⌥ **on this
keyboard only** (matched by `VendorID 0x1a81 / ProductID 0x1202`, a Sonix
wireless dongle), leaving the built-in keyboard untouched.

`hidutil` mappings are lost on reboot and when the dongle re-enumerates, so
`ai.wheatfox.ikbc-remap.plist` is a LaunchAgent that applies it at login and
re-asserts it every 180 s (the set is idempotent and instant).

    launchctl print gui/$(id -u)/ai.wheatfox.ikbc-remap   # inspect
    hidutil property --matching '{"VendorID":0x1a81,"ProductID":0x1202}' --get UserKeyMapping

To undo: remove the symlink in `~/Library/LaunchAgents`, `launchctl bootout`
it, then clear the mapping with `--set '{"UserKeyMapping":[]}'`.

Caps Lock switching input source is a separate macOS setting (Keyboard →
Input Sources), not part of this remap.

### Mouse (Logitech GPW3)

- Device DPI / polling rate live in **G HUB** (on-board memory).
- macOS pointer acceleration is disabled (`com.apple.mouse.scaling -1`) so
  speed is governed purely by DPI. **LinearMouse** (`brew install --cask
  linearmouse`) is the GUI front-end for per-device speed and scroll; once it
  manages the pointer the `defaults` value above is redundant.
