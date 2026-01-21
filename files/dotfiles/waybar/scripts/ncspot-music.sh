#!/bin/bash

# Waybar ncspot music module - shows only when actively playing
# Displays artist and title with clean formatting

# Check if ncspot is running
if ! pgrep -x ncspot > /dev/null; then
    echo ""  # Return empty string instead of exit
    exit 0
fi

# Get current playing info using playerctl (works with ncspot)
if command -v playerctl >/dev/null 2>&1; then
    # Check if music is actually playing (not paused)
    status=$(playerctl --player=ncspot status 2>/dev/null)
    
    if [[ "$status" == "Playing" ]]; then
        artist=$(playerctl --player=ncspot metadata artist 2>/dev/null)
        title=$(playerctl --player=ncspot metadata title 2>/dev/null)
        
        # Format and display if we have both artist and title
        if [[ -n "$artist" && -n "$title" ]]; then
            # Truncate long strings
            if [[ ${#artist} -gt 20 ]]; then
                artist="${artist:0:17}..."
            fi
            if [[ ${#title} -gt 25 ]]; then
                title="${title:0:22}..."
            fi
            
            echo "🎵 $artist - $title"
        else
            echo ""  # Return empty if no track info
        fi
    else
        echo ""  # Return empty if not playing
    fi
else
    # Fallback: check ncspot process and try to get info from ncspot itself
    if pgrep -x ncspot > /dev/null; then
        echo "🎵 Playing"
    else
        echo ""
    fi
fi