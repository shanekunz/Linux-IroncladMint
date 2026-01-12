#!/bin/bash
# Install tmux - terminal multiplexer for persistent sessions
# Used by OpenCode agents for background processes and interactive tools

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-tmux]${NC} Checking for tmux..."

if command -v tmux &> /dev/null; then
    TMUX_VERSION=$(tmux -V)
    echo -e "${GREEN}[install-tmux]${NC} tmux is already installed: $TMUX_VERSION"
    exit 0
fi

echo -e "${YELLOW}[install-tmux]${NC} Installing tmux..."
sudo apt update
sudo apt install -y tmux

# Verify installation
if command -v tmux &> /dev/null; then
    TMUX_VERSION=$(tmux -V)
    echo -e "${GREEN}[install-tmux]${NC} tmux installed successfully: $TMUX_VERSION"
else
    echo -e "${RED}[install-tmux]${NC} Installation failed"
    exit 1
fi
