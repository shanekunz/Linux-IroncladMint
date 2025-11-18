#!/bin/bash
# Install Python development tools

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-python-tools]${NC} Installing Python development tools..."

sudo apt update
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev

echo -e "${GREEN}[install-python-tools]${NC} Python development tools installed successfully!"
