#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# 🎵 WAYBAR MUSIC DISPLAY - Multi-Platform Support
# Supports Spotify, YouTube Music, VLC, and more
# ═══════════════════════════════════════════════════════════════════

get_music_info() {
    # Try playerctl first (works with most media players)
    if command -v playerctl >/dev/null 2>&1; then
        local status=$(playerctl status 2>/dev/null)
        
        if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
            local artist=$(playerctl metadata artist 2>/dev/null)
            local title=$(playerctl metadata title 2>/dev/null)
            local player=$(playerctl metadata --format '{{ playerName }}' 2>/dev/null)
            
            if [ -n "$artist" ] && [ -n "$title" ]; then
                # Truncate long strings
                if [ ${#artist} -gt 20 ]; then
                    artist="${artist:0:17}..."
                fi
                if [ ${#title} -gt 25 ]; then
                    title="${title:0:22}..."
                fi
                
                # Format output based on player
                case "$player" in
                    "spotify")
                        echo " $artist - $title"
                        ;;
                    "firefox" | "chromium" | "chrome")
                        echo " $artist - $title"
                        ;;
                    "vlc")
                        echo " $artist - $title"
                        ;;
                    *)
                        echo " $artist - $title"
                        ;;
                esac
                return 0
            fi
        fi
    fi
    
    # Fallback: Check for Spotify directly
    if pgrep -x "spotify" >/dev/null; then
        echo " Spotify"
        return 0
    fi
    
    # Fallback: Check for common media players
    if pgrep -f "youtube" >/dev/null; then
        echo " YouTube"
        return 0
    fi
    
    if pgrep -x "vlc" >/dev/null; then
        echo " VLC Player"
        return 0
    fi
    
    # No music playing
    echo " No Music"
    return 1
}

# Handle click events
handle_click() {
    case "$1" in
        "left")
            # Play/Pause toggle
            if command -v playerctl >/dev/null 2>&1; then
                playerctl play-pause 2>/dev/null
            fi
            ;;
        "right")
            # Next track
            if command -v playerctl >/dev/null 2>&1; then
                playerctl next 2>/dev/null
            fi
            ;;
        "middle")
            # Previous track
            if command -v playerctl >/dev/null 2>&1; then
                playerctl previous 2>/dev/null
            fi
            ;;
    esac
}

# Main execution
case "${1:-info}" in
    "info")
        get_music_info
        ;;
    "left"|"right"|"middle")
        handle_click "$1"
        ;;
    "tooltip")
        if command -v playerctl >/dev/null 2>&1; then
            local status=$(playerctl status 2>/dev/null)
            if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
                local artist=$(playerctl metadata artist 2>/dev/null)
                local title=$(playerctl metadata title 2>/dev/null)
                local album=$(playerctl metadata album 2>/dev/null)
                local player=$(playerctl metadata --format '{{ playerName }}' 2>/dev/null)
                
                echo "Player: $player"
                echo "Status: $status"
                [ -n "$artist" ] && echo "Artist: $artist"
                [ -n "$title" ] && echo "Title: $title"
                [ -n "$album" ] && echo "Album: $album"
            else
                echo "No music currently playing"
            fi
        else
            echo "Install playerctl for full functionality"
        fi
        ;;
esac