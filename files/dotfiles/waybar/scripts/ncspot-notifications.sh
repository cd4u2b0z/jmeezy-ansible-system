#!/bin/bash

# 🎵 Nord Theme ncspot Notifications for Mako
# Fixed script for ncspot MPRIS integration

# Function to get ncspot player info
get_ncspot_info() {
    # Try multiple ways to get ncspot player
    local ncspot_player=""
    
    # Method 1: Look for ncspot instance
    ncspot_player=$(playerctl --list-all 2>/dev/null | grep ncspot | head -1)
    
    # Method 2: Try direct ncspot reference
    if [[ -z "$ncspot_player" ]]; then
        ncspot_player="ncspot"
    fi
    
    echo "$ncspot_player"
}

# Function to send ncspot notification
send_ncspot_notification() {
    local player=$(get_ncspot_info)
    
    if [[ -z "$player" ]]; then
        echo "❌ ncspot not found"
        return 1
    fi
    
    # Get track info
    local title=$(playerctl -p "$player" metadata title 2>/dev/null || echo "")
    local artist=$(playerctl -p "$player" metadata artist 2>/dev/null || echo "")
    local album=$(playerctl -p "$player" metadata album 2>/dev/null || echo "")
    local status=$(playerctl -p "$player" status 2>/dev/null || echo "")
    
    # Check if we have valid data
    if [[ -z "$title" || -z "$artist" ]]; then
        notify-send -a "ncspot" \
            "🎵 ncspot" \
            "No track information available" \
            --expire-time=2000
        return 1
    fi
    
    # Choose icon and action based on status
    local icon="🎵"
    local action_text="Playing"
    
    case "$status" in
        "Playing")
            icon="▶️"
            action_text="Now Playing"
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
    
    # Send notification with Nord theme styling
    notify-send -a "ncspot" \
        "$icon $action_text" \
        "$title\n♪ $artist${album:+ • $album}" \
        --expire-time=4000
    
    echo "✅ Sent: $title by $artist ($status)"
}

# Function to monitor ncspot events
monitor_ncspot() {
    local player=$(get_ncspot_info)
    
    if [[ -z "$player" ]]; then
        echo "❌ ncspot not found for monitoring"
        return 1
    fi
    
    echo "🎵 Monitoring ncspot notifications..."
    
    # Monitor for play/pause/track changes
    playerctl -p "$player" -F metadata --format '{{status}}|{{title}}|{{artist}}' 2>/dev/null | \
    while IFS='|' read -r status title artist; do
        if [[ -n "$title" && -n "$artist" ]]; then
            send_ncspot_notification
            sleep 1  # Prevent spam
        fi
    done &
    
    # Keep script running
    wait
}

# Function to control ncspot with notifications
control_ncspot() {
    local action="$1"
    local player=$(get_ncspot_info)
    
    if [[ -z "$player" ]]; then
        notify-send -a "ncspot" "❌ ncspot Error" "ncspot not running" --expire-time=2000
        return 1
    fi
    
    case "$action" in
        "toggle"|"playpause")
            playerctl -p "$player" play-pause 2>/dev/null
            sleep 0.5
            send_ncspot_notification
            ;;
        "next")
            playerctl -p "$player" next 2>/dev/null
            sleep 1
            send_ncspot_notification
            ;;
        "previous"|"prev")
            playerctl -p "$player" previous 2>/dev/null
            sleep 1
            send_ncspot_notification
            ;;
        *)
            echo "Unknown action: $action"
            return 1
            ;;
    esac
}

# Main function
main() {
    local command="$1"
    local param="$2"
    
    case "$command" in
        "notify")
            # Send notification for current track
            send_ncspot_notification
            ;;
        "monitor")
            # Start monitoring mode
            monitor_ncspot
            ;;
        "test")
            # Test notification system
            notify-send -a "ncspot" \
                "🎵 ncspot Notifications" \
                "Test notification\nMako integration working!" \
                --expire-time=4000
            echo "✅ Test notification sent"
            ;;
        "toggle"|"next"|"previous"|"prev")
            # Control ncspot with notifications
            control_ncspot "$command"
            ;;
        "status")
            # Show current status
            local player=$(get_ncspot_info)
            if [[ -n "$player" ]]; then
                echo "Player: $player"
                echo "Status: $(playerctl -p "$player" status 2>/dev/null || echo "Unknown")"
                echo "Title: $(playerctl -p "$player" metadata title 2>/dev/null || echo "Unknown")"
                echo "Artist: $(playerctl -p "$player" metadata artist 2>/dev/null || echo "Unknown")"
            else
                echo "❌ ncspot not found"
            fi
            ;;
        *)
            echo "🎵 ncspot Notification Script"
            echo ""
            echo "Usage: $0 {command}"
            echo ""
            echo "Commands:"
            echo "  notify     - Send notification for current track"
            echo "  monitor    - Start monitoring for track changes"
            echo "  test       - Send test notification"
            echo "  toggle     - Toggle play/pause with notification"
            echo "  next       - Next track with notification"
            echo "  previous   - Previous track with notification"
            echo "  status     - Show current ncspot status"
            echo ""
            echo "Examples:"
            echo "  $0 test"
            echo "  $0 notify"
            echo "  $0 monitor &"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"