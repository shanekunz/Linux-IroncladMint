#!/bin/bash
#
# Bootstrap Script for Dotfiles
# ==============================
# Automated setup for Linux Mint + i3 window manager
#
# Usage:
#   ./bootstrap.sh              # Full install (recommended for fresh systems)
#   ./scripts/install-*.sh      # Individual package install
#
# What this does:
#   1. Installs essential tools (git, stow, flatpak)
#   2. Installs core packages (i3, neovim, dev tools)
#   3. Installs applications (browsers, discord, obsidian, etc.)
#   4. Deploys dotfiles with GNU Stow (backs up existing configs)
#
# Safe to run multiple times (idempotent scripts)
#

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}==>${NC} $1"
}

run_script() {
    local script=$1
    if [ -f "$SCRIPTS_DIR/$script" ]; then
        bash "$SCRIPTS_DIR/$script" || log_warn "$script encountered issues (continuing anyway)"
    else
        log_warn "Script not found: $script (skipping)"
    fi
}

echo ""
log_step "Starting dotfiles bootstrap..."
echo ""

# Check prerequisites
log_info "Checking prerequisites..."
if ! command -v git &> /dev/null; then
    log_error "git is not installed. Installing git first..."
    run_script "install-git.sh"
fi

# Install basic tools needed for everything else
log_info "Installing basic prerequisites..."
sudo apt update
run_script "install-essentials.sh"
run_script "install-stow.sh"
run_script "install-flatpak.sh"

# Phase 1: Core system tools with PPAs
log_step "Phase 1: Installing core system packages..."
run_script "install-neovim.sh"
run_script "install-git.sh"

# Phase 2: Window manager and desktop environment
log_step "Phase 2: Installing i3 window manager and tools..."
run_script "install-i3.sh"
run_script "install-rofi.sh"
run_script "install-picom.sh"
run_script "install-dunst.sh"
run_script "install-nitrogen.sh"
run_script "install-nm-applet.sh"
run_script "install-blueman.sh"
run_script "install-arandr.sh"
run_script "install-flameshot.sh"

# Phase 3: Terminal and shell tools
log_step "Phase 3: Installing terminal and CLI tools..."
run_script "install-vim.sh"
run_script "install-nerd-font.sh"

# Phase 4: Networking tools
log_step "Phase 4: Installing networking tools..."
run_script "install-tailscale.sh"

# Phase 5: Development tools
log_step "Phase 5: Installing development tools..."
run_script "install-node.sh"
run_script "install-nvm.sh"
run_script "install-pnpm.sh"
run_script "install-rustup.sh"
run_script "install-python-tools.sh"
run_script "install-lazygit.sh"
run_script "install-gh.sh"

# Phase 6: Applications via Flatpak
log_step "Phase 6: Installing Flatpak applications..."
run_script "install-obsidian.sh"
run_script "install-firefox.sh"
run_script "install-discord.sh"
run_script "install-signal.sh"
run_script "install-vscode.sh"
run_script "install-chromium.sh"

# Phase 7: Custom/external apps
log_step "Phase 7: Installing custom applications..."
run_script "install-obsbot.sh"
run_script "install-sunshine.sh"
run_script "install-retroarch.sh"
run_script "install-localsend.sh"

# Phase 8: Deploy dotfiles with Stow
log_step "Phase 8: Deploying dotfiles with GNU Stow..."
cd "$DOTFILES_DIR"

# Backup existing configs
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
if [ -d "$HOME/.config" ]; then
    log_info "Backing up existing configs to $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"

    for package in */; do
        package_name=${package%/}
        # Skip non-stow directories
        if [[ "$package_name" == "scripts" ]] || [[ "$package_name" == ".git" ]]; then
            continue
        fi

        # Check if any conflicts exist
        if [ -d "$package_name/.config" ]; then
            for config in "$package_name/.config"/*; do
                config_name=$(basename "$config")
                if [ -e "$HOME/.config/$config_name" ] && [ ! -L "$HOME/.config/$config_name" ]; then
                    log_info "Backing up ~/.config/$config_name"
                    mv "$HOME/.config/$config_name" "$BACKUP_DIR/" 2>/dev/null || true
                fi
            done
        fi
    done
fi

# Stow all packages
for package in */; do
    package_name=${package%/}
    # Skip non-stow directories
    if [[ "$package_name" == "scripts" ]] || [[ "$package_name" == ".git" ]]; then
        continue
    fi

    log_info "Stowing $package_name..."
    stow -t "$HOME" "$package_name" 2>/dev/null || log_warn "Issues stowing $package_name (may already be linked)"
done

# Phase 9: Post-install setup
log_step "Phase 9: Post-install configuration..."

# Setup Neovim plugins
if command -v nvim &> /dev/null; then
    log_info "Neovim installed - plugins will auto-install on first launch"
fi

echo ""
echo "=========================================="
log_info "Bootstrap complete!"
echo "=========================================="
echo ""
log_info "Next steps:"
echo "  1. Review any scripts that were skipped above"
echo "  2. Log out and log back in for all changes to take effect"
echo "  3. Select i3 as your window manager at login"
echo "  4. Launch nvim to complete plugin installation"
echo "  5. Review your backed up configs in: $BACKUP_DIR"
echo ""
log_info "To install additional packages, run individual scripts from:"
echo "  $SCRIPTS_DIR"
echo ""
