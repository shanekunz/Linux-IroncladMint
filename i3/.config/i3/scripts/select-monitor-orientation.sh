#!/bin/bash

OPTIONS="Landscape (normal)\nPortrait left\nPortrait right\nLandscape inverted"

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Select Monitor Orientation" -theme-str 'window {width: 400px;}')

case "$CHOICE" in
    "Landscape (normal)")
        echo "normal"
        ;;
    "Portrait left")
        echo "left"
        ;;
    "Portrait right")
        echo "right"
        ;;
    "Landscape inverted")
        echo "inverted"
        ;;
    *)
        exit 1
        ;;
esac
