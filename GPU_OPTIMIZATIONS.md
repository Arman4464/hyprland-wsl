# Hyprland GPU Optimizations & Disabled Features Log

This document records all GPU-saving optimizations and features disabled to maximize performance and ensure stability on the **NVIDIA GeForce GT 710** (Kepler architecture, Direct3D Feature Level 11_0, 2GB VRAM, 1366x768 @ 60Hz monitor).

Use this reference to re-enable features once Hyprland is fully running.

---

## 📋 Summary of Disabled / Modified Features

| Feature / Component | Prior / Normal State | Optimized / Disabled State | Reason for Change | File & Setting Location |
|---|---|---|---|---|
| **Blur** | Enabled (`true`) | Disabled (`false`) | Blur shaders heavily saturate GT 710 memory bandwidth and fillrate, dropping FPS below 60. | `config/hyprland.lua`<br>`decoration.blur.enabled = false` |
| **Drop Shadows** | Enabled (`true`) | Disabled (`false`) | Multi-pass shadow generation consumes significant fragment shader cycles. | `config/hyprland.lua`<br>`decoration.shadow.enabled = false` |
| **Animations** | Enabled (`true`) | Disabled (`false`) | Interpolation calculations cause micro-stuttering and frame drops on Kepler FL 11_0. | `config/hyprland.lua`<br>`animations.enabled = false` |
| **Splash Rendering** | Enabled (`false`) | Disabled (`true`) | Splash text forces extra surface allocations during startup. | `config/hyprland.lua`<br>`misc.disable_splash_rendering = true` |
| **Dynamic Wallpaper Scaling** | Dynamic bicubic/bilinear scaling by compositor | Wallpapers pre-scaled to exactly 1366x768 | Bypasses `Renderer.cpp` dynamic GPU scaling pass on each display refresh/framebuffer init. | Script: `scripts/scale-wallpaper`<br>Target: `~/.config/hypr/` / wallpaper assets |
| **Default Terminal** | `kitty` | `foot` | Kitty requires full OpenGL 3.3 Core Profile which is incompatible with Kepler FL 11_0 over Mesa d3d12 Gallium. `foot` uses pure Wayland SHM / pixman CPU rendering with zero OpenGL version requirements. | `config/hyprland.lua`<br>`local terminal = "foot"` |
| **Status Bar (Waybar)** | Auto-launched on startup (`hl.on("hyprland.start", ...)`) | Removed from autostart | Reduces initial compositor overhead and GPU layer compositing load during initial bring-up. | `config/hyprland.lua`<br>`hl.on("hyprland.start")` block |
| **Frame Presentation** | Standard socket / pipe copy | Direct Access (DAX) Zero-Copy Shared Memory (`/mnt/wslgshm`) | Eliminates CPU-to-GPU and VM-to-Host memory copies; maps Hyprland output buffers directly into Windows DirectX 11 viewer at 6+ GB/s. | `systemd/mnt-wslgshm.mount`<br>`scripts/hyprland-session.sh` |

---

## 🔧 How to Re-enable Each Feature

### 1. Re-enabling Window Blur
In `~/.config/hypr/hyprland.lua` (or `config/hyprland.lua` in repo):
```lua
decoration = {
    blur = {
        enabled = true,
        size = 3,
        passes = 1,
    },
}
```

### 2. Re-enabling Drop Shadows
In `~/.config/hypr/hyprland.lua`:
```lua
decoration = {
    shadow = {
        enabled = true,
        range = 4,
        render_power = 3,
        color = "rgba(1a1a1aee)",
    },
}
```

### 3. Re-enabling Window & Workspace Animations
In `~/.config/hypr/hyprland.lua`:
```lua
animations = {
    enabled = true,
    bezier = "myBezier, 0.05, 0.9, 0.1, 1.05",
    animation = {
        "windows, 1, 7, myBezier",
        "windowsOut, 1, 7, default, popin 80%",
        "border, 1, 10, default",
        "fade, 1, 7, default",
        "workspaces, 1, 6, default",
    },
}
```

### 4. Re-enabling Splash Rendering
In `~/.config/hypr/hyprland.lua`:
```lua
misc = {
    disable_splash_rendering = false,
}
```

### 5. Restoring Kitty Terminal
If testing kitty or modern OpenGL terminal:
In `~/.config/hypr/hyprland.lua`:
```lua
local terminal = "kitty"
```
*(Note: Requires checking Mesa d3d12 Gallium OpenGL Core Profile compatibility with Kepler).*

### 6. Restoring Waybar Autostart
In `~/.config/hypr/hyprland.lua`:
```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("waybar")
end)
```
