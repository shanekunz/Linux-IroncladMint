#!/bin/bash
# Install Sunsama desktop app (AppImage)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

INSTALL_DIR="$HOME/.local/bin"
APP_NAME="sunsama"

echo -e "${YELLOW}[install-sunsama]${NC} Checking for Sunsama..."

if [ -f "$INSTALL_DIR/$APP_NAME" ]; then
    echo -e "${GREEN}[install-sunsama]${NC} Sunsama is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-sunsama]${NC} Installing Sunsama AppImage..."

# Download AppImage
cd /tmp
curl -L -o sunsama.AppImage "https://desktop.sunsama.com/linux/appImage/x64"

# Make executable
chmod +x sunsama.AppImage

# Move to install directory
mkdir -p "$INSTALL_DIR"
mv sunsama.AppImage "$INSTALL_DIR/$APP_NAME"

echo -e "${GREEN}[install-sunsama]${NC} Sunsama installed successfully!"
