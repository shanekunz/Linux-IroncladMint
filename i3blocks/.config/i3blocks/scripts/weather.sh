#!/bin/bash

CACHE_FILE="/tmp/weather_cache.txt"
CACHE_TIME=1800  # 30 minutes

# Check if cache exists and is fresh
if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_TIME ]; then
    cat "$CACHE_FILE"
    exit 0
fi

# Fetch new weather (Orland Park, IL)
WEATHER=$(curl -s "wttr.in/Orland%20Park?format=%c+%t+%C" 2>/dev/null)

if [ -n "$WEATHER" ]; then
    echo "$WEATHER" | tee "$CACHE_FILE"
else
    echo "Weather N/A"
fi
