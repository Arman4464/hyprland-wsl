#!/bin/bash

WALLPAPER_PATH="$1"

if [ -z "$WALLPAPER_PATH" ]; then
    WALLPAPER_PATH=$(cat "$HOME/.cache/wallpaper_state.txt" 2>/dev/null || echo "/home/rango/Pictures/Wallpapers/wallpaper_01.png")
fi

if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "Error: Wallpaper not found at $WALLPAPER_PATH"
    exit 1
fi

# Set wallpaper with awww daemon using fast, lightweight 0.3s fade transition
if command -v awww >/dev/null 2>&1; then
    awww img "$WALLPAPER_PATH" --transition-type "fade" --transition-duration 0.3 --transition-fps 60 2>/dev/null || true
fi

# Retheme system with Material You color engine
SCRIPT_PATH="/home/rango/.config/quickshell/scripts/WallustAwww.sh"
if [ -f "$SCRIPT_PATH" ]; then
    bash "$SCRIPT_PATH" "$WALLPAPER_PATH"
else
    python3 /home/rango/.config/quickshell/scripts/extract_colors.py "$WALLPAPER_PATH"
    qs ipc call theme reload 2>/dev/null || true
fi

pkill -USR1 kitty 2>/dev/null || true
pkill -USR1 cava 2>/dev/null || true
pkill -USR1 foot 2>/dev/null || true
