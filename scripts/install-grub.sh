#!/bin/bash
# Install GRUB configuration with saved entry support (via stow)
set -e

# Get dotfiles directory (parent of scripts directory)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Installing GRUB configuration..."

# Check if GRUB config is already stowed
if [ -L /etc/default/grub ]; then
    echo "✓ GRUB config already symlinked (stowed)"
    exit 0
fi

# Backup and remove existing GRUB config if it exists (and is not a symlink)
if [ -f /etc/default/grub ] && [ ! -L /etc/default/grub ]; then
    echo "Backing up existing GRUB config..."
    sudo cp /etc/default/grub /etc/default/grub.backup-$(date +%Y%m%d-%H%M%S)
    sudo rm /etc/default/grub
fi

# Stow GRUB config to /etc
echo "Stowing GRUB config to /etc/default/grub..."
cd "$DOTFILES_DIR"
sudo stow -t / grub

# Update GRUB to apply changes
echo "Updating GRUB..."
sudo update-grub

echo "✓ GRUB configuration installed successfully"
echo "  Boot menu (Mod+Ctrl+r) now supports one-time and permanent boot changes"
