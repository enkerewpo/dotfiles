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
- `com.apple.mouse.scaling -1` turns off the macOS pointer acceleration curve
  and hands the feel to **LinearMouse** (`brew install --cask linearmouse`),
  which does per-device speed and scrolling.

  These two are a **pair, not two independent settings**. The `defaults` value
  is durable and survives a reboot; LinearMouse only runs if something starts
  it. With acceleration off and LinearMouse not running, what is left is a raw
  uncompensated pointer that crawls — which is how this broke once, after a
  restart, because LinearMouse had never been registered as a login item.
  `install.sh` therefore registers it first and only then writes the defaults.

- Ctrl + scroll zoom (Skim, Preview, browsers) needs an explicit modifier
  action in `~/.config/linearmouse/linearmouse.json`; smooth scrolling
  synthesises its own scroll events and the modifier does not survive the
  substitution:

      "scrolling": { "modifiers": { "control": { "type": "pinchZoom" } } }

  `pinchZoom` emits magnification gestures (continuous). `zoom` sends ⌘+/⌘-
  instead, which steps discretely but does not depend on the app handling
  gestures.

### Login items

Menu-bar utilities that register nothing of their own are added as classic
login items by `install.sh`, so they come back after a restart:

- **LinearMouse** — without it the pointer setting above has nothing to
  compensate it.
- **Snipaste** — its global `F1` shortcut goes away with the app.

Inspect or remove them in System Settings → General → Login Items.

### Troubleshooting

**The whole Esc + F1..F12 row is dead, and ⌘/⌥ is only half swapped.** The
mapping reads back fine from `hidutil --get`, but re-applying it does nothing.
Clear it and write it again:

    hidutil property --matching '{"VendorID":0x1a81,"ProductID":0x1202}' \
      --set '{"UserKeyMapping":[]}'
    bash macos/ikbc-remap.sh

`ikbc-remap.sh` now clears before every set, so the LaunchAgent recovers this
within 180 s on its own. The cause is not confirmed; the device exposes more
than one `RegistryID`, and the mapping landing on a stale one after a reboot
or dongle re-plug is the likely shape.
