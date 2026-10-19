#!/usr/bin/env bash
# ==============================================================================
# /usr/local/bin/Hyprland - Native Hyprland Launcher for WSL 2
# ==============================================================================

# 1. Forward flags directly to compiled Hyprland binary (required by start-hyprland/hyprctl)
if [ "$#" -gt 0 ]; then
    exec /usr/bin/Hyprland "$@"
fi

# 2. Check if already running in this session
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    echo "Hyprland is already running in this session."
    exit 0
fi

# 3. Ensure WSLg zero-copy shared memory is mounted
if ! mountpoint -q /mnt/wslgshm 2>/dev/null; then
    sudo systemctl start mnt-wslgshm.mount 2>/dev/null || true
fi

# 4. Enable terminal line discipline (translate NL to CR-NL to eliminate staircase formatting)
stty onlcr 2>/dev/null || true

# 5. Launch viewer in foreground from C:\ (clean working dir, no UNC warnings)
#    This keeps the real Hyprland session running interactively in this terminal
VIEWER="/mnt/c/Users/rango/.local/bin/hyprland-viewer.exe"
if [ ! -f "$VIEWER" ]; then
    VIEWER="/mnt/d/RangoWorkspace/hyprland-wsl/bin/hyprland-viewer.exe"
fi

(cd /mnt/c && exec "$VIEWER" --distro "${WSL_DISTRO_NAME:-Arch}" --user "$USER" --session /usr/local/bin/hyprland-session)
