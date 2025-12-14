#!/bin/bash
# Install gamescope - Valve's microcompositor for better game compatibility

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}[install-gamescope]${NC} Checking for gamescope..."

if command -v gamescope &> /dev/null; then
    echo -e "${GREEN}[install-gamescope]${NC} gamescope is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-gamescope]${NC} Installing gamescope..."

# Ensure universe repository is enabled (required for gamescope)
sudo add-apt-repository -y universe
sudo apt update

# Try to install from apt first (works on Ubuntu 25.04+)
if sudo apt install -y gamescope 2>/dev/null; then
    echo -e "${GREEN}[install-gamescope]${NC} gamescope installed from apt successfully!"
else
    # Try PPA as fallback (faster than building from source)
    echo -e "${YELLOW}[install-gamescope]${NC} apt install failed, trying PPA..."

    # Try to add PPA (may fail on noble - don't exit script if it fails)
    sudo add-apt-repository -y ppa:ar-lex/gamescope 2>&1 || true
    sudo apt update 2>/dev/null || true

    if sudo apt install -y gamescope 2>/dev/null; then
        echo -e "${GREEN}[install-gamescope]${NC} gamescope installed from PPA successfully!"
    else
        # Try pre-built .deb from GitHub
        echo -e "${YELLOW}[install-gamescope]${NC} PPA failed, trying pre-built .deb package..."

        cd /tmp
        # Get latest release URL from GitHub API
        RELEASE_URL=$(curl -s https://api.github.com/repos/akdor1154/gamescope-pkg/releases/latest | grep "browser_download_url.*\.deb" | cut -d '"' -f 4 | head -1)

        if [ -n "$RELEASE_URL" ]; then
            echo -e "${YELLOW}[install-gamescope]${NC} Downloading gamescope .deb..."
            wget -q --show-progress "$RELEASE_URL" -O gamescope.deb

            echo -e "${YELLOW}[install-gamescope]${NC} Installing .deb package..."
            sudo apt install -y ./gamescope.deb
            rm -f gamescope.deb

            echo -e "${GREEN}[install-gamescope]${NC} gamescope installed from pre-built package!"
        else
            # Last resort: compile from source
            echo -e "${YELLOW}[install-gamescope]${NC} Pre-built package failed, building from source (this takes 5-10 min)..."

            # Install build dependencies and compile from source
    echo -e "${YELLOW}[install-gamescope]${NC} Installing build dependencies..."
    sudo apt install -y \
        meson ninja-build pkg-config \
        libdrm-dev libvulkan-dev libwayland-dev libx11-dev \
        libxdamage-dev libxcomposite-dev libxrender-dev libxext-dev \
        libxxf86vm-dev libxtst-dev libxres-dev \
        libliftoff-dev libcap-dev libsdl2-dev \
        glslang-tools hwdata

    # Clone and build gamescope
    cd /tmp
    if [ -d "gamescope" ]; then
        rm -rf gamescope
    fi
    git clone https://github.com/ValveSoftware/gamescope.git
    cd gamescope
    git submodule update --init --recursive

    meson build/
    ninja -C build/
    sudo ninja -C build/ install

            echo -e "${GREEN}[install-gamescope]${NC} gamescope compiled and installed!"
        fi
    fi
fi

echo -e ""
echo -e "${GREEN}[install-gamescope]${NC} Installation complete!"
echo -e "${YELLOW}To use with Steam (1080p fullscreen):${NC}"
echo -e "  ${BLUE}gamescope -W 1920 -H 1080 -f -- %command%${NC}"
