#!/bin/bash
# Install Caskaydia Cove Nerd Font

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[install-nerd-font]${NC} Checking for Caskaydia Cove Nerd Font..."

# Check if font is already installed
if fc-list | grep -qi "Caskaydia"; then
    echo -e "${GREEN}[install-nerd-font]${NC} Caskaydia Cove Nerd Font is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-nerd-font]${NC} Installing Caskaydia Cove Nerd Font..."

# Create fonts directory if it doesn't exist
mkdir -p ~/.local/share/fonts

# Download and install the font
cd ~/.local/share/fonts

# Clean up any existing files
rm -rf CascadiaCode CascadiaCode.zip

# Download the latest release
wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip

# Unzip
unzip -q -o CascadiaCode.zip -d CascadiaCode
rm CascadiaCode.zip

# Refresh font cache
echo -e "${YELLOW}[install-nerd-font]${NC} Refreshing font cache..."
fc-cache -fv > /dev/null 2>&1

# Set as default system font (for Cinnamon desktop, only if gsettings is available)
if command -v gsettings &> /dev/null; then
    echo -e "${YELLOW}[install-nerd-font]${NC} Setting as default system font..."
    gsettings set org.cinnamon.desktop.interface font-name 'Caskaydia Cove Nerd Font 10' 2>/dev/null || true
    gsettings set org.nemo.desktop font 'Caskaydia Cove Nerd Font 10' 2>/dev/null || true
fi

echo -e "${GREEN}[install-nerd-font]${NC} Caskaydia Cove Nerd Font installed successfully!"
echo -e "${YELLOW}Note:${NC} You may need to log out and log back in for all changes to take effect."
