#!/bin/bash
# Both monitors at full resolution with 150% scaling in landscape
# DP-0: 3840x2160 landscape on left, DP-4: 3840x2160 landscape on right

xrandr --output DP-0 --mode 3840x2160 --rate 164.99 --pos 0x0 --output DP-4 --mode 3840x2160 --rate 144.00 --rotate normal --pos 3840x0
~/.config/i3/scripts/scaling.sh set 1.5
sleep 0.3
xrandr --output DP-0 --mode 3840x2160 --rate 164.99 --pos 0x0 --output DP-4 --mode 3840x2160 --rate 144.00 --rotate normal --pos 3840x0
i3-msg restart
