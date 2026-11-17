#!/bin/bash
# Install Oh My Pi (OMP) coding agent via mise
# https://omp.sh

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

echo -e "${YELLOW}[install-oh-my-pi]${NC} Checking for Oh My Pi..."

if ! command -v mise &> /dev/null; then
    echo -e "${RED}[install-oh-my-pi]${NC} mise not found. Run install-mise.sh first."
    exit 1
fi

if command -v omp &> /dev/null; then
    echo -e "${YELLOW}[install-oh-my-pi]${NC} Ensuring the mise-managed version is current..."
else
    echo -e "${YELLOW}[install-oh-my-pi]${NC} Installing Oh My Pi via mise..."
fi

mise use --global github:can1357/oh-my-pi
mise reshim

if command -v omp &> /dev/null; then
    echo -e "${GREEN}[install-oh-my-pi]${NC} Oh My Pi is ready: $(omp --version 2>/dev/null || echo installed)"
    echo -e "${YELLOW}[install-oh-my-pi]${NC} Run 'omp setup' to configure models and authentication."
else
    echo -e "${RED}[install-oh-my-pi]${NC} Installation completed but 'omp' is not on PATH."
    echo -e "${YELLOW}[install-oh-my-pi]${NC} Restart your shell or run: source ~/.bashrc"
    exit 1
fi
