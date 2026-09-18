#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# iKBC (Windows 布局) 在 macOS 上把 ⌘/⌥ 对调，只作用于这颗键盘。
# 物理 Alt(挨着空格) -> ⌘，物理 Win -> ⌥，与 Mac 原生键盘手型一致。
# 设备：VendorID 0x1a81 (Sonix) / ProductID 0x1202，走 wireless dongle。
set -euo pipefail

VENDOR=0x1a81
PRODUCT=0x1202

hidutil property \
  --matching "{\"VendorID\":${VENDOR},\"ProductID\":${PRODUCT}}" \
  --set '{"UserKeyMapping":[
    {"HIDKeyboardModifierMappingSrc":0x7000000E3,"HIDKeyboardModifierMappingDst":0x7000000E2},
    {"HIDKeyboardModifierMappingSrc":0x7000000E2,"HIDKeyboardModifierMappingDst":0x7000000E3},
    {"HIDKeyboardModifierMappingSrc":0x7000000E7,"HIDKeyboardModifierMappingDst":0x7000000E6},
    {"HIDKeyboardModifierMappingSrc":0x7000000E6,"HIDKeyboardModifierMappingDst":0x7000000E7}
  ]}' >/dev/null

echo "ikbc-remap: ⌘/⌥ swapped on ${VENDOR}:${PRODUCT}"
