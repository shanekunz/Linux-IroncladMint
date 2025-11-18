#!/bin/bash
# Set DPI and UI scaling for X11

DPI=$1

if [ -z "$DPI" ]; then
    echo "Usage: $0 <dpi>"
    exit 1
fi

# Calculate scale factor from DPI (96 is base)
# 120 DPI = 1.25 scale, 144 DPI = 1.5 scale
SCALE=$(echo "scale=2; $DPI / 96" | bc)

# Update DPI in Xresources (for legacy X apps and fonts)
sed -i "s/^Xft.dpi:.*/Xft.dpi: $DPI/" ~/.Xresources
xrdb -merge ~/.Xresources

# Set GTK text scaling (affects most modern apps)
gsettings set org.gnome.desktop.interface text-scaling-factor "$SCALE"

# Notify user
notify-send "Display Scaling" "DPI: $DPI (${SCALE}x scale)" -t 2000 2>/dev/null || true
