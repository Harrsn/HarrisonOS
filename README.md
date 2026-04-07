# HarrisonOS — Custom Debian-Based Linux Distribution

A fully customizable Debian Bookworm-based distribution with KDE Plasma desktop,
built using `live-build`. Produces a bootable/installable ISO you can share.

---

## Setting Up Your Build Machine (Second PC)

Since your main workstation is Windows 11, use your second PC as a dedicated
build machine. You need a Debian or Ubuntu install on it.

### Option A: Install Debian 12 (Bookworm) — Recommended
1. Download the netinst ISO: https://www.debian.org/download
2. Flash to USB: use [Rufus](https://rufus.ie/) on your Windows PC
3. Boot the second PC from USB, install Debian with minimal/server profile
4. After install, SSH into it from your Windows PC:
   ```
   ssh user@<second-pc-ip>
   ```

### Option B: Use a VM on your Windows PC
If you'd rather not dedicate the second PC:
```powershell
# Windows — install WSL2 with Debian
wsl --install -d Debian
```
Note: WSL2 works but can be slower for disk-heavy builds. A real Debian
install on the second PC is ideal.

### Once you have a Debian/Ubuntu environment:
```bash
# Install build dependencies
sudo apt update && sudo apt install -y \
    live-build debootstrap squashfs-tools xorriso \
    grub-pc-bin grub-efi-amd64-bin mtools dosfstools \
    git python3 python3-pip

# Clone the repo
git clone https://github.com/YOUR_USERNAME/HarrisonOS.git
cd HarrisonOS
```

---

## Quick Start

```bash
# 1. Run setup (configures live-build)
chmod +x setup.sh
./setup.sh

# 2. Build the ISO (20-60 min depending on hardware + internet)
cd build
sudo lb build 2>&1 | tee build.log

# 3. Your ISO is ready!
ls -lh HarrisonOS-*.iso
```

## Testing the ISO

```bash
# QEMU (install: sudo apt install qemu-system-x86)
qemu-system-x86_64 -m 4096 -cdrom build/HarrisonOS-1.0-amd64.hybrid.iso \
    -boot d -enable-kvm -smp 4

# Or write to USB (replace /dev/sdX with your USB device!)
sudo dd if=build/HarrisonOS-1.0-amd64.hybrid.iso of=/dev/sdX bs=4M status=progress sync
```

---

## Project Structure

```
HarrisonOS/
├── README.md
├── setup.sh                            # Configures live-build
├── config/
│   ├── package-lists/
│   │   └── desktop.list.chroot         # All packages to include
│   ├── hooks/
│   │   └── live/
│   │       └── 0100-customize.hook.chroot  # System customization script
│   └── includes.chroot/                # Files overlaid onto the filesystem
│       ├── etc/
│       │   ├── hostname
│       │   ├── os-release
│       │   ├── issue
│       │   └── skel/                   # Default home directory template
│       │       └── .config/
│       │           ├── autostart/
│       │           │   └── welcome.desktop
│       │           └── plasma-org.kde.plasma.desktop-appletsrc
│       └── usr/
│           └── share/
│               └── wallpapers/
│                   └── harrisonos/
├── branding/
│   └── wallpaper.py                    # Wallpaper generator (requires Pillow)
├── .github/
│   └── workflows/
│       └── build-iso.yml               # GitHub Actions CI pipeline
└── .gitignore
```

---

## Customization

### Add/remove packages
Edit `config/package-lists/desktop.list.chroot` — one package per line.

### Change system settings
Edit `config/hooks/live/0100-customize.hook.chroot` — this runs inside the
chroot during build. Anything you can do in a shell script, you can do here.

### Add files to the ISO
Drop them in `config/includes.chroot/` mirroring the target path:
- `config/includes.chroot/usr/local/bin/my-tool` → `/usr/local/bin/my-tool`
- `config/includes.chroot/etc/my-app.conf` → `/etc/my-app.conf`

### Rebuild after changes
```bash
cd build
sudo lb clean       # Clean previous build (keeps package cache)
sudo lb build 2>&1 | tee build.log
```

### Full clean rebuild (if things break)
```bash
cd build
sudo lb clean --purge
cd ..
./setup.sh
cd build
sudo lb build 2>&1 | tee build.log
```

---

## CI/CD Pipeline

The project includes a GitHub Actions workflow that automatically builds the
ISO on every push to `main` or when you create a tag.

### Setup
1. Push this repo to GitHub
2. The workflow runs automatically
3. Tagged releases (e.g., `v1.0`) upload the ISO as a GitHub Release asset

### Trigger a release
```bash
git tag v1.0
git push origin v1.0
```

The ISO will be built and attached to the GitHub Release page for download.

---

## Tips

- **Build on the second PC** over SSH from your Windows machine for the best
  experience — edit on Windows, build on Linux.
- **Use VS Code Remote SSH** to edit files directly on the build machine.
- First build downloads ~2-3 GB of packages. Subsequent builds use the cache.
- Build needs ~15-20 GB free disk space.
- `sudo lb clean` (without `--purge`) keeps the package cache for fast rebuilds.
