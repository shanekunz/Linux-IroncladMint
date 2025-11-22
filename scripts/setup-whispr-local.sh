#!/bin/bash
# Setup local Whisper processing for OpenWhispr with proper venv

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

VENV_DIR="$HOME/.cache/openwhispr/venv"

echo -e "${YELLOW}[setup-whispr-local]${NC} Setting up Python virtual environment for OpenWhispr..."

# Install python3-venv if not present
if ! dpkg -l | grep -q python3-venv; then
    echo -e "${YELLOW}[setup-whispr-local]${NC} Installing python3-venv and python3-full..."
    sudo apt update
    sudo apt install -y python3-venv python3-full python3-pip
fi

# Create OpenWhispr cache directory if it doesn't exist
mkdir -p "$(dirname "$VENV_DIR")"

# Create virtual environment
if [ ! -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}[setup-whispr-local]${NC} Creating virtual environment at $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
else
    echo -e "${GREEN}[setup-whispr-local]${NC} Virtual environment already exists"
fi

# Activate and install Whisper with GPU support
echo -e "${YELLOW}[setup-whispr-local]${NC} Installing OpenAI Whisper in virtual environment..."
source "$VENV_DIR/bin/activate"

# Upgrade pip first
pip install --upgrade pip

# Install PyTorch with CUDA support for RTX 4070 Ti Super
echo -e "${YELLOW}[setup-whispr-local]${NC} Installing PyTorch with CUDA support..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install Whisper
echo -e "${YELLOW}[setup-whispr-local]${NC} Installing OpenAI Whisper..."
pip install openai-whisper

# Verify installation
echo -e "${YELLOW}[setup-whispr-local]${NC} Verifying installation..."
python -c "import whisper; import torch; print(f'Whisper installed: {whisper.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA device: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"N/A\"}')"

deactivate

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Whisper Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Unfortunately, OpenWhispr's built-in installer doesn't use this venv"
echo "2. You have TWO options:"
echo ""
echo -e "${GREEN}Option A: Use OpenAI API (RECOMMENDED)${NC}"
echo "   • Cost: \$0.006/min = \$0.36/hour (\$2/month with heavy use)"
echo "   • Setup: Open OpenWhispr, select 'Cloud', add OpenAI API key"
echo "   • Pros: Works immediately, faster, no local setup hassles"
echo ""
echo -e "${YELLOW}Option B: Manual local setup (ADVANCED)${NC}"
echo "   • The venv is at: $VENV_DIR"
echo "   • You'd need to configure OpenWhispr to use this Python"
echo "   • This requires diving into OpenWhispr's config files"
echo "   • Not officially supported by OpenWhispr"
echo ""
echo -e "${YELLOW}Recommendation:${NC}"
echo "Given your budget (\$10/month) and the actual cost (~\$2/month),"
echo "the OpenAI API route is much simpler and more reliable."
echo ""
echo "Your RTX 4070 Ti Super is ready for local processing if you want to"
echo "explore it later, but OpenWhispr's app doesn't make this easy."
