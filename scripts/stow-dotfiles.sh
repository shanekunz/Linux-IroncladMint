#!/bin/bash
# Deploy dotfiles using GNU Stow

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Get the dotfiles directory (parent of scripts directory)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Dotfiles Deployment with Stow${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo -e "${RED}Error:${NC} GNU Stow is not installed"
    echo -e "Run: ${BLUE}./install-stow.sh${NC} first"
    exit 1
fi

# Backup existing files
echo -e "${YELLOW}Creating backup of existing dotfiles...${NC}"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# List of files/directories to back up
declare -a to_backup=(
    ".bashrc"
    ".profile"
    ".gitconfig"
    ".Xresources"
    ".config/i3"
    ".config/nvim"
    ".config/ghostty"
    ".config/starship"
    ".config/rofi"
    ".config/picom"
    ".config/i3blocks"
    ".config/lazygit"
    ".config/flameshot"
    ".config/nitrogen"
    ".config/Signal"
    ".config/sunshine"
    ".config/retroarch"
    ".config/gtk-3.0"
    ".config/gtk-4.0"
    ".config/kanata"
    ".config/environment.d"
    ".config/mise"
    ".config/gh"
    ".config/copyq"
    ".local/bin/webapp"
    ".local/bin/lazygit"
    ".local/bin/sunsama"
    ".claude"
    "scripts"
)

for item in "${to_backup[@]}"; do
    if [ -e "$HOME/$item" ] && [ ! -L "$HOME/$item" ]; then
        echo -e "  Backing up: $item"
        mkdir -p "$BACKUP_DIR/$(dirname "$item")"
        cp -r "$HOME/$item" "$BACKUP_DIR/$item" 2>/dev/null || true
    fi
done

echo -e "${GREEN}Backup created at:${NC} $BACKUP_DIR"
echo ""

# Change to dotfiles directory
cd "$DOTFILES_DIR"

# Deploy dotfiles with stow
echo -e "${YELLOW}Deploying dotfiles with stow...${NC}"

# List of packages to stow
declare -a packages=(
    "bash"
    "git"
    "x11"
    "i3"
    "nvim"
    "ghostty"
    "starship"
    "rofi"
    "picom"
    "i3blocks"
    "lazygit"
    "flameshot"
    "nitrogen"
    "signal"
    "sunshine"
    "retroarch"
    "bin"
    "obsbot"
    "gtk-3.0"
    "gtk-4.0"
    "home-scripts"
    "kanata"
    "claude"
    "environment.d"
    "mise"
    "gh"
    "copyq"
)

for package in "${packages[@]}"; do
    if [ -d "$package" ]; then
        echo -e "  Stowing: ${BLUE}$package${NC}"
        stow -v 1 -t "$HOME" "$package" 2>&1 | grep -v "^BUG" || true
    else
        echo -e "  ${YELLOW}Skipping:${NC} $package (directory not found)"
    fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Dotfiles Deployed Successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}What was done:${NC}"
echo -e "  • Backed up existing dotfiles to: $BACKUP_DIR"
echo -e "  • Created symlinks from ~/ to $DOTFILES_DIR/"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Review the symlinks: ${BLUE}ls -la ~/.bashrc ~/.gitconfig ~/.config/i3${NC}"
echo -e "  2. Source your bash config: ${BLUE}source ~/.bashrc${NC}"
echo -e "  3. Log out and log back in for all changes to take effect"
echo ""
echo -e "${YELLOW}To undo:${NC}"
echo -e "  Run: ${BLUE}cd $DOTFILES_DIR && stow -D -t ~ bash git x11 i3 nvim ...${NC}"
echo ""
