#!/bin/bash
# Install Kanata keyboard remapper

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-kanata]${NC} Checking for Kanata..."

if command -v kanata &> /dev/null; then
    echo -e "${GREEN}[install-kanata]${NC} Kanata is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-kanata]${NC} Installing Kanata..."

# Install dependencies
sudo apt install -y libudev-dev unzip

# Get latest release from GitHub
LATEST_VERSION=$(curl -s https://api.github.com/repos/jtroo/kanata/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_VERSION" ]; then
    echo -e "${YELLOW}[install-kanata]${NC} Could not determine latest version, using v1.10.1"
    LATEST_VERSION="v1.10.1"
fi

echo -e "${YELLOW}[install-kanata]${NC} Downloading Kanata ${LATEST_VERSION}..."

# Download the Linux x64 zip file
DOWNLOAD_URL="https://github.com/jtroo/kanata/releases/download/${LATEST_VERSION}/kanata-linux-binaries-${LATEST_VERSION}-x64.zip"

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download and extract
curl -L -o kanata.zip "$DOWNLOAD_URL"
unzip kanata.zip

# Install the standard binary (not the cmd_allowed variant)
chmod +x kanata_linux_x64
sudo mv kanata_linux_x64 /usr/local/bin/kanata

# Clean up
cd - > /dev/null
rm -rf "$TEMP_DIR"

# Set up udev rules for non-root access
echo -e "${YELLOW}[install-kanata]${NC} Setting up udev rules..."

# Create uinput group if it doesn't exist
if ! getent group uinput > /dev/null; then
    sudo groupadd uinput
fi

# Add current user to input and uinput groups
sudo usermod -aG input "$USER"
sudo usermod -aG uinput "$USER"

# Create udev rule for uinput
UDEV_RULE='KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"'
echo "$UDEV_RULE" | sudo tee /etc/udev/rules.d/99-uinput.rules > /dev/null

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# Load uinput module
sudo modprobe uinput

# Ensure uinput loads on boot
if ! grep -q "^uinput$" /etc/modules 2>/dev/null; then
    echo "uinput" | sudo tee -a /etc/modules > /dev/null
fi

echo -e "${GREEN}[install-kanata]${NC} Kanata installed successfully!"
echo -e "${YELLOW}[install-kanata]${NC} NOTE: You must log out and log back in for group changes to take effect."
echo -e "${YELLOW}[install-kanata]${NC} Then run: kanata -c ~/.config/kanata/kanata.kbd"
