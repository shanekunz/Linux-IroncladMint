#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

is_wsl() {
    grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null
}

run_if_available() {
    local command_name="$1"
    shift

    if command -v "$command_name" > /dev/null 2>&1; then
        "$@"
    else
        echo -e "${YELLOW}Skipping:${NC} $command_name is not installed"
    fi
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Dotfiles Full System Update${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${BLUE}Step 1:${NC} Updating dotfiles repository"
if [ -d "$DOTFILES_DIR/.git" ]; then
    if git -C "$DOTFILES_DIR" status --porcelain | grep -q .; then
        echo -e "${YELLOW}Skipping:${NC} git pull because the dotfiles repo has local changes"
        echo -e "           Commit, stash, or discard changes first if you want to fast-forward"
    else
        git -C "$DOTFILES_DIR" pull --ff-only
    fi
else
    echo -e "${YELLOW}Skipping:${NC} $DOTFILES_DIR is not a git repository"
fi
echo ""

echo -e "${BLUE}Step 2:${NC} Updating system packages"
sudo apt update
sudo apt upgrade
run_if_available flatpak flatpak update
run_if_available snap snap refresh
echo ""

echo -e "${BLUE}Step 3:${NC} Updating mise-managed tools"
if command -v mise > /dev/null 2>&1; then
    mise upgrade
    mise up
else
    echo -e "${YELLOW}Skipping:${NC} mise is not installed"
fi
echo ""

echo -e "${BLUE}Step 4:${NC} Re-running managed installers"
if is_wsl; then
    bash "$SCRIPTS_DIR/install-wsl-safe.sh"
else
    bash "$SCRIPTS_DIR/master-install.sh"
fi
echo ""

echo -e "${BLUE}Step 5:${NC} Re-deploying dotfiles"
bash "$SCRIPTS_DIR/stow-dotfiles.sh"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Update Complete${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review any warnings above"
echo "  2. Log out and back in if desktop components changed"
echo "  3. Reboot if a kernel or graphics stack update was installed"
