#!/bin/bash
# Get the focused window
WINDOW=$(xdotool getactivewindow)

# Get window geometry
eval $(xdotool getwindowgeometry --shell $WINDOW)

# Calculate center position
CENTER_X=$((X + WIDTH / 2))
CENTER_Y=$((Y + HEIGHT / 2))

# Move mouse to center
xdotool mousemove $CENTER_X $CENTER_Y
