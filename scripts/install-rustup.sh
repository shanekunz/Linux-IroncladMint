#!/bin/bash
# Install Rust via rustup

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-rustup]${NC} Checking for Rust..."

# Check if rustup/cargo is already installed
if command -v rustc &> /dev/null && command -v cargo &> /dev/null; then
    echo -e "${GREEN}[install-rustup]${NC} Rust is already installed ($(rustc --version))"
    exit 0
fi

echo -e "${YELLOW}[install-rustup]${NC} Installing Rust via rustup..."

# Download and run rustup install script
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Load cargo environment
source "$HOME/.cargo/env"

echo -e "${GREEN}[install-rustup]${NC} Rust installed successfully!"
echo -e "${YELLOW}Note:${NC} Restart your shell or run: source ~/.cargo/env"
