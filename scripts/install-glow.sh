#!/bin/bash
# Install glow - terminal markdown viewer

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-glow]${NC} Checking for glow..."

if command -v glow &> /dev/null; then
    echo -e "${GREEN}[install-glow]${NC} glow is already installed ($(glow --version))"
    exit 0
fi

echo -e "${YELLOW}[install-glow]${NC} Installing glow from GitHub releases..."

# Get latest version
LATEST_VERSION=$(curl -s https://api.github.com/repos/charmbracelet/glow/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')

# Download .deb for amd64
TEMP_DEB="/tmp/glow_${LATEST_VERSION}_amd64.deb"
curl -L "https://github.com/charmbracelet/glow/releases/download/v${LATEST_VERSION}/glow_${LATEST_VERSION}_amd64.deb" -o "$TEMP_DEB"

# Install
sudo dpkg -i "$TEMP_DEB"

# Clean up
rm "$TEMP_DEB"

echo -e "${GREEN}[install-glow]${NC} glow installed successfully!"
