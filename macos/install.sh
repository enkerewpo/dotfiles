#!/usr/bin/env bash
# 在一台新 Mac 上重放键鼠配置。
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

# 鼠标。
#
# com.apple.mouse.scaling = -1 关掉 macOS 自己的指针加速曲线，把手感整个
# 交给 LinearMouse。这两者是一对，不是可以拆开的两条设置：只关加速而
# LinearMouse 没在跑，剩下的就是一个没有任何补偿的裸指针，慢到没法用。
#
# 这正是它第一次出问题的方式——设置写进了 defaults（重启后还在），而负责
# 补偿它的 LinearMouse 没进登录项（重启后没了）。所以先确保 LinearMouse
# 会自启，确保不了就不关加速。
LM=/Applications/LinearMouse.app
if [[ -d "$LM" ]]; then
  # 经典登录项，System Settings > 通用 > 登录项 里可见、可手动关掉。
  if ! osascript -e 'tell application "System Events" to get the name of every login item' \
       2>/dev/null | grep -q LinearMouse; then
    osascript -e "tell application \"System Events\" to make login item at end \
      with properties {path:\"$LM\", hidden:false}" >/dev/null
    echo "LinearMouse 已加入登录项"
  fi
  pgrep -qf LinearMouse || open -a LinearMouse
  defaults write -g com.apple.mouse.scaling -float -1
  defaults write -g com.apple.mouse.linear -int 1
  echo "指针加速已交给 LinearMouse（重新登录后完全生效）"
else
  # 没装就保持系统默认：这里写 -1 只会得到一个爬行的指针。
  echo "未安装 LinearMouse，保留 macOS 默认指针加速" >&2
fi
