#!/usr/bin/env bash
# ==============================================================================
# hyprland-session.sh - Hyprland WSL 2 Session Initializer
#
# Connects Hyprland's Aquamarine WSL backend to the Windows DirectX 11 companion
# viewer using zero-copy shared memory (/mnt/wslgshm) and AF_VSOCK.
# ==============================================================================
set -euo pipefail

# 1. Terminal line discipline: guarantee newline emits carriage return (CR+LF)
stty onlcr 2>/dev/null || stty -F /dev/tty onlcr 2>/dev/null || true

cleanup() {
    stty sane 2>/dev/null || true
    stty onlcr 2>/dev/null || stty -F /dev/tty onlcr 2>/dev/null || true
}
trap cleanup EXIT INT TERM HUP

# 2. Hyper-V VM ID Handshake to Windows companion viewer via stdout
VMID=$(wslinfo --vm-id 2>/dev/null | tr -d '\r')
if [ -z "$VMID" ]; then
    echo "Error: wslinfo --vm-id failed (WSL 2.0+ required)." >&2
    exit 1
fi
echo "WOMARCHY_VMID=$VMID"

# 3. Runtime & Zero-Copy Section Shared Memory
RUNTIME="/run/user/$(id -u)"
[ -d "$RUNTIME" ] || mkdir -p "$RUNTIME"
export XDG_RUNTIME_DIR="$RUNTIME"

# Mount /mnt/wslgshm if not already mounted (using passwordless sudo rule)
SHM="/mnt/wslgshm"
if ! mountpoint -q "$SHM" 2>/dev/null; then
    sudo -n /usr/bin/systemctl start mnt-wslgshm.mount 2>/dev/null || true
fi

if mountpoint -q "$SHM" 2>/dev/null && [ -w "$SHM" ]; then
    export WOMARCHY_SHM_DIR="$SHM"
fi

# 4. Clean Environment & Strip Windows PATH for rapid binary resolution
unset DISPLAY WAYLAND_DISPLAY
PATH=$(printf '%s' "$PATH" | tr ':' '\n' | grep -v '^/mnt/' | paste -sd:)
export PATH

# 5. Backend & GPU Variables
export HYPRLAND_BACKEND=wsl
export WOMARCHY_VM_ID="$VMID"
export WOMARCHY_TOKEN="${WOMARCHY_TOKEN:-}"
export WOMARCHY_CLIP_TOKEN="${WOMARCHY_CLIP_TOKEN:-}"
export WOMARCHY_VSOCK_PORT="${WOMARCHY_VSOCK_PORT:-}"
export WOMARCHY_MONITORS="${WOMARCHY_MONITORS:-}"

# Ensure /tmp/.X11-unix exists, is writable, and has sticky bit (WSLg mounts it ro by default)
sudo -n /usr/bin/mkdir -p /tmp/.X11-unix 2>/dev/null || true
if mountpoint -q /tmp/.X11-unix 2>/dev/null; then
    sudo -n /usr/bin/mount -o remount,rw /tmp/.X11-unix 2>/dev/null || true
fi
sudo -n /usr/bin/chmod 1777 /tmp/.X11-unix 2>/dev/null || true

# 6. Backend Lifecycle: 0 = keep Hyprland compositor alive with the viewer
export WOMARCHY_ORPHAN_TIMEOUT=0

# Direct3D 12 Gallium driver acceleration via /dev/dxg (Kepler FL 11_0)
export LIBGL_DRI2_DISABLE=1
export MESA_LOG_LEVEL=error
export LIBGL_ALWAYS_SOFTWARE=0
export GALLIUM_DRIVER=d3d12
export MESA_LOADER_DRIVER_OVERRIDE=d3d12
export MESA_D3D12_DEFAULT_ADAPTER_NAME="NVIDIA"
export WLR_RENDERER=gles2
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_CLASS=user
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland

# Force Qt 6 & Quickshell hardware acceleration on Wayland
export QSG_RHI_BACKEND=opengl
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

# 7. Start in user home directory so spawned apps start in ~
cd "$HOME"

# 8. Launch official Hyprland compositor via start-hyprland watchdog
stty onlcr 2>/dev/null || stty -F /dev/tty onlcr 2>/dev/null || true

if [ $# -gt 0 ]; then
    /usr/bin/start-hyprland --path /usr/bin/Hyprland -- "$@" 2>&1 | /usr/local/bin/wsl-crlf || true
else
    /usr/bin/start-hyprland --path /usr/bin/Hyprland 2>&1 | /usr/local/bin/wsl-crlf || true
fi
EXIT_CODE=$?

cleanup
exit $EXIT_CODE
