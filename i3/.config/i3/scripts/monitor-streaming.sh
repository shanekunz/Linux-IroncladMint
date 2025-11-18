#!/bin/bash
# Streaming mode - LED monitor at 1080p 60Hz with no scaling

xrandr --output DP-0 --off --output DP-4 --mode 1920x1080 --rate 60.00
~/.config/i3/scripts/set-dpi.sh 96
