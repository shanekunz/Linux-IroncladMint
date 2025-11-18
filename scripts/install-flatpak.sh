#!/bin/bash
# Ensure Flatpak is installed and Flathub is configured

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-flatpak]${NC} Checking for Flatpak..."

# Check if Flatpak is installed
if ! command -v flatpak &> /dev/null; then
    echo -e "${YELLOW}[install-flatpak]${NC} Installing Flatpak..."
    sudo apt update
    sudo apt install -y flatpak
fi

echo -e "${GREEN}[install-flatpak]${NC} Flatpak is installed"

# Add Flathub repository if not already added
echo -e "${YELLOW}[install-flatpak]${NC} Configuring Flathub repository..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo -e "${GREEN}[install-flatpak]${NC} Flatpak and Flathub configured successfully!"
echo -e "${YELLOW}Note:${NC} You may need to log out and log back in for Flatpak apps to appear in your app menu"
