#!/bin/bash
# Main monitor only at 4K 165Hz with 150% scaling

xrandr --output DP-0 --mode 3840x2160 --rate 164.99 --output DP-4 --off
~/.config/i3/scripts/scaling.sh set 1.5
sleep 0.3
i3-msg restart
