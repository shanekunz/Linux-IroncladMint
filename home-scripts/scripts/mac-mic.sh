#!/bin/bash

pactl unload-module module-pipe-source 2>/dev/null
rm -f /tmp/mac_mic.pipe

pactl load-module module-pipe-source source_name=mac_mic file=/tmp/mac_mic.pipe source_properties=device.description="Mac_Microphone" rate=16000 channels=1

pactl set-default-source mac_mic

# Keep the pipe drained even when nothing is recording
parec --device=mac_mic --raw > /dev/null &
DRAIN_PID=$!

echo "Waiting for Mac mic connection on port 8000..."
nc -lk 8000 > /tmp/mac_mic.pipe

# Cleanup on exit
kill $DRAIN_PID 2>/dev/null
