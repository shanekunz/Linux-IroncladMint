#!/bin/bash
# Streaming mode - LED monitor (DP-4) with selectable resolution (no rotation, no scaling)
# Even though monitor is physically portrait, display landscape to protect OLED

# Define resolution options
OPTIONS="Current (1680x1050)\n1080p (1920x1080)\n1440p (2560x1440)\n4K (3840x2160)"

# Show rofi menu
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Select Streaming Resolution" -theme-str 'window {width: 400px;}')

# Exit if no selection
if [ -z "$CHOICE" ]; then
    exit 0
fi

# Parse selection and set resolution
case "$CHOICE" in
    "Current (1680x1050)")
        MODE="1680x1050"
        RATE="59.95"
        ;;
    "1080p (1920x1080)")
        MODE="1920x1080"
        RATE="60.00"
        ;;
    "1440p (2560x1440)")
        MODE="2560x1440"
        RATE="144.00"
        ;;
    "4K (3840x2160)")
        MODE="3840x2160"
        RATE="144.00"
        ;;
    *)
        exit 1
        ;;
esac

# Apply the selected resolution
xrandr --output DP-0 --off --output DP-4 --mode "$MODE" --rate "$RATE" --rotate normal
~/.config/i3/scripts/scaling.sh set 1.0
sleep 0.3
xrandr --output DP-0 --off --output DP-4 --mode "$MODE" --rate "$RATE" --rotate normal 2>/dev/null
i3-msg restart
