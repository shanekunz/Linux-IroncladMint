#!/bin/bash
# Install Zoom from official .deb package

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-zoom]${NC} Checking for Zoom..."

if command -v zoom &> /dev/null; then
    echo -e "${GREEN}[install-zoom]${NC} Zoom is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-zoom]${NC} Installing Zoom from official .deb package..."

# Download latest Zoom .deb
cd /tmp
wget -O zoom.deb "https://zoom.us/client/latest/zoom_amd64.deb"

# Install
sudo apt install -y ./zoom.deb

# Cleanup
rm zoom.deb

echo -e "${GREEN}[install-zoom]${NC} Zoom installed successfully!"
