#!/bin/bash

# Music Notification Script with Spotify Integration
# Monitors playerctl events and sends Mako notifications

# Function to get player info
get_player_info() {
    local player="$1"
    local title=$(playerctl -p "$player" metadata title 2>/dev/null || echo "Unknown Track")
    local artist=$(playerctl -p "$player" metadata artist 2>/dev/null || echo "Unknown Artist")
    local album=$(playerctl -p "$player" metadata album 2>/dev/null || echo "Unknown Album")
    local status=$(playerctl -p "$player" status 2>/dev/null || echo "Unknown")
    
    echo "$title|$artist|$album|$status"
}

# Function to send music notification
send_music_notification() {
    local player="$1"
    local info=$(get_player_info "$player")
    
    IFS='|' read -r title artist album status <<< "$info"
    
    # Choose icon based on status
    local icon="🎵"
    local action_text=""
    
    case "$status" in
        "Playing")
            icon="▶️"
            action_text="Playing"
            ;;
        "Paused")
            icon="⏸️"
            action_text="Paused"
            ;;
        "Stopped")
            icon="⏹️"
            action_text="Stopped"
            ;;
    esac
    
    # Send notification with appropriate app name for styling
    if [[ "$player" == *"spotify"* ]]; then
        notify-send -a "Spotify" -i audio-x-generic \
            "$icon $action_text" \
            "$title\nby $artist" \
            --expire-time=3000
    else
        # Use default grey Nord theme for ncspot and other players
        notify-send -i audio-x-generic \
            "$icon $action_text" \
            "$title\nby $artist" \
            --expire-time=3000
    fi
}

# Function to monitor player events
monitor_player_events() {
    local player="$1"
    
    # Monitor for play/pause/track changes
    playerctl -p "$player" -F metadata --format '{{playerName}}|{{status}}|{{title}}|{{artist}}' 2>/dev/null | \
    while IFS='|' read -r player_name status title artist; do
        if [[ -n "$title" && -n "$artist" ]]; then
            send_music_notification "$player"
        fi
    done &
}

# Main function
main() {
    local command="$1"
    local player="${2:-spotify}"
    
    case "$command" in
        "notify")
            # Send immediate notification for current track
            send_music_notification "$player"
            ;;
        "monitor")
            # Start monitoring mode
            echo "Starting music notification monitor for $player..."
            monitor_player_events "$player"
            wait
            ;;
        "test")
            # Test notification
            notify-send -a "Spotify" -i audio-x-generic \
                "🎵 Music Notifications" \
                "Test notification for Spotify\nNotifications are working!" \
                --expire-time=4000
            ;;
        "toggle")
            # Toggle play/pause and notify
            playerctl -p "$player" play-pause 2>/dev/null
            sleep 0.5  # Wait for status to update
            send_music_notification "$player"
            ;;
        "next")
            # Next track and notify
            playerctl -p "$player" next 2>/dev/null
            sleep 1  # Wait for track to change
            send_music_notification "$player"
            ;;
        "previous")
            # Previous track and notify
            playerctl -p "$player" previous 2>/dev/null
            sleep 1  # Wait for track to change
            send_music_notification "$player"
            ;;
        *)
            echo "Usage: $0 {notify|monitor|test|toggle|next|previous} [player]"
            echo "  notify   - Send notification for current track"
            echo "  monitor  - Start monitoring for track changes"
            echo "  test     - Send test notification"
            echo "  toggle   - Toggle play/pause with notification"
            echo "  next     - Next track with notification"
            echo "  previous - Previous track with notification"
            echo "  player   - Specify player (default: spotify)"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"