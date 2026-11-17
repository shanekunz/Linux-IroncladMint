#!/bin/bash

# Require explicit confirmation before opening the full-system update terminal.
choice=$(printf 'Yes\nCancel\n' | rofi -dmenu -p 'Update entire system?' -no-custom -selected-row 1)
if [ "$choice" != 'Yes' ]; then
    exit 0
fi

exec ghostty -e "$HOME/.config/i3/scripts/update-system-terminal.sh"
