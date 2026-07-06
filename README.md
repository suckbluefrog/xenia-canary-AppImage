<div align="center">

# xenia-canary-AppImage 🐧

[![GitHub Downloads](https://img.shields.io/github/downloads/pkgforge-dev/xenia-canary-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/pkgforge-dev/xenia-canary-AppImage/releases/latest)
[![CI Build Status](https://github.com//pkgforge-dev/xenia-canary-AppImage/actions/workflows/appimage.yml/badge.svg)](https://github.com/pkgforge-dev/xenia-canary-AppImage/releases/latest)
[![Latest Release](https://img.shields.io/github/v/release/pkgforge-dev/xenia-canary-AppImage)](https://github.com/pkgforge-dev/xenia-canary-AppImage/releases/latest)

<p align="center">
  <img src="https://github.com/xenia-canary/xenia-canary/blob/canary_experimental/assets/icon/128.png" width="128" />
</p>


| Latest Release | Upstream URL |
| :---: | :---: |
| [Click here](https://github.com/pkgforge-dev/xenia-canary-AppImage/releases/latest) | [Click here](https://github.com/xenia-canary/xenia-canary) |

</div>

---

AppImage made using [sharun](https://github.com/VHSgunzo/sharun) and its wrapper [quick-sharun](https://github.com/pkgforge-dev/Anylinux-AppImages/blob/main/useful-tools/quick-sharun.sh), which makes it extremely easy to turn any binary into a portable package reliably without using containers or similar tricks.

**The ARM64 AppImage is experimental/debug-focused.** It is not a production-quality sealed runtime, and it intentionally relies on the host Mesa/Vulkan graphics stack via `USE_HOST_MESA_DRIVERS=1`.

This avoids bundling and validating one GPU driver stack across Adreno, Mali, RADV, and other ARM64 targets. For a validated target, the runtime image should own the graphics stack and avoid mixing host ICDs with unmatched bundled Mesa/libdrm/LLVM pieces.

The x86_64 AppImage follows the normal portable AppImage packaging model.

This AppImage doesn't require FUSE to run at all, thanks to the [uruntime](https://github.com/VHSgunzo/uruntime).

This AppImage is also supplied with a self-updater by default, so any updates to this application won't be missed, you will be promted for permission to check for updates and if agreed you will then be notified when a new update is available.

Self-updater is disabled by default if AppImage managers like [am](https://github.com/ivan-hc/AM), [soar](https://github.com/pkgforge/soar) or [dbin](https://github.com/xplshn/dbin) exist, which manage AppImage updates.

<details>
  <summary><b><i>raison d'être</i></b></summary>
    <img src="https://github.com/user-attachments/assets/d40067a6-37d2-4784-927c-2c7f7cc6104b" alt="Inspiration Image">
  </a>
</details>

---

More at: [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/)
