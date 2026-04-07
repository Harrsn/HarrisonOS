<p align="center">
  <img src="https://img.shields.io/badge/base-Debian%20Bookworm-a80030?style=flat-square" alt="Debian Bookworm">
  <img src="https://img.shields.io/badge/desktop-KDE%20Plasma-1d99f3?style=flat-square" alt="KDE Plasma">
  <img src="https://img.shields.io/badge/arch-amd64-333?style=flat-square" alt="amd64">
  <img src="https://img.shields.io/github/v/release/Harrsn/HarrisonOS?style=flat-square&color=2ea043" alt="Latest Release">
  <img src="https://img.shields.io/github/actions/workflow/status/Harrsn/HarrisonOS/build-iso.yml?style=flat-square&label=ISO%20build" alt="Build Status">
</p>

<h1 align="center">HarrisonOS</h1>
<p align="center"><strong>A custom Linux distribution built on Debian stable with KDE Plasma.</strong><br>Opinionated defaults. Developer-ready out of the box. One ISO.</p>

---

## What is this?

HarrisonOS is a custom Debian Bookworm-based Linux distribution that ships as a single bootable ISO. It's designed to be a complete workstation environment from the moment you boot — dark-themed KDE Plasma desktop, a full development toolchain, networking utilities, multimedia apps, and a curated set of CLI power tools, all pre-configured with sane defaults.

No post-install setup scripts. No "now install your 40 favorite packages." Just flash, boot, and work.

## Download

Grab the latest ISO from the [**Releases**](https://github.com/Harrsn/HarrisonOS/releases) page.

**Flash to USB:**
```bash
# Linux / macOS
sudo dd if=HarrisonOS-1.0-amd64.hybrid.iso of=/dev/sdX bs=4M status=progress

# Windows — use Rufus (https://rufus.ie), Ventoy, or balenaEtcher
```

**Test in a VM:**
```bash
qemu-system-x86_64 -m 4096 -cdrom HarrisonOS-1.0-amd64.hybrid.iso -boot d -enable-kvm -smp 4
```

## What's included

<table>
<tr><td><strong>Desktop</strong></td><td>KDE Plasma with Breeze Dark, Papirus icons, Fira Code terminal font, Noto Sans UI</td></tr>
<tr><td><strong>Browser</strong></td><td>Firefox ESR</td></tr>
<tr><td><strong>Dev tools</strong></td><td>Python 3, pip, venv, Flask, Git, GCC, CMake, Neovim, Docker, QEMU/KVM</td></tr>
<tr><td><strong>Networking</strong></td><td>Wireshark, nmap, WireGuard, OpenVPN, Remmina, iperf3, tcpdump</td></tr>
<tr><td><strong>CLI</strong></td><td>fzf, ripgrep, fd, bat, exa, btop, htop, tmux, zsh, ranger, ncdu, tldr</td></tr>
<tr><td><strong>Multimedia</strong></td><td>VLC, mpv, OBS Studio, GIMP, Inkscape, Kdenlive, Audacity, PipeWire</td></tr>
<tr><td><strong>Office</strong></td><td>LibreOffice (Plasma integration + Breeze theme)</td></tr>
<tr><td><strong>Security</strong></td><td>UFW, fail2ban, KeePassXC, ClamAV</td></tr>
<tr><td><strong>Extras</strong></td><td>Flatpak + Flathub, CUPS printing, full firmware/driver bundle</td></tr>
</table>

The shell comes pre-loaded with 40+ aliases, FZF integration, a configured `.tmux.conf`, `.vimrc`, `.nanorc`, `.gitconfig`, and neofetch on terminal open.

## Screenshots

> *Coming soon — boot it up and see for yourself.*

## Build it yourself

Want to customize it or just see how it works? The entire distro is defined by a few config files and a build script.

**Requirements:** A Debian or Ubuntu machine (bare metal, VM, or WSL2).

```bash
# Install build tools
sudo apt install -y live-build debootstrap squashfs-tools xorriso \
    grub-pc-bin grub-efi-amd64-bin mtools dosfstools git

# Clone and build
git clone https://github.com/Harrsn/HarrisonOS.git
cd HarrisonOS
chmod +x setup.sh && ./setup.sh
cd build
sudo lb build 2>&1 | tee build.log
```

The ISO lands in the `build/` directory. Takes 20–60 minutes depending on hardware and internet speed.

## Customization

| Want to... | Edit this file |
|---|---|
| Add or remove packages | `config/package-lists/desktop.list.chroot` |
| Change system settings, themes, shell config | `config/hooks/live/0100-customize.hook.chroot` |
| Add files to the filesystem | Drop them in `config/includes.chroot/` mirroring the target path |
| Change distro name/branding | `setup.sh` + `config/includes.chroot/etc/os-release` |

After editing, rebuild:
```bash
cd build && sudo lb clean && sudo lb build 2>&1 | tee build.log
```

## CI/CD

Every push to `main` builds the ISO via GitHub Actions. Tagged releases (e.g. `v1.0`) automatically create a GitHub Release with the ISO attached for download.

## License

The build system and configuration files in this repository are released under the [MIT License](LICENSE). HarrisonOS is assembled from Debian packages, each of which carries its own license.

---

<p align="center"><sub>Built in West Virginia.</sub></p>
