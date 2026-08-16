#!/bin/bash
# Install glow - terminal markdown viewer

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-glow]${NC} Installing Glow from Charm's APT repository..."

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
sudo apt update
sudo apt install -y glow

echo -e "${GREEN}[install-glow]${NC} Glow is installed and will update through APT."
