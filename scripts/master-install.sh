#!/bin/bash
# Master installation script - runs all individual install scripts

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Dotfiles Master Installation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to run a script
run_script() {
    local script=$1
    if [ -f "$SCRIPT_DIR/$script" ]; then
        echo -e "${YELLOW}Running:${NC} $script"
        bash "$SCRIPT_DIR/$script"
        echo ""
    else
        echo -e "${YELLOW}Skipping:${NC} $script (not found)"
    fi
}

# Core System
echo -e "${BLUE}=== Core System ===${NC}"
run_script "install-essentials.sh"
run_script "install-stow.sh"
run_script "install-flatpak.sh"

# i3 Window Manager Stack
echo -e "${BLUE}=== Window Manager ===${NC}"
run_script "install-i3.sh"
run_script "install-rofi.sh"
run_script "install-picom.sh"
run_script "install-nitrogen.sh"
run_script "install-flameshot.sh"
run_script "install-vokoscreen.sh"
run_script "install-dunst.sh"
run_script "install-nm-applet.sh"
run_script "install-blueman.sh"
run_script "install-feh.sh"
run_script "install-arandr.sh"

# Development Tools
echo -e "${BLUE}=== Development Tools ===${NC}"
run_script "install-git.sh"
run_script "install-gh.sh"
run_script "install-lazygit.sh"
run_script "install-neovim.sh"
run_script "install-ripgrep.sh"
run_script "install-fd.sh"
run_script "install-fzf.sh"
run_script "install-vim.sh"
run_script "install-vscode.sh"
run_script "install-ghostty.sh"
run_script "install-mise.sh"
run_script "install-python-tools.sh"
run_script "install-claude-cli.sh"
run_script "install-glow.sh"

# Browsers
echo -e "${BLUE}=== Browsers ===${NC}"
run_script "install-firefox.sh"
run_script "install-chromium.sh"
run_script "install-edge.sh"

# Communication
echo -e "${BLUE}=== Communication ===${NC}"
run_script "install-discord.sh"
run_script "install-zoom.sh"
run_script "install-signal.sh"
run_script "install-whatsie.sh"

# Productivity
echo -e "${BLUE}=== Productivity ===${NC}"
run_script "install-obsidian.sh"
run_script "install-todoist.sh"
run_script "install-teams.sh"
run_script "install-sunsama.sh"
run_script "install-emote.sh"
run_script "install-open-whispr.sh"

# Media & Gaming
echo -e "${BLUE}=== Media & Gaming ===${NC}"
run_script "install-obs.sh"
run_script "install-steam.sh"
run_script "install-retroarch.sh"
run_script "install-sunshine.sh"

# Networking
echo -e "${BLUE}=== Networking ===${NC}"
run_script "install-tailscale.sh"

# Utilities
echo -e "${BLUE}=== Utilities ===${NC}"
run_script "install-accountable2you.sh"
run_script "install-localsend.sh"
run_script "install-nerd-font.sh"
run_script "install-webapp-script.sh"

# Custom Builds
echo -e "${BLUE}=== Custom Builds ===${NC}"
run_script "install-obsbot.sh"

# Web Apps (requires dotfiles to be deployed first)
echo -e "${BLUE}=== Web Applications ===${NC}"
echo -e "${YELLOW}Note:${NC} Web apps require the webapp script to be deployed via stow first."
echo -e "       Run ${BLUE}./stow-dotfiles.sh${NC} first, then run ${BLUE}./install-webapps.sh${NC} manually."

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Run ${BLUE}./stow-dotfiles.sh${NC} to deploy your dotfiles"
echo -e "  2. Run ${BLUE}./install-webapps.sh${NC} to create web app shortcuts"
echo -e "  3. Log out and log back in for all changes to take effect"
echo ""
