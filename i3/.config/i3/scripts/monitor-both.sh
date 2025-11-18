#!/bin/bash
# Both monitors at full resolution with 150% scaling

xrandr --output DP-0 --mode 3840x2160 --rate 164.99 --output DP-4 --mode 3840x2160 --rate 144.00 --rotate left --pos 3840x-1680
~/.config/i3/scripts/scaling.sh set 1.5
