#!/bin/bash
# Install web applications as PWAs using custom webapp script

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-webapps]${NC} Installing web applications..."

# Check if webapp script is available
if ! command -v webapp &> /dev/null; then
    echo -e "${YELLOW}[install-webapps]${NC} webapp script not found in PATH"
    echo -e "${YELLOW}Note:${NC} Make sure to run stow-dotfiles.sh to deploy the webapp script first"
    exit 1
fi

# Function to create webapp if it doesn't exist
create_webapp() {
    local name=$1
    local url=$2
    local size=$3

    if [ -f "$HOME/.local/share/applications/${name,,}.desktop" ] || \
       [ -f "$HOME/.local/share/applications/${name}.desktop" ]; then
        echo -e "${GREEN}[install-webapps]${NC} $name already exists"
    else
        echo -e "${YELLOW}[install-webapps]${NC} Creating $name webapp..."
        webapp "$name" "$url" "$size"
    fi
}

# Create all web apps
create_webapp "ChatGPT" "https://chatgpt.com" "1200x900"
create_webapp "Claude" "https://claude.ai" "1200x900"
create_webapp "Linear" "https://linear.app" "1400x900"
create_webapp "Limitless" "https://app.limitless.ai" "1200x800"
create_webapp "Apple-Music" "https://music.apple.com" "1400x800"
create_webapp "BrainFM" "https://brain.fm" "1000x700"
create_webapp "Outlook" "https://outlook.com" "1400x900"
create_webapp "Jira" "https://jira.atlassian.com" "1400x900"
create_webapp "Confluence" "https://confluence.atlassian.com" "1400x900"

echo -e "${GREEN}[install-webapps]${NC} All web applications installed successfully!"
echo -e "${YELLOW}Note:${NC} You may need to customize Jira and Confluence URLs for your organization"
