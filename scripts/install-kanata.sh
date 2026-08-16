#!/bin/bash
# Install Kanata keyboard remapper

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-kanata]${NC} Checking for the latest Kanata release..."

# Install dependencies
sudo apt install -y jq libudev-dev unzip

# Get the current release asset instead of constructing a version-specific filename.
RELEASE_JSON=$(curl -fsSL https://api.github.com/repos/jtroo/kanata/releases/latest)
LATEST_VERSION=$(printf '%s' "$RELEASE_JSON" | jq -r '.tag_name')
DOWNLOAD_URL=$(printf '%s' "$RELEASE_JSON" | jq -r '.assets[] | select(.name == "linux-binaries-x64.zip") | .browser_download_url')
INSTALLED_VERSION=""
if command -v kanata &> /dev/null; then
    INSTALLED_VERSION=$(kanata --version 2>/dev/null | grep -Po 'v?\K[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)
fi

if [ "$INSTALLED_VERSION" = "${LATEST_VERSION#v}" ]; then
    echo -e "${GREEN}[install-kanata]${NC} Kanata is already current: $INSTALLED_VERSION"
    exit 0
fi

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
    echo -e "${YELLOW}[install-kanata]${NC} Could not find the Linux x64 release asset"
    exit 1
fi

echo -e "${YELLOW}[install-kanata]${NC} Downloading Kanata ${LATEST_VERSION}..."

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT
cd "$TEMP_DIR"

# Download and extract
curl -L -o kanata.zip "$DOWNLOAD_URL"
unzip kanata.zip

# Install the standard binary (not the cmd_allowed variant)
chmod +x kanata_linux_x64
sudo mv kanata_linux_x64 /usr/local/bin/kanata

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
