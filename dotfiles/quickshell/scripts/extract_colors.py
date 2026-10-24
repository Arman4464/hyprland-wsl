#!/usr/bin/env python3
"""
extract_colors.py
Extracts dominant Material You palette from wallpaper image using Pillow.
Updates:
  - ~/.config/quickshell/core/Logic/WallustColors.js
  - ~/.config/rofi/colors.rasi
  - ~/.config/foot/foot.ini
"""

import sys
import os
import colorsys
from pathlib import Path
from PIL import Image

def rgb_to_hex(r, g, b):
    return f"#{int(r):02x}{int(g):02x}{int(b):02x}"

def hsl_to_rgb(h, s, l):
    # h in [0, 1], s in [0, 1], l in [0, 1]
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return int(round(r * 255)), int(round(g * 255)), int(round(b * 255))

def rgb_to_hsl(r, g, b):
    h, l, s = colorsys.rgb_to_hls(r / 255.0, g / 255.0, b / 255.0)
    return h, s, l

def extract_palette(image_path):
    img = Image.open(image_path).convert("RGB")
    # Resize to speed up calculation
    img = img.resize((150, 150), Image.Resampling.BILINEAR)

    # Quantize to 24 colors
    quantized = img.quantize(colors=24, method=Image.Quantize.FASTOCTREE)
    palette = quantized.getpalette()[:24*3]
    color_counts = quantized.getcolors()

    # Sort colors by frequency
    sorted_colors = sorted(color_counts, key=lambda x: x[0], reverse=True)

    candidates = []
    for count, idx in sorted_colors:
        r = palette[idx*3]
        g = palette[idx*3 + 1]
        b = palette[idx*3 + 2]
        h, s, l = rgb_to_hsl(r, g, b)
        # Skip pure black, pure white, and near-greys when searching for seed
        candidates.append({
            "count": count,
            "rgb": (r, g, b),
            "hsl": (h, s, l),
            "score": count * (s ** 1.2) * (1.0 - abs(l - 0.55) * 1.5)
        })

    # Pick primary seed with best vibrancy/frequency score
    scored = [c for c in candidates if c["hsl"][1] > 0.15 and 0.15 < c["hsl"][2] < 0.85]
    if scored:
        scored.sort(key=lambda x: x["score"], reverse=True)
        primary_candidate = scored[0]
    else:
        # Fallback to most frequent non-extreme color
        primary_candidate = candidates[0]

    prim_h, prim_s, prim_l = primary_candidate["hsl"]

    # Pick secondary seed: different hue or moderate saturation
    sec_candidates = [
        c for c in candidates 
        if abs(c["hsl"][0] - prim_h) > 0.08 and c["hsl"][1] > 0.10
    ]
    if sec_candidates:
        sec_candidates.sort(key=lambda x: x["score"], reverse=True)
        sec_h, sec_s, _ = sec_candidates[0]["hsl"]
    else:
        sec_h = (prim_h + 0.08) % 1.0
        sec_s = max(0.2, prim_s * 0.7)

    # Pick tertiary seed: accent / complementary hue
    tert_candidates = [
        c for c in candidates 
        if abs(c["hsl"][0] - prim_h) > 0.20 and abs(c["hsl"][0] - sec_h) > 0.10 and c["hsl"][1] > 0.10
    ]
    if tert_candidates:
        tert_candidates.sort(key=lambda x: x["score"], reverse=True)
        tert_h, tert_s, _ = tert_candidates[0]["hsl"]
    else:
        tert_h = (prim_h + 0.35) % 1.0
        tert_s = max(0.25, prim_s * 0.8)

    # Construct Material You Dark Theme Palette
    palette_map = {}

    # Neutral Dark Surfaces
    palette_map["background"] = rgb_to_hex(*hsl_to_rgb(prim_h, prim_s * 0.18, 0.05))
    palette_map["surface"] = rgb_to_hex(*hsl_to_rgb(prim_h, prim_s * 0.20, 0.10))
    palette_map["surface_container"] = rgb_to_hex(*hsl_to_rgb(prim_h, prim_s * 0.22, 0.14))
    palette_map["surface_variant"] = rgb_to_hex(*hsl_to_rgb(prim_h, prim_s * 0.22, 0.20))

    # Readable Text & Overlays
    palette_map["on_background"] = rgb_to_hex(*hsl_to_rgb(prim_h, prim_s * 0.10, 0.90))
    palette_map["on_surface"] = rgb_to_hex(*hsl_to_rgb(prim_h, prim_s * 0.10, 0.90))
    palette_map["on_surface_variant"] = rgb_to_hex(*hsl_to_rgb(prim_h, prim_s * 0.15, 0.78))

    # Primary Tone (Tone 80 in dark theme)
    palette_map["primary"] = rgb_to_hex(*hsl_to_rgb(prim_h, min(1.0, max(0.40, prim_s * 1.1)), 0.76))
    palette_map["on_primary"] = rgb_to_hex(*hsl_to_rgb(prim_h, prim_s * 0.8, 0.20))
    palette_map["primary_container"] = rgb_to_hex(*hsl_to_rgb(prim_h, prim_s * 0.7, 0.32))
    palette_map["on_primary_container"] = rgb_to_hex(*hsl_to_rgb(prim_h, prim_s * 0.8, 0.92))
    palette_map["inverse_primary"] = rgb_to_hex(*hsl_to_rgb(prim_h, prim_s * 0.8, 0.42))

    # Secondary Tone
    palette_map["secondary"] = rgb_to_hex(*hsl_to_rgb(sec_h, min(1.0, max(0.30, sec_s * 0.9)), 0.74))
    palette_map["on_secondary"] = rgb_to_hex(*hsl_to_rgb(sec_h, sec_s * 0.7, 0.20))
    palette_map["secondary_container"] = rgb_to_hex(*hsl_to_rgb(sec_h, sec_s * 0.6, 0.30))
    palette_map["on_secondary_container"] = rgb_to_hex(*hsl_to_rgb(sec_h, sec_s * 0.7, 0.90))

    # Tertiary Tone
    palette_map["tertiary"] = rgb_to_hex(*hsl_to_rgb(tert_h, min(1.0, max(0.35, tert_s * 0.9)), 0.74))
    palette_map["on_tertiary"] = rgb_to_hex(*hsl_to_rgb(tert_h, tert_s * 0.7, 0.20))
    palette_map["tertiary_container"] = rgb_to_hex(*hsl_to_rgb(tert_h, tert_s * 0.6, 0.30))
    palette_map["on_tertiary_container"] = rgb_to_hex(*hsl_to_rgb(tert_h, tert_s * 0.7, 0.90))

    # Standard Material Error Tones
    palette_map["error"] = "#ffb3b0"
    palette_map["on_error"] = "#522122"
    palette_map["error_container"] = "#8e1126"
    palette_map["on_error_container"] = "#ffdad8"

    # Accents & Borders
    palette_map["outline"] = rgb_to_hex(*hsl_to_rgb(prim_h, prim_s * 0.15, 0.50))
    palette_map["shadow"] = "#000000"
    palette_map["inverse_surface"] = rgb_to_hex(*hsl_to_rgb(prim_h, prim_s * 0.10, 0.90))
    palette_map["inverse_on_surface"] = rgb_to_hex(*hsl_to_rgb(prim_h, prim_s * 0.20, 0.18))

    return palette_map

def write_wallust_colors_js(colors, output_path):
    lines = [
        "//this file is generated by extract_colors.py using the material-you palette",
        "",
        f'var background = "{colors["background"]}"',
        f'var on_background = "{colors["on_background"]}"',
        f'var surface = "{colors["surface"]}"',
        f'var surface_variant = "{colors["surface_variant"]}"',
        f'var on_surface = "{colors["on_surface"]}"',
        f'var on_surface_variant = "{colors["on_surface_variant"]}"',
        f'var primary = "{colors["primary"]}"',
        f'var on_primary = "{colors["on_primary"]}"',
        f'var primary_container = "{colors["primary_container"]}"',
        f'var on_primary_container = "{colors["on_primary_container"]}"',
        f'var secondary = "{colors["secondary"]}"',
        f'var on_secondary = "{colors["on_secondary"]}"',
        f'var secondary_container = "{colors["secondary_container"]}"',
        f'var on_secondary_container = "{colors["on_secondary_container"]}"',
        f'var tertiary = "{colors["tertiary"]}"',
        f'var on_tertiary = "{colors["on_tertiary"]}"',
        f'var tertiary_container = "{colors["tertiary_container"]}"',
        f'var on_tertiary_container = "{colors["on_tertiary_container"]}"',
        f'var error = "{colors["error"]}"',
        f'var on_error = "{colors["on_error"]}"',
        f'var error_container = "{colors["error_container"]}"',
        f'var on_error_container = "{colors["on_error_container"]}"',
        f'var outline = "{colors["outline"]}"',
        f'var shadow = "{colors["shadow"]}"',
        f'var inverse_surface = "{colors["inverse_surface"]}"',
        f'var inverse_on_surface = "{colors["inverse_on_surface"]}"',
        f'var inverse_primary = "{colors["inverse_primary"]}"',
        f'var surface_container = "{colors["surface_container"]}"',
        ""
    ]
    with open(output_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

def write_rofi_colors(colors, output_path):
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    content = f"""* {{
    bg: {colors['background']};
    fg: {colors['on_surface']};
    accent: {colors['primary']};
    selected: {colors['surface_variant']};
    border-col: {colors['primary']};
    surface: {colors['surface']};
    surface-variant: {colors['surface_variant']};
    background-color: @bg;
    text-color: @fg;
}}
"""
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(content)

def update_foot_ini(colors, ini_path):
    def raw_hex(c):
        return c.lstrip("#").lower()

    content = f"""# ~/.config/foot/foot.ini
# Rosewood-matched Foot Terminal Configuration

[main]
font=JetBrainsMono Nerd Font:size=11
pad=12x12 center

[colors]
alpha=0.88
background={raw_hex(colors['background'])}
foreground={raw_hex(colors['on_surface'])}

## Regular colors (Rosewood Material palette)
regular0={raw_hex(colors['surface'])}
regular1={raw_hex(colors['error'])}
regular2={raw_hex(colors['secondary'])}
regular3={raw_hex(colors['tertiary'])}
regular4={raw_hex(colors['primary'])}
regular5={raw_hex(colors['on_primary_container'])}
regular6={raw_hex(colors['on_surface_variant'])}
regular7={raw_hex(colors['on_background'])}

## Bright colors
bright0={raw_hex(colors['surface_variant'])}
bright1={raw_hex(colors['on_error_container'])}
bright2={raw_hex(colors['on_secondary_container'])}
bright3={raw_hex(colors['on_tertiary_container'])}
bright4={raw_hex(colors['primary_container'])}
bright5=ffffff
bright6=ffffff
bright7=ffffff

[cursor]
style=beam
color={raw_hex(colors['background'])} {raw_hex(colors['primary'])}
blink=yes
"""
    os.makedirs(os.path.dirname(ini_path), exist_ok=True)
    with open(ini_path, "w", encoding="utf-8") as f:
        f.write(content)

def main():
    home = Path.home()
    if len(sys.argv) > 1 and sys.argv[1]:
        wallpaper_path = sys.argv[1]
    else:
        state_file = home / ".cache" / "wallpaper_state.txt"
        if state_file.exists():
            wallpaper_path = state_file.read_text(encoding="utf-8").strip()
        else:
            wallpaper_path = str(home / "Pictures" / "Wallpapers" / "wallpaper_01.png")

    if not os.path.exists(wallpaper_path):
        print(f"Error: Wallpaper '{wallpaper_path}' not found!", file=sys.stderr)
        sys.exit(1)

    print(f"Extracting Material You colors from: {wallpaper_path}")
    colors = extract_palette(wallpaper_path)

    # 1. Quickshell WallustColors.js
    js_path = home / ".config" / "quickshell" / "core" / "Logic" / "WallustColors.js"
    write_wallust_colors_js(colors, js_path)
    print(f"Updated: {js_path}")

    # 2. Rofi colors.rasi
    rofi_path = home / ".config" / "rofi" / "colors.rasi"
    write_rofi_colors(colors, rofi_path)
    print(f"Updated: {rofi_path}")

    # 3. Foot foot.ini
    foot_path = home / ".config" / "foot" / "foot.ini"
    update_foot_ini(colors, foot_path)
    print(f"Updated: {foot_path}")

    print("Dynamic color extraction completed successfully!")

if __name__ == "__main__":
    main()
