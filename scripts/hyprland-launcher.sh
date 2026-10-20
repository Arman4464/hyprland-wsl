#!/usr/bin/env bash
# ==============================================================================
# /usr/local/bin/Hyprland - Native Hyprland Launcher for WSL 2
# ==============================================================================
set -euo pipefail

# 1. Forward flags directly to compiled Hyprland binary (required by hyprctl/tools)
# Also guard against recursion if invoked from within an existing Hyprland session
if [ -n "${WOMARCHY_TOKEN:-}" ] || [ -n "${HYPRLAND_BACKEND:-}" ] || [ "$#" -gt 0 ]; then
    exec /usr/bin/Hyprland "$@"
fi

# 2. Check if already running in this session (verify active IPC socket)
RUNTIME="/run/user/$(id -u)"
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ -S "${RUNTIME}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket.sock" ]; then
    echo "Hyprland is already running in this session."
    exit 0
fi

# 3. Ensure WSLg zero-copy shared memory is mounted
if ! mountpoint -q /mnt/wslgshm 2>/dev/null; then
    sudo -n /usr/bin/systemctl start mnt-wslgshm.mount 2>/dev/null || true
fi

# 4. Terminal restoration trap and line discipline
cleanup() {
    stty sane 2>/dev/null || true
}
trap cleanup EXIT INT TERM
stty onlcr 2>/dev/null || true

# 5. Launch viewer attached directly to interactive TTY
VIEWER="/mnt/c/Users/rango/.local/bin/hyprland-viewer.exe"
if [ ! -f "$VIEWER" ]; then
    VIEWER="/mnt/d/RangoWorkspace/bin/hyprland-viewer.exe"
fi
if [ ! -f "$VIEWER" ]; then
    VIEWER="/mnt/d/RangoWorkspace/hyprland-wsl/bin/hyprland-viewer.exe"
fi

cd /mnt/c
"$VIEWER" --distro "${WSL_DISTRO_NAME:-Arch}" --user "$USER" --session /usr/local/bin/hyprland-session
