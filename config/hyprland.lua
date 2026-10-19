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
    },
    decoration = {
        rounding = 4,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        blur = {
            enabled = false, -- Disabled for peak 60 FPS on GT 710
        },
        shadow = {
            enabled = false, -- Disabled to prevent multi-pass GPU shadow blur
        },
    },
    animations = {
        enabled = false, -- Disabled for zero frame drops on Kepler FL 11_0
    },
    misc = {
        disable_hyprland_logo = true,    -- Stops Hyprland from scaling massive 8K wallpaper on GT 710
        disable_splash_rendering = true, -- Stops splash text allocation
        force_default_wallpaper = 0,
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
-- Applications
hl.bind("SUPER + RETURN", function()
    hl.exec_cmd(terminal)
end)

hl.bind("SUPER + Q", function()
    hl.exec_cmd(terminal)
end)

hl.bind("SUPER + SPACE", function()
    hl.exec_cmd(menu)
end)

-- Window controls
hl.bind("SUPER + C", hl.dsp.window.close())
hl.bind("SUPER + V", hl.dsp.window.float())

-- Exit Hyprland session (original single keybinding)
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
