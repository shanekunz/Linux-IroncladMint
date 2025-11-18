#!/bin/bash
# Install lazygit TUI from GitHub releases

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-lazygit]${NC} Checking for lazygit..."

if command -v lazygit &> /dev/null; then
    echo -e "${GREEN}[install-lazygit]${NC} lazygit is already installed ($(lazygit --version | head -n1))"
    exit 0
fi

echo -e "${YELLOW}[install-lazygit]${NC} Installing lazygit from GitHub releases..."

# Create bin directory if it doesn't exist
mkdir -p ~/.local/bin

# Get latest version
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

# Download and extract
cd /tmp
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
mv lazygit ~/.local/bin/
chmod +x ~/.local/bin/lazygit
rm lazygit.tar.gz

echo -e "${GREEN}[install-lazygit]${NC} lazygit ${LAZYGIT_VERSION} installed successfully!"
