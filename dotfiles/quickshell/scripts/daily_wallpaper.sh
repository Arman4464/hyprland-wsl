#!/bin/bash
# daily_wallpaper.sh - Daily wallpaper rotation for Rosewood desktop
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

DAY=$(date +%j)
NUM=$(( (10#$DAY % 19) + 1 ))
INDEX_STR=$(printf "%02d" "$NUM")
SELECTED_WALLPAPER="$WALLPAPER_DIR/wallpaper_${INDEX_STR}.png"

if [ ! -f "$SELECTED_WALLPAPER" ]; then
    # Fallback if specific numbered wallpaper is missing
    SELECTED_WALLPAPER="$WALLPAPER_DIR/wallpaper_01.png"
fi

echo "Day of year: $DAY -> Selected wallpaper ($INDEX_STR): $SELECTED_WALLPAPER"

# Apply wallpaper and retheme desktop
APPLY_SCRIPT="$HOME/.config/quickshell/scripts/ApplyWallpaper.sh"
if [ -f "$APPLY_SCRIPT" ]; then
    bash "$APPLY_SCRIPT" "$SELECTED_WALLPAPER"
else
    echo "$SELECTED_WALLPAPER" > "$HOME/.cache/wallpaper_state.txt"
    python3 "$HOME/.config/quickshell/scripts/extract_colors.py" "$SELECTED_WALLPAPER"
    qs ipc call theme reload 2>/dev/null || true
fi
