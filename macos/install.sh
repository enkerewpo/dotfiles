#!/usr/bin/env bash
# 在一台新 Mac 上重放今天的键鼠配置。
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABEL="ai.wheatfox.ikbc-remap"
DEST="$HOME/Library/LaunchAgents/${LABEL}.plist"

# iKBC ⌘/⌥ 重映射：软链 plist 到 LaunchAgents，仓库是唯一真源。
mkdir -p "$HOME/Library/LaunchAgents"
ln -sf "$HERE/${LABEL}.plist" "$DEST"
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$DEST"
launchctl kickstart -k "gui/$(id -u)/$LABEL"
echo "loaded $LABEL"

# 鼠标：关掉 macOS 指针加速（线性）。LinearMouse 装了后由它统管，
# 这条作为无 LinearMouse 时的兜底；改后需重新登录生效。
defaults write -g com.apple.mouse.scaling -1
echo "mouse acceleration disabled (re-login to take effect)"
