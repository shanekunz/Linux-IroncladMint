#!/bin/bash
# Install or update Shotcut via the stable Flathub release recommended upstream.
# https://shotcut.org/download/

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! command -v flatpak &> /dev/null; then
    echo "[install-shotcut] Flatpak is required. Run ./scripts/install-flatpak.sh first." >&2
    exit 1
fi

flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

if flatpak info --system org.shotcut.Shotcut//stable &> /dev/null; then
    echo -e "${YELLOW}[install-shotcut]${NC} Checking for Shotcut updates..."
    flatpak update --system -y org.shotcut.Shotcut//stable
else
    echo -e "${YELLOW}[install-shotcut]${NC} Installing Shotcut via Flatpak..."
    flatpak install --system -y flathub org.shotcut.Shotcut//stable
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$SCRIPT_DIR/sync-flatpak-nvidia.sh"
python3 "$SCRIPT_DIR/configure-shotcut.py"

echo -e "${GREEN}[install-shotcut]${NC} Shotcut is up to date. Launch from the app menu or with flatpak run org.shotcut.Shotcut."
