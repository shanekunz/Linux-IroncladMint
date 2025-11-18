#!/bin/bash
# Install Sunsama from AppImage

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-sunsama]${NC} Checking for Sunsama..."

if [ -f "$HOME/.local/bin/sunsama" ]; then
    echo -e "${GREEN}[install-sunsama]${NC} Sunsama is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-sunsama]${NC} Installing Sunsama from AppImage..."

# Create directories
mkdir -p ~/.local/bin

# Download latest Sunsama AppImage
cd /tmp
wget -O sunsama.AppImage "https://desktop-downloads.sunsama.com/linux/latest"

# Extract the binary (AppImages can be used directly or extracted)
chmod +x sunsama.AppImage
./sunsama.AppImage --appimage-extract > /dev/null

# Move the extracted files to a more permanent location
mv squashfs-root/sunsama ~/.local/bin/
chmod +x ~/.local/bin/sunsama

# Cleanup
rm -rf squashfs-root sunsama.AppImage

echo -e "${GREEN}[install-sunsama]${NC} Sunsama installed successfully!"
echo -e "${YELLOW}Note:${NC} You may want to create a desktop file for easier launching"
