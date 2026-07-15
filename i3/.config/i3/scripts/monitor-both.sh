#!/bin/bash
# Both monitors at full resolution with 150% scaling.
# DP-0: 3840x2160 primary on left, DP-4: 3840x2160 secondary on right.

OPTIONS="Landscape (normal)\nPortrait left\nPortrait right\nLandscape inverted"

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Second Monitor Rotation" -theme-str 'window {width: 400px;}')

if [ -z "$CHOICE" ]; then
    exit 0
fi

case "$CHOICE" in
    "Landscape (normal)")
        ROTATION="normal"
        ;;
    "Portrait left")
        ROTATION="left"
        ;;
    "Portrait right")
        ROTATION="right"
        ;;
    "Landscape inverted")
        ROTATION="inverted"
        ;;
    *)
        exit 1
        ;;
esac

xrandr --output DP-0 --mode 3840x2160 --rate 164.99 --primary --pos 0x0 --output DP-4 --mode 3840x2160 --rate 144.00 --rotate "$ROTATION" --pos 3840x0 --output HDMI-0 --off
~/.config/i3/scripts/scaling.sh set 1.5
sleep 0.3
xrandr --output DP-0 --mode 3840x2160 --rate 164.99 --primary --pos 0x0 --output DP-4 --mode 3840x2160 --rate 144.00 --rotate "$ROTATION" --pos 3840x0 --output HDMI-0 --off
i3-msg restart
