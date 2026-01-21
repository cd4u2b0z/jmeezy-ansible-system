#!/usr/bin/env bash

# Simple working app tray for waybar
# Shows ncspot as Spotify and other running apps

# Check if ncspot is running and show as Spotify
if pgrep -x "ncspot" > /dev/null; then
    echo '{"text": "󰓇", "tooltip": "Spotify (ncspot) - Right-click to kill", "class": "running"}'
elif pgrep -x "spotify" > /dev/null; then
    echo '{"text": "󰓇", "tooltip": "Spotify - Right-click to kill", "class": "running"}'
else
    echo '{"text": "", "tooltip": "No music app running", "class": "empty"}'
fi
