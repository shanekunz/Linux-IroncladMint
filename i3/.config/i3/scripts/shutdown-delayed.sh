#!/bin/bash
# Shutdown computer in 15 seconds with cancel option

# Start shutdown countdown in background
(sleep 15 && systemctl poweroff) &
SHUTDOWN_PID=$!

# Show dialog with cancel button
zenity --question \
    --title="Shutdown Scheduled" \
    --text="Computer will shut down in 15 seconds.\n\nClick Cancel to abort." \
    --ok-label="Cancel" \
    --width=300 \
    --timeout=15

# If user clicked Cancel (exit code 0), kill the shutdown process
if [ $? -eq 0 ]; then
    kill $SHUTDOWN_PID 2>/dev/null
fi
