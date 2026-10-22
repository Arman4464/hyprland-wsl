-- ~/.config/hypr/hyprland.lua
-- Official Hyprland Lua Configuration
-- Tuned for Rosewood Desktop Shell, 1366x768 @ 60Hz and NVIDIA GeForce GT 710 D3D12

------------------
---- MONITORS ----
------------------
hl.monitor({
    output = "WSL-1",
    mode = "1366x768@60",
    position = "0x0",
    scale = 1.0,
})

hl.monitor({
    output = "",
    mode = "1366x768@60",
    position = "0x0",
    scale = 1.0,
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal = "foot"
local menu = "rofi -show drun"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("bash -c 'awww-daemon & sleep 0.5 && /home/rango/.config/quickshell/scripts/daily_wallpaper.sh'")
    hl.exec_cmd("qs -p /home/rango/.config/quickshell")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("LIBGL_ALWAYS_SOFTWARE", "0")
hl.env("GALLIUM_DRIVER", "d3d12")
hl.env("MESA_LOADER_DRIVER_OVERRIDE", "d3d12")
hl.env("MESA_D3D12_DEFAULT_ADAPTER_NAME", "NVIDIA")
hl.env("WLR_RENDERER", "gles2")
hl.env("QSG_RHI_BACKEND", "opengl")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

---------------------------
---- GENERAL & OPTIONS ----
---------------------------
hl.config({
    general = {
        border_size = 2,
        gaps_in = 5,
        gaps_out = 10,
        layout = "dwindle",
        col = {
            active_border = { colors = {"rgba(D4B1ADee)", "rgba(654D4Aee)"}, angle = 45 },
            inactive_border = "rgba(221F1Faa)",
        },
    },
    decoration = {
        rounding = 8,
        active_opacity = 0.95,
        inactive_opacity = 0.85,
        blur = {
            enabled = true,
            size = 2,
            passes = 1,
            new_optimizations = true,
            xray = false,
            popups = false,
            ignore_opacity = true,
        },
        shadow = {
            enabled = true,
            range = 4,
            render_power = 1,
            color = "rgba(1a1a1a66)",
        },
    },
    animations = {
        enabled = true,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        background_color = "0x030000",
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
    },
    debug = {
        disable_logs = true,
        enable_stdout_logs = false,
    },
})

---------------------
---- LAYER RULES ----
---------------------
-- Kepler GT 710 Optimization:
-- Layer surfaces (Quickshell pill, notifications, desktop bar) have no_anim and blur disabled.
-- This guarantees zero expensive makeSnapshotFB framebuffer snapshot overhead on GT 710 Kepler,
-- ensuring locked 60 FPS while application windows (foot, rofi, zen) enjoy smooth dual-kawase blur.

hl.layer_rule({
    name = "quickshell-perf",
    match = { namespace = "^quickshell.*" },
    no_anim = true,
    blur = false,
    blur_popups = false,
})

hl.layer_rule({
    name = "all-layers-perf",
    match = { namespace = ".*" },
    no_anim = true,
    blur = false,
    blur_popups = false,
})

--------------------
---- ANIMATIONS ----
--------------------
-- Snappy, punchy animations (120-180ms) for instant responsiveness without GPU damage readback stalls
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("fluent_decel", { type = "bezier", points = { {0.1, 1}, {0, 1} } })

hl.animation({ leaf = "global", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "fluent_decel", style = "popin 80%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "fluent_decel", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "fluent_decel", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "layers", enabled = false })
hl.animation({ leaf = "layersIn", enabled = false })
hl.animation({ leaf = "layersOut", enabled = false })
hl.animation({ leaf = "fadeLayersIn", enabled = false })
hl.animation({ leaf = "fadeLayersOut", enabled = false })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slide" })

------------------
---- KEYBINDS ----
------------------
-- Single SUPER tap brings up the Windows Start Menu
hl.bind("SUPER + Super_L", hl.dsp.exec_cmd("/mnt/e/RangoWorkspace/bin/open-start.exe"), { release = true })
hl.bind("SUPER + Super_R", hl.dsp.exec_cmd("/mnt/e/RangoWorkspace/bin/open-start.exe"), { release = true })

-- Applications
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + Q", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + B", hl.dsp.exec_cmd("zen"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("foot -e nvim"))
hl.bind("SUPER + P", hl.dsp.exec_cmd("foot -e rmpc"))

-- Rosewood Quickshell Controls
hl.bind("SUPER + R", hl.dsp.exec_cmd("qs ipc call pill setState appLauncher"))
hl.bind("SUPER + W", hl.dsp.exec_cmd("qs ipc call pill setState wallpaper"))
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("qs ipc call pill setState powermenu"))

-- Linux Lock Screen (SUPER + SHIFT + L ensures Windows never intercepts Win+L, locking Linux only!)
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("/home/rango/.config/quickshell/lockscreen/lock.sh"))

-- Screenshot
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd([[bash -c 'geom=$(slurp) && [ -n "$geom" ] && file="$HOME/Pictures/Screenshots/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png" && grim -g "$geom" "$file" && wl-copy -t image/png < "$file"']]))

-- Window controls
hl.bind("SUPER + C", hl.dsp.window.close())
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))

-- Exit Hyprland session
hl.bind("SUPER + M", hl.dsp.exit())

-- Focus Movement
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-5
for i = 1, 5 do
    local ws = tostring(i)
    hl.bind("SUPER + " .. ws, hl.dsp.focus({ workspace = ws }))
    hl.bind("SUPER + SHIFT + " .. ws, hl.dsp.window.move({ workspace = ws }))
end

-- Mouse bindings
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { drag = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { drag = true })
