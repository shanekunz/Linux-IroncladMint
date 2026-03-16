#!/bin/bash
#
# Bootstrap Script for Dotfiles
# ==============================
# Orchestrates complete system setup for fresh Linux Mint + i3 installations
#
# Usage:
#   ./bootstrap.sh              # Full install (recommended for fresh systems)
#   ./scripts/install-*.sh      # Individual package install
#   ./scripts/master-install.sh # Just install packages (no dotfiles deployment)
#
# What this does:
#   1. Checks prerequisites (git)
#   2. Runs master-install.sh to install all packages
#   3. Deploys dotfiles with GNU Stow (backs up existing configs)
#   4. Creates web application shortcuts
#   5. Post-install configuration
#
# Safe to run multiple times (idempotent)
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
    log_error "git is not installed. Please install git first:"
    log_error "  sudo apt update && sudo apt install -y git"
    exit 1
fi

# Phase 1: Install all packages
log_step "Phase 1: Installing all packages..."
log_info "Running master-install.sh to install all system packages..."
echo ""
bash "$SCRIPTS_DIR/master-install.sh"
echo ""

# Phase 2: Deploy dotfiles with Stow
log_step "Phase 2: Deploying dotfiles with GNU Stow..."
cd "$DOTFILES_DIR"
bash "$SCRIPTS_DIR/stow-dotfiles.sh"

# Phase 3: Web Applications
log_step "Phase 3: Creating web application shortcuts..."
run_script "install-webapps.sh"

# Phase 4: Post-install setup
log_step "Phase 4: Post-install configuration..."

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
echo ""
log_info "To install additional packages, run individual scripts from:"
echo "  $SCRIPTS_DIR"
echo ""
