#!/bin/bash
# Main monitor only at 4K 165Hz with 150% DPI

xrandr --output DP-0 --mode 3840x2160 --rate 164.99 --output DP-4 --off
~/.config/i3/scripts/set-dpi.sh 144
