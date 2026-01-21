#!/bin/bash

# Music Monitor Service - Runs in background to send notifications
# This script monitors all media players and sends notifications for track changes

MONITOR_PID_FILE="/tmp/music-monitor.pid"

# Function to clean up on exit
cleanup() {
    echo "Stopping music monitor..."
    if [[ -f "$MONITOR_PID_FILE" ]]; then
        rm "$MONITOR_PID_FILE"
    fi
    # Kill any background processes
    pkill -P $$
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM EXIT

# Function to monitor a specific player
monitor_player() {
    local player="$1"
    echo "Monitoring player: $player"
    
    playerctl -p "$player" -F metadata --format '{{status}}|{{title}}|{{artist}}' 2>/dev/null | \
    while IFS='|' read -r status title artist; do
        if [[ -n "$title" && -n "$artist" && "$title" != "No players found" ]]; then
            # Only notify on status changes or new tracks
            local cache_key="${player}_${title}_${artist}"
            local cache_file="/tmp/music_cache_${player}"
            local last_track=""
            
            if [[ -f "$cache_file" ]]; then
                last_track=$(cat "$cache_file")
            fi
            
            if [[ "$cache_key" != "$last_track" ]]; then
                echo "$cache_key" > "$cache_file"
                
                # Send notification
                local icon="🎵"
                case "$status" in
                    "Playing") icon="▶️" ;;
                    "Paused") icon="⏸️" ;;
                    "Stopped") icon="⏹️" ;;
                esac
                
                # Choose app name for proper styling
                local app_name="Music"
                if [[ "$player" == *"spotify"* ]]; then
                    app_name="Spotify"
                elif [[ "$player" == *"ncspot"* ]]; then
                    app_name="ncspot"
                elif [[ "$player" == *"vlc"* ]]; then
                    app_name="VLC"
                fi
                
                notify-send -a "$app_name" -i audio-x-generic \
                    "$icon $title" \
                    "by $artist" \
                    --expire-time=3000
            fi
        fi
    done &
}

# Main function
main() {
    case "$1" in
        "start")
            if [[ -f "$MONITOR_PID_FILE" ]]; then
                echo "Music monitor already running (PID: $(cat $MONITOR_PID_FILE))"
                exit 1
            fi
            
            echo $$ > "$MONITOR_PID_FILE"
            echo "Starting music notification monitor..."
            
            # Monitor all available players
            while true; do
                local players=$(playerctl -l 2>/dev/null || echo "")
                
                if [[ -n "$players" ]]; then
                    for player in $players; do
                        # Check if we're already monitoring this player
                        if ! pgrep -f "playerctl.*$player.*metadata" > /dev/null; then
                            monitor_player "$player"
                        fi
                    done
                fi
                
                sleep 5  # Check for new players every 5 seconds
            done
            ;;
        "stop")
            if [[ -f "$MONITOR_PID_FILE" ]]; then
                local pid=$(cat "$MONITOR_PID_FILE")
                echo "Stopping music monitor (PID: $pid)..."
                kill "$pid" 2>/dev/null || true
                rm "$MONITOR_PID_FILE" 2>/dev/null || true
            else
                echo "Music monitor not running"
            fi
            ;;
        "status")
            if [[ -f "$MONITOR_PID_FILE" ]]; then
                local pid=$(cat "$MONITOR_PID_FILE")
                if kill -0 "$pid" 2>/dev/null; then
                    echo "Music monitor running (PID: $pid)"
                else
                    echo "Music monitor PID file exists but process not running"
                    rm "$MONITOR_PID_FILE"
                fi
            else
                echo "Music monitor not running"
            fi
            ;;
        "restart")
            $0 stop
            sleep 2
            $0 start
            ;;
        *)
            echo "Usage: $0 {start|stop|status|restart}"
            echo "  start   - Start monitoring music players"
            echo "  stop    - Stop monitoring"
            echo "  status  - Check if monitor is running"
            echo "  restart - Restart the monitor"
            exit 1
            ;;
    esac
}

main "$@"