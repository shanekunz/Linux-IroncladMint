#!/bin/bash

# Toggle Mac Microphone streaming on/off
# Sends desktop notification with status

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
MAC_MIC_SCRIPT="$SCRIPT_DIR/mac-mic.sh"
PID_FILE="/tmp/mac-mic.pid"

is_running() {
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
    fi
    # Also check for nc process listening on port 8000
    if pgrep -f "nc -lk 8000" > /dev/null; then
        return 0
    fi
    return 1
}

stop_mac_mic() {
    # Kill the nc listener and parec drain
    pkill -f "nc -lk 8000" 2>/dev/null || true
    pkill -f "parec --device=mac_mic" 2>/dev/null || true

    # Clean up PulseAudio module
    pactl unload-module module-pipe-source 2>/dev/null || true

    # Remove pipe and pid file
    rm -f /tmp/mac_mic.pipe "$PID_FILE"

    notify-send -t 2000 "Mac Mic" "Stopped"
}

start_mac_mic() {
    # Start in background
    nohup "$MAC_MIC_SCRIPT" > /tmp/mac-mic.log 2>&1 &
    echo $! > "$PID_FILE"

    notify-send -t 2000 "Mac Mic" "Started - listening on port 8000"
}

if is_running; then
    stop_mac_mic
else
    start_mac_mic
fi
