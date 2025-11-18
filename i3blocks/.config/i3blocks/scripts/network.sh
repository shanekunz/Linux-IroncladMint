#!/bin/bash

# Get primary network interface
INTERFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)

if [ -z "$INTERFACE" ]; then
    echo "NET N/A"
    exit 0
fi

# Read current stats
RX1=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX1=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

sleep 1

# Read stats again
RX2=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX2=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

# Calculate speeds
RX_SPEED=$(( ($RX2 - $RX1) / 1024 ))
TX_SPEED=$(( ($TX2 - $TX1) / 1024 ))

# Format output with fixed width
if [ $RX_SPEED -gt 1024 ]; then
    RX_DISPLAY=$(awk "BEGIN {printf \"%5.1fM\", $RX_SPEED/1024}")
else
    RX_DISPLAY=$(printf "%5dK" $RX_SPEED)
fi

if [ $TX_SPEED -gt 1024 ]; then
    TX_DISPLAY=$(awk "BEGIN {printf \"%5.1fM\", $TX_SPEED/1024}")
else
    TX_DISPLAY=$(printf "%5dK" $TX_SPEED)
fi

echo "↓${RX_DISPLAY} ↑${TX_DISPLAY}"
