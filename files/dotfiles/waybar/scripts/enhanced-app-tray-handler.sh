#!/usr/bin/env bash

# Handler for app tray clicks
# $1 = button number (1=left click, 3=right click)

button="$1"

case "$button" in
    1)
        # Left click - launch or focus app
        if pgrep -x "ncspot" > /dev/null; then
            # Focus on ncspot
            notify-send "Spotify" "Focusing ncspot..."
        else
            # Launch ncspot
            notify-send "Spotify" "Starting ncspot..."
            nohup ncspot > /dev/null 2>&1 &
        fi
        ;;
    3)
        # Right click - kill app
        if pgrep -x "ncspot" > /dev/null; then
            pkill ncspot
            notify-send "Spotify" "Killed ncspot"
        elif pgrep -x "spotify" > /dev/null; then
            pkill spotify
            notify-send "Spotify" "Killed Spotify"
        else
            notify-send "Spotify" "No music app running"
        fi
        ;;
esac

# Refresh waybar
pkill -SIGRTMIN+8 waybar
