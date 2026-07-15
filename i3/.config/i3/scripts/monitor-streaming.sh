#!/bin/bash
# Streaming mode with selectable resolution (no scaling)
# Most options use the LED monitor on DP-4; the MacBook-native 16:10 mode uses the dummy plug on HDMI-0.

# Define resolution options
OPTIONS="Current (1680x1050)\n1080p (1920x1080)\n1440p (2560x1440)\n4K (3840x2160)\nMacBook 13.3 Native (2560x1600)"

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
        TARGET_OUTPUT="DP-4"
        SCALE="1.0"
        ;;
    "1080p (1920x1080)")
        MODE="1920x1080"
        RATE="60.00"
        TARGET_OUTPUT="DP-4"
        SCALE="1.0"
        ;;
    "1440p (2560x1440)")
        MODE="2560x1440"
        RATE="144.00"
        TARGET_OUTPUT="DP-4"
        SCALE="1.0"
        ;;
    "4K (3840x2160)")
        MODE="3840x2160"
        RATE="144.00"
        TARGET_OUTPUT="DP-4"
        SCALE="1.0"
        ;;
    "MacBook 13.3 Native (2560x1600)")
        MODE="2560x1600"
        RATE="59.97"
        TARGET_OUTPUT="HDMI-0"
        SCALE="1.25"
        ;;
    *)
        exit 1
        ;;
esac

# Apply the selected resolution
xrandr --output DP-0 --off --output DP-4 --off --output HDMI-0 --off --output "$TARGET_OUTPUT" --mode "$MODE" --rate "$RATE" --rotate normal
~/.config/i3/scripts/scaling.sh set "$SCALE"
sleep 0.3
xrandr --output DP-0 --off --output DP-4 --off --output HDMI-0 --off --output "$TARGET_OUTPUT" --mode "$MODE" --rate "$RATE" --rotate normal 2>/dev/null
i3-msg restart
