#!/bin/bash
# Fix GNOME Keyring password prompt issues
# This script helps when you get password prompts for Edge, git, GOG, etc. on startup
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   GNOME Keyring Password Fix${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Show current keyrings
echo -e "${YELLOW}Current keyrings found:${NC}"
for keyring in ~/.local/share/keyrings/*.keyring; do
    if [ -f "$keyring" ]; then
        name=$(basename "$keyring" .keyring)
        size=$(du -h "$keyring" | cut -f1)
        echo "  - $name ($size)"
    fi
done
echo ""

echo -e "${YELLOW}Why you're seeing password prompts:${NC}"
echo "You have MULTIPLE keyrings, each potentially with different passwords:"
echo "  - login.keyring: Main keyring (Edge, Chrome, git credentials)"
echo "  - Default_keyring.keyring: Fallback keyring"
echo "  - gogcli.keyring: GOG Galaxy CLI (created with separate password)"
echo ""
echo "On i3, keyrings don't auto-unlock unless their password matches your login."
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Quick Fix (RECOMMENDED)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Reset ALL keyrings to use your login password:"
echo ""
echo -e "${RED}WARNING: This deletes saved passwords. You'll need to re-login to:${NC}"
echo "  - Websites in Edge/Chrome"
echo "  - GOG Galaxy"
echo "  - Any app using the keyring"
echo ""
echo -e "${YELLOW}Commands to run:${NC}"
echo ""
echo "  # 1. Close all browsers and apps"
echo "  # 2. Delete all keyrings:"
echo "  rm ~/.local/share/keyrings/*.keyring"
echo ""
echo "  # 3. Log out and log back in"
echo "  # 4. When prompted, create new keyring with your LOGIN password"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Alternative: Use Seahorse GUI${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Keep existing passwords but change keyring passwords:"
echo ""
echo "  1. Open Seahorse (Passwords and Keys app)"
echo "  2. For EACH keyring (Login, Default, gogcli):"
echo "     - Right-click -> Change Password"
echo "     - Set to your LOGIN password (same for all)"
echo ""

# Check if seahorse is installed
if ! command -v seahorse &> /dev/null; then
    echo ""
    read -p "Seahorse not installed. Install it now? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installing Seahorse...${NC}"
        sudo apt install -y seahorse
        echo -e "${GREEN}Done!${NC}"
    fi
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   What do you want to do?${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "  1) Delete all keyrings (quick fix, lose saved passwords)"
echo "  2) Open Seahorse to manually fix (keep saved passwords)"
echo "  3) Exit and do nothing"
echo ""
read -p "Choose [1/2/3]: " -n 1 -r choice
echo ""

case $choice in
    1)
        echo ""
        echo -e "${RED}This will delete all saved passwords!${NC}"
        read -p "Are you sure? [y/N] " -n 1 -r confirm
        echo
        if [[ $confirm =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Deleting keyrings...${NC}"
            rm -f ~/.local/share/keyrings/*.keyring
            echo -e "${GREEN}Done! Now log out and log back in.${NC}"
            echo -e "${YELLOW}When prompted, create new keyring with your LOGIN password.${NC}"
        fi
        ;;
    2)
        if command -v seahorse &> /dev/null; then
            echo -e "${YELLOW}Opening Seahorse...${NC}"
            seahorse &
            echo ""
            echo "In Seahorse:"
            echo "  1. Right-click each keyring -> Change Password"
            echo "  2. Set ALL keyrings to your login password"
            echo "  3. Log out and log back in"
        else
            echo -e "${RED}Seahorse not installed. Run this script again and choose to install it.${NC}"
        fi
        ;;
    *)
        echo "Exiting without changes."
        ;;
esac

echo ""
