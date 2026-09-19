#!/usr/bin/env bash
# Replay this machine's keyboard and mouse configuration on a new Mac.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABEL="ai.wheatfox.ikbc-remap"
DEST="$HOME/Library/LaunchAgents/${LABEL}.plist"

login_item() {
  # A classic login item: visible and removable in
  # System Settings > General > Login Items, unlike an SMAppService
  # registration an app makes for itself.
  local app="$1" name
  name="$(basename "$app" .app)"
  [[ -d "$app" ]] || { echo "not installed, skipping: $app" >&2; return 1; }
  if osascript -e 'tell application "System Events" to get the name of every login item' \
     2>/dev/null | grep -q "$name"; then
    return 0
  fi
  osascript -e "tell application \"System Events\" to make login item at end \
    with properties {path:\"$app\", hidden:false}" >/dev/null
  echo "added login item: $name"
}

# ── iKBC ⌘/⌥ remap ─────────────────────────────────────────────────────────
# The plist is symlinked out of this repo, so the repo stays the only source.
mkdir -p "$HOME/Library/LaunchAgents"
ln -sf "$HERE/${LABEL}.plist" "$DEST"
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$DEST"
launchctl kickstart -k "gui/$(id -u)/$LABEL"
echo "loaded $LABEL"

# ── Mouse ──────────────────────────────────────────────────────────────────
# `com.apple.mouse.scaling = -1` turns off the macOS pointer acceleration
# curve and hands the feel entirely to LinearMouse. The two are a pair, not
# two settings that can be applied independently: with acceleration off and
# LinearMouse not running, what is left is a raw uncompensated pointer that
# crawls.
#
# That is exactly how this broke once. The defaults write is durable and
# survived a reboot; LinearMouse was never registered as a login item and did
# not. So register it first, and only disable acceleration once that is in
# place.
LM=/Applications/LinearMouse.app
if login_item "$LM"; then
  pgrep -qf LinearMouse || open -a LinearMouse
  defaults write -g com.apple.mouse.scaling -float -1
  defaults write -g com.apple.mouse.linear -int 1
  echo "pointer acceleration handed to LinearMouse (full effect after re-login)"
else
  # Without the app, writing -1 here would only produce a crawling pointer.
  echo "LinearMouse absent; leaving the macOS pointer acceleration default" >&2
fi

# ── Other menu-bar apps that must survive a reboot ──────────────────────────
# Snipaste registers no login item of its own; after a restart it is simply
# gone, and its global F1 shortcut goes with it.
login_item /Applications/Snipaste.app || true
