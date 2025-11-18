#!/bin/bash
# Toggle mouse button swap (left/right)

current=$(xinput get-button-map 14)

if [ "$current" = "3 2 1" ]; then
    # Currently swapped, switch to normal
    xinput set-button-map 14 1 2 3
else
    # Currently normal, switch to swapped
    xinput set-button-map 14 3 2 1
fi
