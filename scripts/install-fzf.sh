#!/bin/bash
# Install fzf - fuzzy finder for LazyVim

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-fzf]${NC} Checking for fzf..."

if command -v fzf &> /dev/null; then
    echo -e "${GREEN}[install-fzf]${NC} fzf is already installed ($(fzf --version))"
    exit 0
fi

echo -e "${YELLOW}[install-fzf]${NC} Installing fzf from git..."

# Clone fzf repo
if [ ! -d ~/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi

# Install fzf (binary only, skip shell integration to avoid modifying shell configs)
~/.fzf/install --bin

# Symlink to ~/.local/bin for easy PATH access
mkdir -p ~/.local/bin
ln -sf ~/.fzf/bin/fzf ~/.local/bin/fzf

echo -e "${GREEN}[install-fzf]${NC} fzf installed successfully!"
