#!/bin/bash
set -e  # Exit on error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    log_error "Do not run this script as root/sudo. It will ask for sudo when needed."
    exit 1
fi

log_info "Starting application installation setup..."

#####################
# NATIVE APPS
#####################

log_info "Installing native applications..."

# VS Code
if ! command -v code &> /dev/null; then
    log_info "Installing VS Code..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm /tmp/packages.microsoft.gpg
    sudo apt update
    sudo apt install -y code
    log_info "VS Code installed successfully"
else
    log_info "VS Code already installed"
fi

# Discord
if ! command -v discord &> /dev/null; then
    log_info "Installing Discord..."
    wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
    sudo apt install -y /tmp/discord.deb
    rm /tmp/discord.deb
    log_info "Discord installed successfully"
else
    log_info "Discord already installed"
fi

# OBS Studio
if ! command -v obs &> /dev/null; then
    log_info "Installing OBS Studio..."
    sudo add-apt-repository -y ppa:obsproject/obs-studio
    sudo apt update
    sudo apt install -y obs-studio
    log_info "OBS Studio installed successfully"
else
    log_info "OBS Studio already installed"
fi

# Todoist (Flatpak)
if ! flatpak list | grep -q "com.todoist.Todoist"; then
    log_info "Installing Todoist..."
    flatpak install -y flathub com.todoist.Todoist
    log_info "Todoist installed successfully"
else
    log_info "Todoist already installed"
fi

# RetroArch
if ! command -v retroarch &> /dev/null; then
    log_info "Installing RetroArch..."
    sudo add-apt-repository -y ppa:libretro/stable
    sudo apt update
    sudo apt install -y retroarch
    log_info "RetroArch installed successfully"
else
    log_info "RetroArch already installed"
fi

# Figma Linux
if ! command -v figma-linux &> /dev/null; then
    log_info "Installing Figma Linux..."
    # Get latest release URL
    FIGMA_URL=$(curl -s https://api.github.com/repos/Figma-Linux/figma-linux/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)
    wget -O /tmp/figma-linux.deb "$FIGMA_URL"
    sudo apt install -y /tmp/figma-linux.deb
    rm /tmp/figma-linux.deb
    log_info "Figma Linux installed successfully"
else
    log_info "Figma Linux already installed"
fi

# Sunsama (from Downloads)
SUNSAMA_FILE="/home/shane/Downloads/sunsama-3.2.4x86_64.AppImage"
if [ -f "$SUNSAMA_FILE" ]; then
    log_info "Installing Sunsama..."
    mkdir -p ~/.local/bin
    cp "$SUNSAMA_FILE" ~/.local/bin/sunsama
    chmod +x ~/.local/bin/sunsama

    # Create .desktop file for rofi
    mkdir -p ~/.local/share/applications
    cat > ~/.local/share/applications/sunsama.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Sunsama
Comment=Daily planner for busy professionals
Exec=/home/shane/.local/bin/sunsama
Icon=sunsama
Categories=Office;ProjectManagement;
Terminal=false
StartupWMClass=Sunsama
EOF
    log_info "Sunsama installed successfully"
else
    log_warn "Sunsama AppImage not found at $SUNSAMA_FILE - skipping"
fi

#####################
# WEB APP LAUNCHER
#####################

log_info "Creating web app launcher..."

mkdir -p ~/.local/bin

cat > ~/.local/bin/webapp << 'EOF'
#!/bin/bash
# Usage: webapp "App Name" "https://url.com" [window-size] [icon-name]

NAME="$1"
URL="$2"
SIZE="${3:-1200,800}"
ICON="${4:-applications-internet}"

# Install chromium if not present
if ! command -v chromium-browser &> /dev/null; then
    echo "Chromium not found. Please install it first:"
    echo "sudo apt install chromium-browser"
    exit 1
fi

chromium-browser \
  --app="$URL" \
  --class="$NAME" \
  --name="$NAME" \
  --window-size="$SIZE" \
  --user-data-dir="$HOME/.local/share/webapps/$NAME" \
  &> /dev/null &
EOF

chmod +x ~/.local/bin/webapp
log_info "Web app launcher created"

# Install chromium if not present
if ! command -v chromium-browser &> /dev/null; then
    log_info "Installing Chromium for web apps..."
    sudo apt install -y chromium-browser
fi

#####################
# WEB APP DESKTOP FILES
#####################

log_info "Creating .desktop files for web apps..."

mkdir -p ~/.local/share/applications

# Linear
cat > ~/.local/share/applications/linear.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Linear
Comment=Issue tracking for modern software teams
Exec=/home/shane/.local/bin/webapp "Linear" "https://linear.app" "1400,900"
Icon=applications-development
Categories=Development;ProjectManagement;
Terminal=false
StartupWMClass=Linear
EOF

# Outlook
cat > ~/.local/share/applications/outlook-web.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Outlook
Comment=Microsoft Outlook web app
Exec=/home/shane/.local/bin/webapp "Outlook" "https://outlook.com" "1400,900"
Icon=evolution
Categories=Office;Email;
Terminal=false
StartupWMClass=Outlook
EOF

# Limitless
cat > ~/.local/share/applications/limitless.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Limitless
Comment=AI meeting recorder
Exec=/home/shane/.local/bin/webapp "Limitless" "https://app.limitless.ai" "1200,800"
Icon=audio-recorder
Categories=Office;AudioVideo;
Terminal=false
StartupWMClass=Limitless
EOF

# Brain.fm
cat > ~/.local/share/applications/brainfm.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Brain.fm
Comment=Focus music service
Exec=/home/shane/.local/bin/webapp "Brain.fm" "https://brain.fm" "1000,700"
Icon=rhythmbox
Categories=AudioVideo;Audio;
Terminal=false
StartupWMClass=Brain.fm
EOF

# Claude
cat > ~/.local/share/applications/claude.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Claude
Comment=Anthropic's AI assistant
Exec=/home/shane/.local/bin/webapp "Claude" "https://claude.ai" "1200,900"
Icon=applications-science
Categories=Office;Utility;
Terminal=false
StartupWMClass=Claude
EOF

# ChatGPT
cat > ~/.local/share/applications/chatgpt.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=ChatGPT
Comment=OpenAI's chatbot
Exec=/home/shane/.local/bin/webapp "ChatGPT" "https://chatgpt.com" "1200,900"
Icon=applications-science
Categories=Office;Utility;
Terminal=false
StartupWMClass=ChatGPT
EOF

# Apple Music
cat > ~/.local/share/applications/apple-music.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Apple Music
Comment=Apple Music web player
Exec=/home/shane/.local/bin/webapp "Apple Music" "https://music.apple.com" "1400,800"
Icon=music
Categories=AudioVideo;Audio;Music;
Terminal=false
StartupWMClass=Apple Music
EOF

log_info "Web app .desktop files created"

#####################
# OBSBOT COMMUNITY TOOL
#####################

log_info "Setting up Obsbot Tiny 2 community tool..."

if [ ! -d ~/.local/src/obsbot-tiny2 ]; then
    log_info "Cloning Obsbot Tiny 2 controller..."
    mkdir -p ~/.local/src
    git clone https://github.com/cgevans/tiny2.git ~/.local/src/obsbot-tiny2

    log_info "Installing dependencies for Obsbot tool..."
    # Check if requirements exist and install
    if [ -f ~/.local/src/obsbot-tiny2/requirements.txt ]; then
        # Install python3-pip if not present
        if ! command -v pip3 &> /dev/null; then
            sudo apt install -y python3-pip
        fi

        # Install Python dependencies
        pip3 install --user -r ~/.local/src/obsbot-tiny2/requirements.txt

        log_info "Obsbot Tiny 2 tool installed. Run it from: ~/.local/src/obsbot-tiny2"
        log_info "Note: This tool is for Obsbot Tiny 2 camera. If you have a different model, you may need a different tool."
    else
        log_warn "Could not find requirements.txt - you may need to manually set up dependencies"
    fi
else
    log_info "Obsbot Tiny 2 tool already cloned"
fi

#####################
# FINISH UP
#####################

# Update desktop database so rofi sees the new apps
log_info "Updating desktop database..."
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

log_info ""
log_info "========================================="
log_info "Installation complete!"
log_info "========================================="
log_info ""
log_info "Installed native apps:"
log_info "  - VS Code (code)"
log_info "  - Discord (discord)"
log_info "  - OBS Studio (obs)"
log_info "  - Todoist (flatpak run com.todoist.Todoist)"
log_info "  - RetroArch (retroarch)"
log_info "  - Figma Linux (figma-linux)"
log_info "  - Sunsama (sunsama)"
log_info ""
log_info "Web apps (accessible via Mod+Space in rofi):"
log_info "  - Linear"
log_info "  - Outlook"
log_info "  - Limitless"
log_info "  - Brain.fm"
log_info "  - Claude"
log_info "  - ChatGPT"
log_info "  - Apple Music"
log_info ""
log_info "All apps should now appear in your rofi launcher (Mod+Space)"
log_info ""
log_info "Obsbot Tiny 2 tool is available at: ~/.local/src/obsbot-tiny2"
log_info ""
log_info "You may need to restart i3 (Mod+Shift+r) or log out/in for all changes to take effect."
