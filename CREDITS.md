# Acknowledgements & Credits

This project builds upon the groundbreaking engineering work of several open-source contributors:

### 1. Upstream Hyprland & Aquamarine
- **Vaxry & the Hyprwm Organization** ([github.com/hyprwm](https://github.com/hyprwm))
  - Creators of the incredible [Hyprland](https://github.com/hyprwm/Hyprland) Wayland compositor and the [Aquamarine](https://github.com/hyprwm/aquamarine) rendering abstraction backend library.

### 2. The Omarchy / Womarchy Project
- **Shital Shah & the Womarchy Contributors** ([github.com/sytelus/womarchy](https://github.com/sytelus/womarchy))
  - Pioneered the DRM-free surfaceless EGL rendering architecture and the WSL `AF_VSOCK` display protocol.
  - Engineered the virtio-fs DAX section shared memory pipeline (`/mnt/wslgshm`) interfacing with Windows `OpenFileMappingW`.
  - Authored the core companion DirectX 11 presenter window and the initial patch sets for Aquamarine and Hyprland.
  - Full technical background and development journey: [sytelus/womarchy docs/JOURNEY.md](https://github.com/sytelus/womarchy/blob/main/docs/JOURNEY.md).

---
*All copyrights, logos, and trademarks belong to their respective project maintainers.*
