#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Swap ⌘ / ⌥ on the iKBC (Windows-layout) keyboard only, so the key under the
# thumb is ⌘ as it is on a Mac keyboard. Physical Alt (next to space) -> ⌘,
# physical Win -> ⌥.
# Device: VendorID 0x1a81 (Sonix) / ProductID 0x1202, over the wireless dongle.
set -euo pipefail

VENDOR=0x1a81
PRODUCT=0x1202

# Clear before setting, rather than overwriting in place.
#
# Seen once: the mapping is present -- `hidutil --get` reads it back -- while
# the keyboard's whole Esc + F1..F12 row is dead and the ⌘/⌥ swap is only half
# applied. Clearing it and writing it again fixes that; repeating the --set
# alone does not. The likely shape is that after a reboot or a dongle re-plug
# the mapping lands on a stale RegistryID and has to be re-seated (the device
# exposes more than one).
#
# Clearing is idempotent and costs one more instantaneous call, so do it every
# pass: the LaunchAgent then recovers that state within its 180 s interval
# instead of needing someone to notice and intervene.
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
