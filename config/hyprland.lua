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
local terminal = "kitty"
local menu = "rofi -show drun"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("waybar")
    hl.exec_cmd(terminal)
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
        rounding = 6,
        active_opacity = 1.0,
        inactive_opacity = 0.95,
        blur = {
            enabled = false, -- Disabled for peak 60 FPS on GT 710
        },
    },
    animations = {
        enabled = false, -- Disabled for zero frame drops
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
hl.bind("SUPER + Q", function()
    hl.exec_cmd(terminal)
end)

hl.bind("SUPER + SPACE", function()
    hl.exec_cmd(menu)
end)

hl.bind("SUPER + C", function()
    hl.dispatch("killactive")
end)

-- Exit Hyprland session
hl.bind("SUPER + M", function()
    hl.dispatch("exit")
end)

hl.bind("SUPER + V", function()
    hl.dispatch("togglefloating")
end)

-- Focus Movement
hl.bind("SUPER + left", function() hl.dispatch("movefocus", "l") end)
hl.bind("SUPER + right", function() hl.dispatch("movefocus", "r") end)
hl.bind("SUPER + up", function() hl.dispatch("movefocus", "u") end)
hl.bind("SUPER + down", function() hl.dispatch("movefocus", "d") end)
hl.bind("SUPER + h", function() hl.dispatch("movefocus", "l") end)
hl.bind("SUPER + l", function() hl.dispatch("movefocus", "r") end)
hl.bind("SUPER + k", function() hl.dispatch("movefocus", "u") end)
hl.bind("SUPER + j", function() hl.dispatch("movefocus", "d") end)

-- Workspaces 1-5
for i = 1, 5 do
    local ws = tostring(i)
    hl.bind("SUPER + " .. ws, function() hl.dispatch("workspace", ws) end)
    hl.bind("SUPER + SHIFT + " .. ws, function() hl.dispatch("movetoworkspace", ws) end)
end
