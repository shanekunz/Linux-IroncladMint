#!/bin/bash
# Build and install Obsbot Tiny 2 controller from source

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-obsbot]${NC} Checking for Obsbot Tiny 2 controller..."

# Check if already built
if [ -f "$HOME/.local/src/obsbot-tiny2/target/release/obsbot-gui" ]; then
    echo -e "${GREEN}[install-obsbot]${NC} Obsbot Tiny 2 controller is already built"
    exit 0
fi

echo -e "${YELLOW}[install-obsbot]${NC} Building Obsbot Tiny 2 controller from source..."

# Ensure Rust is installed
if ! command -v cargo &> /dev/null; then
    echo -e "${YELLOW}[install-obsbot]${NC} Rust is not installed. Please run install-rustup.sh first."
    exit 1
fi

# Create directory
mkdir -p ~/.local/src

# Clone the repository
if [ ! -d "$HOME/.local/src/obsbot-tiny2" ]; then
    cd ~/.local/src
    git clone https://github.com/feschber/obsbot-tiny2.git
fi

# Build the project
cd ~/.local/src/obsbot-tiny2
cargo build --release

echo -e "${GREEN}[install-obsbot]${NC} Obsbot Tiny 2 controller built successfully!"
echo -e "${YELLOW}Note:${NC} Use stow to deploy the desktop file and make it accessible from your app menu"
