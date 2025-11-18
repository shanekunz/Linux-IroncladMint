#!/bin/bash
# Install Todoist via Flatpak

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-todoist]${NC} Checking for Todoist..."

if flatpak list | grep -q com.todoist.Todoist; then
    echo -e "${GREEN}[install-todoist]${NC} Todoist is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-todoist]${NC} Installing Todoist via Flatpak..."

# Ensure Flatpak is set up
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install
flatpak install -y flathub com.todoist.Todoist

echo -e "${GREEN}[install-todoist]${NC} Todoist installed successfully!"
