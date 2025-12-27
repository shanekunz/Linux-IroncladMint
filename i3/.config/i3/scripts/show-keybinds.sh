#!/bin/bash
# Show keybinds help file, sized to fit current monitor
# Uses Ghostty's native sizing to avoid pop-in effect

# Cell size estimates for 10pt font at 96 DPI
# Adjust these if your font/DPI differs significantly
CELL_WIDTH=9
CELL_HEIGHT=19

# Get focused monitor's resolution using i3
read -r screen_width screen_height < <(i3-msg -t get_workspaces | jq -r '.[] | select(.focused) | .rect | "\(.width) \(.height)"')

# Fallbacks
if [[ -z "$screen_width" || -z "$screen_height" ]]; then
    read -r screen_width screen_height < <(xrandr | grep -w connected | grep primary | grep -oP '\d+x\d+' | head -1 | tr 'x' ' ')
fi
: "${screen_width:=1920}" "${screen_height:=1080}"

# Target window size in pixels (96% height, fixed width for readability)
win_width_px=1100
win_height_px=$((screen_height * 96 / 100))

# Cap for very tall monitors
((win_height_px > 1800)) && win_height_px=1800

# Convert to cells (rows/columns) for Ghostty
# Subtract some for window decorations and padding
cols=$((win_width_px / CELL_WIDTH - 4))
rows=$((win_height_px / CELL_HEIGHT - 2))

# Launch ghostty with calculated size (positioning handled by i3)
ghostty \
    --title="i3-keybinds-help" \
    --window-width="$cols" \
    --window-height="$rows" \
    --confirm-close-surface=false \
    -e glow -p ~/.config/i3/keybinds.md &

# Wait for window to appear, then center it
for _ in {1..20}; do
    sleep 0.1
    if i3-msg -t get_tree | grep -q "i3-keybinds-help"; then
        sleep 0.1
        i3-msg "[title=\"i3-keybinds-help\"] floating enable, move position center" >/dev/null 2>&1
        break
    fi
done
