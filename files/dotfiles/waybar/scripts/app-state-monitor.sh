#!/bin/bash

# App State Monitor - Monitors for app start/stop events
# Sends signal to Waybar to update immediately when apps change

WAYBAR_PID=$(pgrep waybar)

# Function to trigger Waybar update
trigger_update() {
    if [[ -n "$WAYBAR_PID" ]]; then
        # Send SIGUSR1 to Waybar to force refresh custom modules
        kill -USR1 $WAYBAR_PID 2>/dev/null || true
    fi
}

# Function to check if an important app is running
check_important_apps() {
    local apps=("spotify" "steam" "discord" "obs" "obs-studio")
    local flatpak_apps=("com.spotify.Client" "com.valvesoftware.Steam" "com.discordapp.Discord")
    
    for app in "${apps[@]}"; do
        if pgrep -x "$app" > /dev/null || pgrep -f "$app" > /dev/null; then
            return 0
        fi
    done
    
    for app in "${flatpak_apps[@]}"; do
        if flatpak ps --columns=application 2>/dev/null | grep -q "^$app$"; then
            return 0
        fi
    done
    
    return 1
}

# Monitor mode - watch for process changes
if [[ "$1" == "monitor" ]]; then
    echo "Starting app state monitor..."
    
    last_state=""
    
    while true; do
        current_apps=""
        
        # Build current state string
        if pgrep -x "spotify" > /dev/null || flatpak ps --columns=application 2>/dev/null | grep -q "^com.spotify.Client$"; then
            current_apps="${current_apps}spotify,"
        fi
        if pgrep -x "steam" > /dev/null || flatpak ps --columns=application 2>/dev/null | grep -q "^com.valvesoftware.Steam$"; then
            current_apps="${current_apps}steam,"
        fi
        if pgrep -x "discord" > /dev/null || flatpak ps --columns=application 2>/dev/null | grep -q "^com.discordapp.Discord$"; then
            current_apps="${current_apps}discord,"
        fi
        if pgrep -f "obs" > /dev/null; then
            current_apps="${current_apps}obs,"
        fi
        
        # If state changed, trigger update
        if [[ "$current_apps" != "$last_state" ]]; then
            echo "App state changed: $last_state -> $current_apps"
            trigger_update
            last_state="$current_apps"
        fi
        
        sleep 1
    done
elif [[ "$1" == "update" ]]; then
    # Manual update trigger
    trigger_update
else
    echo "Usage: $0 {monitor|update}"
    echo "  monitor - Start monitoring for app state changes"
    echo "  update  - Manually trigger Waybar update"
fi