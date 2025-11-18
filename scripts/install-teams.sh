#!/bin/bash
# Install Teams for Linux via Flatpak

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-teams]${NC} Checking for Teams..."

if flatpak list | grep -q com.github.IsmaelMartinez.teams_for_linux; then
    echo -e "${GREEN}[install-teams]${NC} Teams is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-teams]${NC} Installing Teams for Linux via Flatpak..."

# Ensure Flatpak is set up
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install
flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux

echo -e "${GREEN}[install-teams]${NC} Teams for Linux installed successfully!"
