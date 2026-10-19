#!/usr/bin/env bash
# ==============================================================================
# hyprland-session.sh - Hyprland WSL 2 Session Initializer
#
# Connects Hyprland's Aquamarine WSL backend to the Windows DirectX 11 companion
# viewer using zero-copy shared memory (/mnt/wslgshm) and AF_VSOCK.
# ==============================================================================
set -euo pipefail

# 1. Terminal line discipline: ensure newline emits carriage return (CR+LF)
stty onlcr 2>/dev/null || true

# 2. Real-time scheduling limits (reduces micro-stutter)
ulimit -r 99 -e 20 2>/dev/null || true

# 3. Hyper-V VM ID Handshake to Windows companion viewer via file descriptor 3
exec 3>&1

VMID=$(wslinfo --vm-id 2>/dev/null | tr -d '\r')
if [ -z "$VMID" ]; then
    echo "Error: wslinfo --vm-id failed (WSL 2.0+ required)." >&2
    exit 1
fi
echo "WOMARCHY_VMID=$VMID" >&3
exec 3>&-

# 4. Runtime & Zero-Copy Section Shared Memory
RUNTIME="/run/user/$(id -u)"
[ -d "$RUNTIME" ] || mkdir -p "$RUNTIME"
export XDG_RUNTIME_DIR="$RUNTIME"

# Mount /mnt/wslgshm if not already mounted
SHM="/mnt/wslgshm"
if ! mountpoint -q "$SHM" 2>/dev/null; then
    systemctl start mnt-wslgshm.mount 2>/dev/null || true
fi

if mountpoint -q "$SHM" 2>/dev/null && [ -w "$SHM" ]; then
    export WOMARCHY_SHM_DIR="$SHM"
fi

# 5. Clean Environment & Strip Windows PATH for rapid binary resolution
unset DISPLAY WAYLAND_DISPLAY
PATH=$(printf '%s' "$PATH" | tr ':' '\n' | grep -v '^/mnt/' | paste -sd:)
export PATH

# 6. Backend & GPU Variables
export HYPRLAND_BACKEND=wsl
export WOMARCHY_VM_ID="$VMID"
export WOMARCHY_TOKEN="${WOMARCHY_TOKEN:-}"
export WOMARCHY_CLIP_TOKEN="${WOMARCHY_CLIP_TOKEN:-}"
export WOMARCHY_VSOCK_PORT="${WOMARCHY_VSOCK_PORT:-}"
export WOMARCHY_MONITORS="${WOMARCHY_MONITORS:-}"
export WOMARCHY_ORPHAN_TIMEOUT=0

# Direct3D 12 Gallium driver acceleration via /dev/dxg
export GALLIUM_DRIVER=d3d12
export MESA_LOADER_DRIVER_OVERRIDE=d3d12
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_CLASS=user
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland

# 7. Start in user home directory so spawned apps start in ~
cd "$HOME"

# 8. Launch official Hyprland compositor with explicit path
if command -v start-hyprland >/dev/null 2>&1; then
    exec /usr/bin/start-hyprland --path /usr/bin/Hyprland "$@"
else
    exec /usr/bin/Hyprland "$@"
fi
