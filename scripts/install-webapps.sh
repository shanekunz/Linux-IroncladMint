#!/bin/bash
# Install web applications as PWAs using custom webapp script

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-webapps]${NC} Installing web applications..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Load URL configuration
if [ -f "$DOTFILES_DIR/webapp-urls.conf" ]; then
    source "$DOTFILES_DIR/webapp-urls.conf"
fi

# Load local overrides if they exist (gitignored)
if [ -f "$DOTFILES_DIR/webapp-urls.local.conf" ]; then
    echo -e "${GREEN}[install-webapps]${NC} Loading local URL configuration..."
    source "$DOTFILES_DIR/webapp-urls.local.conf"
fi

# Check if webapp script is available
if ! command -v webapp &> /dev/null; then
    echo -e "${YELLOW}[install-webapps]${NC} webapp script not found in PATH"
    echo -e "${YELLOW}Note:${NC} Make sure to run stow-dotfiles.sh to deploy the webapp script first"
    exit 1
fi

# Ensure applications directory exists
mkdir -p "$HOME/.local/share/applications"

# Function to create webapp desktop file (overwrites if exists to allow URL updates)
create_webapp() {
    local name=$1
    local url=$2
    local size=$3
    local comment=$4
    local icon="${5:-applications-internet}"
    local category="${6:-Office;Utility;}"

    local desktop_file="$HOME/.local/share/applications/${name,,}.desktop"

    echo -e "${YELLOW}[install-webapps]${NC} Creating $name webapp..."
    cat > "$desktop_file" << EOF
[Desktop Entry]
Type=Application
Name=$name
Comment=$comment
Exec=$HOME/.local/bin/webapp "$name" "$url" "$size"
Icon=$icon
Categories=$category
Terminal=false
StartupWMClass=$name
EOF
    chmod +x "$desktop_file"
    echo -e "${GREEN}[install-webapps]${NC} Created $desktop_file"
}

# Create all web apps
create_webapp "ChatGPT" "https://chatgpt.com" "1200,900" "OpenAI ChatGPT" "applications-science" "Office;Utility;"
create_webapp "Claude" "https://claude.ai" "1200,900" "Anthropic Claude AI" "applications-science" "Office;Utility;"
create_webapp "Linear" "https://linear.app" "1400,900" "Linear issue tracker" "applications-development" "Office;Development;"
create_webapp "Limitless" "https://app.limitless.ai" "1200,800" "Limitless AI meetings" "applications-office" "Office;AudioVideo;"
create_webapp "Apple-Music" "https://music.apple.com" "1400,800" "Apple Music streaming" "applications-multimedia" "AudioVideo;Audio;"
create_webapp "BrainFM" "https://brain.fm" "1000,700" "Brain.fm focus music" "applications-multimedia" "AudioVideo;Audio;"
create_webapp "Outlook" "https://outlook.com" "1400,900" "Microsoft Outlook email" "applications-mail" "Office;Email;"
create_webapp "Jira" "$JIRA_URL" "1400,900" "Jira issue tracker" "applications-development" "Office;Development;"
create_webapp "Confluence" "$CONFLUENCE_URL" "1400,900" "Confluence wiki" "applications-office" "Office;Documentation;"

echo -e "${GREEN}[install-webapps]${NC} All web applications installed successfully!"
echo -e "${YELLOW}Note:${NC} To customize Jira/Confluence URLs, create webapp-urls.local.conf (see webapp-urls.conf for instructions)"
