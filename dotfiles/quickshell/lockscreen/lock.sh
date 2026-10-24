#!/bin/bash
bg="${XDG_RUNTIME_DIR}/quickshell-lock-bg.png"
mkdir -p "$(dirname "$bg")"
grim "$bg" 2>/dev/null || true
QS_LOCK_BG="$bg" qs -p "${HOME}/.config/quickshell/lockscreen/lockscreen.qml"
rm -f "$bg"