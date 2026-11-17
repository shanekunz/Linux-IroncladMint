#!/bin/bash
# Install Blender via Flatpak

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! command -v flatpak &> /dev/null; then
    echo "[install-blender] Flatpak is required. Run ./scripts/install-flatpak.sh first." >&2
    exit 1
fi

echo -e "${YELLOW}[install-blender]${NC} Checking for Blender..."

if flatpak info --system org.blender.Blender &> /dev/null; then
    echo -e "${GREEN}[install-blender]${NC} Blender is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-blender]${NC} Installing Blender via Flatpak..."

flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --system -y flathub org.blender.Blender

echo -e "${GREEN}[install-blender]${NC} Blender installed successfully!"
