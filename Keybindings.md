# ⌨️ Hyprland WSL 2 & Rosewood Rice — Keybindings Cheat Sheet

> **Note:** **`SUPER`** refers to the physical **Windows Key** (<kbd>⊞ Win</kbd>).

---

## 1. System & Windows 11 Bridge

| Shortcut | Action | Component / Details |
| :--- | :--- | :--- |
| **Single <kbd>SUPER</kbd>** *(Tap alone)* | **Windows 11 Start Menu** | Minimizes viewer and pops up Windows Start Menu (`open-start.exe`) |
| <kbd>SUPER</kbd> + <kbd>M</kbd> | **Exit Hyprland** | Clean compositor & session shutdown back to Windows |
| <kbd>ALT</kbd> + <kbd>TAB</kbd> | **Windows Task Switcher** | Instantly releases capture, minimizes viewer, and switches to Windows apps |
| <kbd>CTRL</kbd> + <kbd>ALT</kbd> + <kbd>END</kbd> | **Emergency Detach** | Minimizes / detaches Hyprland viewer window |

---

## 2. Applications

| Shortcut | Action | Details |
| :--- | :--- | :--- |
| <kbd>SUPER</kbd> + <kbd>RETURN</kbd> | **Foot Terminal** | GPU-accelerated Wayland terminal (88% opacity with dual-kawase blur) |
| <kbd>SUPER</kbd> + <kbd>Q</kbd> | **Foot Terminal** (Alternative) | Fast terminal access |
| <kbd>SUPER</kbd> + <kbd>B</kbd> | **Zen Browser** | Native browser (`/usr/local/bin/zen`) |
| <kbd>SUPER</kbd> + <kbd>E</kbd> | **Neovim** | Code editor (`foot -e nvim`) |
| <kbd>SUPER</kbd> + <kbd>P</kbd> | **RMPC Music Player** | Terminal music player (`foot -e rmpc`) |
| <kbd>SUPER</kbd> + <kbd>SPACE</kbd> | **Rofi Application Drawer** | Dynamic Material You categorized menu |

---

## 3. Rosewood Desktop Shell (Quickshell)

| Shortcut | Action | What It Does |
| :--- | :--- | :--- |
| <kbd>SUPER</kbd> + <kbd>R</kbd> | **Rosewood Pill Launcher** | 2-column app drawer with search, `=math`, and `:bash` |
| <kbd>SUPER</kbd> + <kbd>W</kbd> | **Wallpaper Picker** | Visual grid of all 19 wallpapers (applies + recolors system) |
| <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>P</kbd> | **Power Menu** | Floating Power · Reboot · Suspend · Lock pill |
| <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>L</kbd> | **Lock Screen** | Freezes Linux display, applies blurred wallpaper & PAM auth (Linux only, no Windows double lock) |
| **Hover on Top Pill** | **Hover Dashboard** | Expands pill into Clock, Media, Storage/RAM, Quick Toggles (instant 200ms) |

---

## 4. Window Management & Tiling

| Shortcut | Action |
| :--- | :--- |
| <kbd>SUPER</kbd> + <kbd>C</kbd> | **Close** active window |
| <kbd>SUPER</kbd> + <kbd>V</kbd> | **Toggle Floating** mode for active window |
| <kbd>SUPER</kbd> + <kbd>←</kbd> / <kbd>→</kbd> / <kbd>↑</kbd> / <kbd>↓</kbd> | Move focus in direction (Arrow keys) |
| <kbd>SUPER</kbd> + <kbd>H</kbd> / <kbd>L</kbd> / <kbd>K</kbd> / <kbd>J</kbd> | Move focus in direction (Vim keys) |
| <kbd>SUPER</kbd> + **Left Click Drag** | Move / reposition window |
| <kbd>SUPER</kbd> + **Right Click Drag** | Resize window |

---

## 5. Workspaces (1–5)

| Shortcut | Action |
| :--- | :--- |
| <kbd>SUPER</kbd> + <kbd>1</kbd> … <kbd>5</kbd> | Switch to Workspace 1, 2, 3, 4, or 5 (smooth slide) |
| <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>1</kbd> … <kbd>5</kbd> | Move active window to Workspace 1–5 |

---

## 6. Screenshots

| Shortcut | Action |
| :--- | :--- |
| <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>S</kbd> | Select screen area (`slurp`), capture with `grim`, save timestamped PNG to `~/Pictures/Screenshots/`, and copy image to clipboard |

---

## 7. In-Component Navigation Keys

### In Rosewood App Launcher (<kbd>SUPER</kbd> + <kbd>R</kbd>):
* `/` — Focus search input
* `=12*4` — Instant calculator mode
* `:htop` — Direct bash execution mode
* <kbd>↑</kbd> / <kbd>↓</kbd> / <kbd>←</kbd> / <kbd>→</kbd> or `h`/`j`/`k`/`l` — Navigate application grid
* <kbd>Enter</kbd> — Launch selected application
* <kbd>Esc</kbd> — Clear search / collapse back to clock pill

### In Rosewood Wallpaper Picker (<kbd>SUPER</kbd> + <kbd>W</kbd>):
* `/` — Search wallpapers
* <kbd>Arrow Keys</kbd> or `h`/`j`/`k`/`l` — Move through wallpaper thumbnails
* <kbd>Enter</kbd> — Apply wallpaper live via `awww` and trigger Material You color retheme
* <kbd>Esc</kbd> — Close picker

### In Rosewood Power Menu (<kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>P</kbd>):
* <kbd>←</kbd> / <kbd>→</kbd> or `h`/`l` — Select Power, Reboot, Suspend, or Lock
* <kbd>Enter</kbd> or <kbd>Space</kbd> — Execute action
* <kbd>Esc</kbd> — Cancel
