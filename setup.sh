#!/bin/bash
# ============================================================================
# HarrisonOS — Custom Distro Setup Script
# Configures Debian live-build to produce a bootable ISO with KDE Plasma
# ============================================================================

set -euo pipefail

# ── Configuration ───────────────────────────────────────────────────────────
DISTRO_NAME="HarrisonOS"
DISTRO_VERSION="1.0"
DISTRO_CODENAME="aurora"
BUILD_DIR="build"
CONFIG_DIR="config"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ── Preflight checks ───────────────────────────────────────────────────────
check_deps() {
    local missing=()
    for cmd in lb debootstrap xorriso mksquashfs; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        err "Missing dependencies: ${missing[*]}"
        err "Run: sudo apt install -y live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools dosfstools"
        exit 1
    fi
}

info "Checking dependencies..."
check_deps
ok "All dependencies found"

# ── Create build directory ──────────────────────────────────────────────────
if [[ -d "$BUILD_DIR" ]]; then
    info "Build directory exists, cleaning..."
    cd "$BUILD_DIR"
    sudo lb clean 2>/dev/null || true
    cd ..
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# ── Configure live-build ────────────────────────────────────────────────────
info "Configuring live-build for KDE Plasma..."

lb config \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --architectures amd64 \
    --binary-images iso-hybrid \
    --bootappend-live "boot=live components quiet splash" \
    --debian-installer live \
    --debian-installer-gui true \
    --iso-application "$DISTRO_NAME" \
    --iso-publisher "$DISTRO_NAME Project" \
    --iso-volume "$DISTRO_NAME $DISTRO_VERSION" \
    --image-name "$DISTRO_NAME-$DISTRO_VERSION" \
    --memtest none \
    --apt-recommends true \
    --security true \
    --updates true \
    --firmware-binary true \
    --firmware-chroot true \
    --cache true \
    --cache-packages true

ok "live-build configured"

# ── Copy config overlays ───────────────────────────────────────────────────
info "Copying package lists, hooks, and filesystem overlays..."
cd ..

# Package lists
mkdir -p "$BUILD_DIR/config/package-lists"
cp "$CONFIG_DIR/package-lists/desktop.list.chroot" \
   "$BUILD_DIR/config/package-lists/"

# Hooks
mkdir -p "$BUILD_DIR/config/hooks/live"
cp "$CONFIG_DIR/hooks/live/0100-customize.hook.chroot" \
   "$BUILD_DIR/config/hooks/live/"

# Filesystem overlays
if [[ -d "$CONFIG_DIR/includes.chroot" ]]; then
    cp -r "$CONFIG_DIR/includes.chroot" "$BUILD_DIR/config/"
fi

if [[ -d "$CONFIG_DIR/includes.binary" ]]; then
    cp -r "$CONFIG_DIR/includes.binary" "$BUILD_DIR/config/"
fi

ok "Config overlays copied"

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  ${GREEN}$DISTRO_NAME $DISTRO_VERSION (Aurora)${NC}${BOLD} — Setup Complete              ║${NC}"
echo -e "${BOLD}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}║${NC}  Base:     Debian Bookworm (stable)                          ${BOLD}║${NC}"
echo -e "${BOLD}║${NC}  Desktop:  KDE Plasma 5.27                                   ${BOLD}║${NC}"
echo -e "${BOLD}║${NC}  Arch:     amd64                                             ${BOLD}║${NC}"
echo -e "${BOLD}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}║${NC}                                                              ${BOLD}║${NC}"
echo -e "${BOLD}║${NC}  Next steps:                                                 ${BOLD}║${NC}"
echo -e "${BOLD}║${NC}    cd build                                                  ${BOLD}║${NC}"
echo -e "${BOLD}║${NC}    sudo lb build 2>&1 | tee build.log                        ${BOLD}║${NC}"
echo -e "${BOLD}║${NC}                                                              ${BOLD}║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
