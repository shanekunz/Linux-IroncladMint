#!/bin/bash
# Install tmux for Linux Mint and Ubuntu/WSL environments.

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}[install-tmux]${NC} Checking for tmux..."

if command -v tmux >/dev/null 2>&1; then
    TMUX_VERSION=$(tmux -V)
    echo -e "${GREEN}[install-tmux]${NC} tmux is already installed: $TMUX_VERSION"
    exit 0
fi

if ! command -v apt >/dev/null 2>&1; then
    echo -e "${RED}[install-tmux]${NC} apt not found. This installer supports Linux Mint and Ubuntu/WSL only."
    exit 1
fi

if grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null; then
    echo -e "${YELLOW}[install-tmux]${NC} WSL detected - installing tmux from Ubuntu apt repositories"
else
    echo -e "${YELLOW}[install-tmux]${NC} Installing tmux from apt repositories"
fi

sudo apt update
sudo apt install -y tmux

if command -v tmux >/dev/null 2>&1; then
    TMUX_VERSION=$(tmux -V)
    echo -e "${GREEN}[install-tmux]${NC} tmux installed successfully: $TMUX_VERSION"
else
    echo -e "${RED}[install-tmux]${NC} Installation failed"
    exit 1
fi
