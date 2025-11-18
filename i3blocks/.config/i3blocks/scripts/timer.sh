#!/bin/bash

TIMER_FILE="/tmp/i3blocks_timer"
PAUSED_FILE="/tmp/i3blocks_timer_paused"

# Handle clicks
case $BLOCK_BUTTON in
    1) # Left click - start/pause/resume
        if [ -f "$PAUSED_FILE" ]; then
            # Resume from pause
            REMAINING=$(cat "$PAUSED_FILE")
            echo $(($(date +%s) + REMAINING)) > "$TIMER_FILE"
            rm "$PAUSED_FILE"
        elif [ -f "$TIMER_FILE" ]; then
            # Pause running timer
            END_TIME=$(cat "$TIMER_FILE")
            NOW=$(date +%s)
            REMAINING=$((END_TIME - NOW))
            if [ $REMAINING -gt 0 ]; then
                echo $REMAINING > "$PAUSED_FILE"
            fi
            rm "$TIMER_FILE"
        else
            # Start new 25min timer
            echo $(($(date +%s) + 1500)) > "$TIMER_FILE"
        fi
        ;;
    3) # Right click - reset
        rm -f "$TIMER_FILE" "$PAUSED_FILE"
        ;;
esac

# Display timer
if [ -f "$PAUSED_FILE" ]; then
    # Show paused time
    REMAINING=$(cat "$PAUSED_FILE")
    MINS=$((REMAINING / 60))
    SECS=$((REMAINING % 60))
    printf "⏱ %02d:%02d ⏸" $MINS $SECS
elif [ -f "$TIMER_FILE" ]; then
    # Show running time
    END_TIME=$(cat "$TIMER_FILE")
    NOW=$(date +%s)
    REMAINING=$((END_TIME - NOW))

    if [ $REMAINING -le 0 ]; then
        rm "$TIMER_FILE"
        notify-send "Timer Done!" "Pomodoro session complete"
        echo "⏱ 00:00 ✓"
    else
        MINS=$((REMAINING / 60))
        SECS=$((REMAINING % 60))
        printf "⏱ %02d:%02d ▶" $MINS $SECS
    fi
else
    echo "⏱ --:-- ○"
fi
