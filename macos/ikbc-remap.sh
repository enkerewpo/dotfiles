#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# iKBC (Windows 布局) 在 macOS 上把 ⌘/⌥ 对调，只作用于这颗键盘。
# 物理 Alt(挨着空格) -> ⌘，物理 Win -> ⌥，与 Mac 原生键盘手型一致。
# 设备：VendorID 0x1a81 (Sonix) / ProductID 0x1202，走 wireless dongle。
set -euo pipefail

VENDOR=0x1a81
PRODUCT=0x1202

# 先清空再写入，而不是直接覆盖。
#
# 见过一次这样的状态：映射「在」（hidutil --get 读得出来），但键盘上整排
# Esc + F1~F12 没有反应，⌘/⌥ 对调也半死不活。清空一次再写回去就好了，
# 单纯重复 --set 不管用。推测是重启 / 重新插 dongle 后映射落在了过期的
# RegistryID 上，需要重新落位。清空是幂等的，代价是一次瞬时调用，所以
# 每次都做，让这条 agent 能自己把那个状态顶回来。
hidutil property \
  --matching "{\"VendorID\":${VENDOR},\"ProductID\":${PRODUCT}}" \
  --set '{"UserKeyMapping":[]}' >/dev/null

hidutil property \
  --matching "{\"VendorID\":${VENDOR},\"ProductID\":${PRODUCT}}" \
  --set '{"UserKeyMapping":[
    {"HIDKeyboardModifierMappingSrc":0x7000000E3,"HIDKeyboardModifierMappingDst":0x7000000E2},
    {"HIDKeyboardModifierMappingSrc":0x7000000E2,"HIDKeyboardModifierMappingDst":0x7000000E3},
    {"HIDKeyboardModifierMappingSrc":0x7000000E7,"HIDKeyboardModifierMappingDst":0x7000000E6},
    {"HIDKeyboardModifierMappingSrc":0x7000000E6,"HIDKeyboardModifierMappingDst":0x7000000E7}
  ]}' >/dev/null

echo "ikbc-remap: ⌘/⌥ swapped on ${VENDOR}:${PRODUCT}"
