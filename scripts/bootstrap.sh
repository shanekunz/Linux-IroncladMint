#!/bin/bash
# Bootstrap script - Complete system setup from scratch

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}========================================"${NC}
echo -e "${BLUE}   Dotfiles Bootstrap${NC}"
echo -e "${BLUE}   Complete System Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}This script will:${NC}"
echo -e "  1. Install all programs and tools"
echo -e "  2. Deploy all dotfiles using stow"
echo -e "  3. Set up web applications"
echo ""
echo -e "${RED}Warning:${NC} This may take 30-60 minutes depending on your internet connection"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Bootstrap cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Step 1: Installing Programs${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Run master install script
bash "$SCRIPT_DIR/master-install.sh"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Step 2: Deploying Dotfiles${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Run stow deployment script
bash "$SCRIPT_DIR/stow-dotfiles.sh"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Step 3: Setting up Web Apps${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Run web apps installation
bash "$SCRIPT_DIR/install-webapps.sh"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Step 4: Installing Development Tools${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Install mise version manager
bash "$SCRIPT_DIR/install-mise.sh"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Bootstrap Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}System is now fully configured!${NC}"
echo ""
echo -e "${YELLOW}Important next steps:${NC}"
echo -e "  1. ${BLUE}Log out and log back in${NC} for all changes to take effect"
echo -e "  2. Open Neovim to let LazyVim install plugins: ${BLUE}nvim${NC}"
echo -e "  3. Configure GitHub CLI: ${BLUE}gh auth login${NC}"
echo -e "  4. Customize web app URLs (Jira, Confluence) if needed"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo -e "  • Update LazyVim: ${BLUE}cd ~/dotfiles/nvim/.config/nvim && git fetch upstream && git merge upstream/main${NC}"
echo -e "  • See installed packages: ${BLUE}flatpak list${NC}"
echo -e "  • Manage Node versions: ${BLUE}nvm list${NC}"
echo ""
