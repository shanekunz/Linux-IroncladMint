#!/bin/bash

# Install Caskaydia Mono Nerd Font and set as default system font

echo "Installing Caskaydia Cove Nerd Font..."

# Create fonts directory if it doesn't exist
mkdir -p ~/.local/share/fonts

# Download the font
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip

# Unzip
unzip -o CascadiaCode.zip -d CascadiaCode
rm CascadiaCode.zip

# Refresh font cache
echo "Refreshing font cache..."
fc-cache -fv

# Set as default system font (for Cinnamon desktop)
echo "Setting as default system font..."
gsettings set org.cinnamon.desktop.interface font-name 'Caskaydia Cove Nerd Font 10'
gsettings set org.nemo.desktop font 'Caskaydia Cove Nerd Font 10'

echo "Done! Font installed and set as default."
echo "You may need to log out and log back in for all changes to take effect."
echo ""
echo "To verify installation, run:"
echo "  fc-list | grep -i caskaydia"
echo "  gsettings get org.cinnamon.desktop.interface font-name"
