#!/bin/bash
# Install open-whispr voice-to-text dictation app

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

WHISPR_VERSION="1.0.12"
WHISPR_DEB="open-whispr_${WHISPR_VERSION}_amd64.deb"
WHISPR_URL="https://github.com/HeroTools/open-whispr/releases/download/v${WHISPR_VERSION}/${WHISPR_DEB}"
TEMP_DIR="/tmp/open-whispr-install"

echo -e "${YELLOW}[install-open-whispr]${NC} Checking for open-whispr..."

if command -v open-whispr &> /dev/null; then
    INSTALLED_VERSION=$(dpkg -l | grep open-whispr | awk '{print $3}' | cut -d'-' -f1)
    echo -e "${GREEN}[install-open-whispr]${NC} open-whispr is already installed (version ${INSTALLED_VERSION})"
    exit 0
fi

echo -e "${YELLOW}[install-open-whispr]${NC} Checking dependencies..."

# Check for xdotool (required for auto-paste on X11)
if ! command -v xdotool &> /dev/null; then
    echo -e "${YELLOW}[install-open-whispr]${NC} Installing xdotool for auto-paste functionality..."
    sudo apt update
    sudo apt install -y xdotool
fi

# Check for Python 3.7+ (required for local Whisper processing)
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}[install-open-whispr]${NC} Installing Python 3..."
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv
else
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    echo -e "${GREEN}[install-open-whispr]${NC} Python ${PYTHON_VERSION} is installed"
fi

# Create temp directory
mkdir -p "${TEMP_DIR}"
cd "${TEMP_DIR}"

echo -e "${YELLOW}[install-open-whispr]${NC} Downloading open-whispr ${WHISPR_VERSION}..."
wget -O "${WHISPR_DEB}" "${WHISPR_URL}"

echo -e "${YELLOW}[install-open-whispr]${NC} Installing open-whispr..."
sudo dpkg -i "${WHISPR_DEB}" || sudo apt-get install -f -y

# Clean up
echo -e "${YELLOW}[install-open-whispr]${NC} Cleaning up..."
rm -rf "${TEMP_DIR}"

echo -e "${GREEN}[install-open-whispr]${NC} open-whispr installed successfully!"
echo ""
echo -e "${YELLOW}Setup Instructions:${NC}"
echo "1. Launch open-whispr from your app launcher or run 'open-whispr'"
echo "2. Configure in the Control Panel:"
echo "   - For LOCAL processing (privacy, uses your GPU):"
echo "     • Select 'Local' processing mode"
echo "     • Choose Whisper model: 'base' (recommended) or 'small' for balance"
echo "     • Models download automatically on first use (~75MB-500MB)"
echo "   - For CLOUD processing (faster, ~\$0.006/min):"
echo "     • Select 'Cloud' processing mode"
echo "     • Add your OpenAI API key"
echo "     • Cost: ~\$0.36/hour, very affordable for voice input"
echo "3. Set your preferred global hotkey (default: backtick key)"
echo "4. Test: Press hotkey, speak, press hotkey again to transcribe"
echo ""
echo -e "${YELLOW}Integration with i3:${NC}"
echo "A keybind will be added to i3 config for quick access."
