#!/bin/bash
# Install Tailscale VPN from official repository

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-tailscale]${NC} Checking for Tailscale..."

if command -v tailscale &> /dev/null; then
    echo -e "${GREEN}[install-tailscale]${NC} Tailscale is already installed ($(tailscale --version | head -n1))"
    exit 0
fi

echo -e "${YELLOW}[install-tailscale]${NC} Installing Tailscale from official repository..."

# Add Tailscale's official repository
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

# Install Tailscale
sudo apt update
sudo apt install -y tailscale

# Enable and start the service
sudo systemctl enable --now tailscaled

echo -e "${GREEN}[install-tailscale]${NC} Tailscale installed successfully!"
echo -e "${YELLOW}[install-tailscale]${NC} To connect to your Tailscale network, run: sudo tailscale up"
