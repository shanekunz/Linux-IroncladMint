#!/bin/bash
# Install fzf - fuzzy finder for LazyVim

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-fzf]${NC} Checking fzf..."

if [ -d "$HOME/.fzf/.git" ]; then
    echo -e "${YELLOW}[install-fzf]${NC} Updating the existing fzf clone..."
    git -C "$HOME/.fzf" pull --ff-only
elif command -v fzf &> /dev/null; then
    echo -e "${GREEN}[install-fzf]${NC} fzf is package-managed: $(fzf --version)"
    exit 0
else
    echo -e "${YELLOW}[install-fzf]${NC} Installing fzf from git..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
fi

# Install fzf (binary only, skip shell integration to avoid modifying shell configs)
"$HOME/.fzf/install" --bin

# Symlink to ~/.local/bin for easy PATH access
mkdir -p ~/.local/bin
ln -sf "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"

echo -e "${GREEN}[install-fzf]${NC} fzf installed successfully!"
