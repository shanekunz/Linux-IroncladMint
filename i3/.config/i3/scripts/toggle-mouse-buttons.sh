#!/bin/bash
# Swap mouse buttons (left/right) for Glorious mouse (wired or wireless)
# This script is idempotent - always ensures buttons are swapped (primary click on right)

# Find Glorious mouse device ID (matches both wired and wireless)
device_id=$(xinput list | grep -i "GLORIOUS.*Mouse" | grep -o 'id=[0-9]*' | grep -o '[0-9]*' | head -n 1)

if [ -z "$device_id" ]; then
    # Mouse not found - exit silently (might not be plugged in yet)
    exit 0
fi

# Get current button mapping
current=$(xinput get-button-map "$device_id")

# Check if buttons are already swapped (starts with "3 2 1")
if [[ "$current" == 3\ 2\ 1* ]]; then
    # Already swapped, nothing to do
    exit 0
fi

# Swap the buttons (primary click on right)
xinput set-button-map "$device_id" 3 2 1 4 5 6 7 8 9 10 11
