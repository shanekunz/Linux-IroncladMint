#!/bin/bash
# Install GRUB configuration and boot helper support (via stow)
set -e

# Get dotfiles directory (parent of scripts directory)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_root() {
    if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
        sudo "$@"
    elif command -v pkexec >/dev/null 2>&1; then
        pkexec "$@"
    else
        echo "Error: sudo or pkexec is required" >&2
        exit 1
    fi
}

echo "Installing GRUB configuration..."

GRUB_ALREADY_STOWED=0

# Check if GRUB config is already stowed
if [ -L /etc/default/grub ]; then
    echo "✓ GRUB config already symlinked (stowed)"
    GRUB_ALREADY_STOWED=1
fi

# Backup and remove existing GRUB config if it exists (and is not a symlink)
if [ "$GRUB_ALREADY_STOWED" -eq 0 ] && [ -f /etc/default/grub ] && [ ! -L /etc/default/grub ]; then
    echo "Backing up existing GRUB config..."
    run_root cp /etc/default/grub /etc/default/grub.backup-$(date +%Y%m%d-%H%M%S)
    run_root rm /etc/default/grub
fi

# Stow GRUB config and the passwordless boot helper
echo "Stowing GRUB config and boot helper..."
cd "$DOTFILES_DIR"

if [ "$GRUB_ALREADY_STOWED" -eq 0 ]; then
    run_root stow -t / grub
fi

# Clean up old broken stow symlink from earlier installs.
if [ -L /usr/local/lib/dotfiles ]; then
    run_root rm -f /usr/local/lib/dotfiles
fi

run_root mkdir -p /usr/local/lib/dotfiles
run_root rm -f /usr/local/lib/dotfiles/boot-target.sh
run_root install -m 755 "$DOTFILES_DIR/boot-hotkey/usr/local/lib/dotfiles/boot-target.sh" /usr/local/lib/dotfiles/boot-target.sh
run_root mkdir -p /etc/sudoers.d
run_root rm -f /etc/sudoers.d/dotfiles-boot-target
run_root install -m 440 "$DOTFILES_DIR/boot-hotkey/etc/sudoers.d/dotfiles-boot-target" /etc/sudoers.d/dotfiles-boot-target

# Update GRUB to apply changes
echo "Updating GRUB..."
run_root update-grub

echo "✓ GRUB configuration installed successfully"
echo "  Boot menu (Mod+Ctrl+r) now supports one-time and permanent boot changes"
echo "  F11 can be used for passwordless one-time Windows boot after i3 reload"
