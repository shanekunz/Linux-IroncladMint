#!/bin/bash
# Streaming mode - LED monitor at 1080p 60Hz landscape (no rotation, no scaling)
# Even though monitor is physically portrait, display landscape to protect OLED

xrandr --output DP-0 --off --output DP-4 --mode 1920x1080 --rate 60.00 --rotate normal
~/.config/i3/scripts/scaling.sh set 1.0
sleep 0.3
xrandr --output DP-0 --off --output DP-4 --mode 1920x1080 --rate 60.00 --rotate normal 2>/dev/null
i3-msg restart
