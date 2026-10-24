#!/bin/bash
mkdir -p "$HOME/.cache" "$HOME/.config/rofi"

if [ -n "$1" ]; then
  wallpaper_path="$1"
else
  wallpaper_path=$(cat "$HOME/.cache/wallpaper_state.txt" 2>/dev/null || echo "/home/rango/Pictures/Wallpapers/wallpaper_01.png")
fi

echo "$wallpaper_path" > "$HOME/.cache/wallpaper_state.txt"
ln -sf "$wallpaper_path" "$HOME/.config/rofi/.current_wallpaper"

# Run our automated Material You color extraction engine
if [ -f "/home/rango/.config/quickshell/scripts/extract_colors.py" ]; then
    python3 /home/rango/.config/quickshell/scripts/extract_colors.py "$wallpaper_path"
fi

# Fallback/optional wallust if present
if command -v wallust >/dev/null 2>&1; then
    wallust run "$wallpaper_path" -q 2>/dev/null || true
fi

# Reload quickshell theme via IPC
qs ipc call theme reload 2>/dev/null || true
