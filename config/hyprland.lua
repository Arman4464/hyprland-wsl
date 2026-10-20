-- ~/.config/hypr/hyprland.lua
-- Official Hyprland Lua Configuration
-- Tuned for 1366x768 @ 60Hz and NVIDIA GeForce GT 710 Direct3D 12 acceleration

------------------
---- MONITORS ----
------------------
hl.monitor({
    output = "WSL-1",
    mode = "1366x768@60",
    position = "0x0",
    scale = 1.0,
})

-- Wildcard fallback for any monitor output
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
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

---------------------------
---- GENERAL & OPTIONS ----
---------------------------
hl.config({
    general = {
        border_size = 2,
        gaps_in = 4,
        gaps_out = 8,
        layout = "dwindle",
        col = {
            active_border = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
    },
    decoration = {
        rounding = 6,
        active_opacity = 1.0,
        inactive_opacity = 0.95,
        blur = {
            enabled = false, -- Disabled for peak 60 FPS on GT 710
        },
        shadow = {
            enabled = false, -- Disabled to maximize GT 710 fillrate and eliminate shader passes
        },
    },
    animations = {
        enabled = false, -- Disabled for zero frame drops on Kepler FL 11_0
    },
    misc = {
        disable_hyprland_logo = false,   -- Enabled: wallpapers pre-scaled to 1366x768 (zero runtime scaling lag)
        disable_splash_rendering = true, -- Stops splash text allocation
        force_default_wallpaper = 2,     -- 0: classic anime, 1: dark minimal, 2: anime aesthetic, -1: random
        background_color = "0x11111b",
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
    },
    debug = {
        disable_logs = false,
        enable_stdout_logs = true,
    },
})

------------------
---- KEYBINDS ----
------------------
-- Single SUPER tap brings up the Windows Start Menu
hl.bind("SUPER + Super_L", hl.dsp.exec_cmd("/mnt/d/RangoWorkspace/bin/open-start.exe"), { release = true })
hl.bind("SUPER + Super_R", hl.dsp.exec_cmd("/mnt/d/RangoWorkspace/bin/open-start.exe"), { release = true })

-- Applications (direct C++ dispatchers for instant response)
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + Q", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + R", hl.dsp.exec_cmd(menu))

-- Screenshot (selects area, saves to ~/Pictures/Screenshots/ and copies to clipboard)
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd([[bash -c 'geom=$(slurp) && [ -n "$geom" ] && file="$HOME/Pictures/Screenshots/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png" && grim -g "$geom" "$file" && wl-copy -t image/png < "$file"']]))

-- Window controls
hl.bind("SUPER + C", hl.dsp.window.close())
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))

-- Exit Hyprland session (clean compositor shutdown returning to terminal)
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

-- Mouse bindings (drag/resize floating windows)
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { drag = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { drag = true })
