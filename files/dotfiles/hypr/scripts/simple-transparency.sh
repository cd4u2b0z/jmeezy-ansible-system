#!/bin/bash

# Simple Window Transparency Controller 
# Just like Linux Mint - two keys, slider behavior
# Safety: Prevents transparency on fullscreen games

# File to store current alpha state
ALPHA_FILE="/tmp/hypr_alpha_$(hyprctl activewindow -j | jq -r '.pid')"

# Check if current window should be protected from transparency
is_protected_window() {
    local window_info=$(hyprctl activewindow -j)
    local class=$(echo "$window_info" | jq -r '.class // ""' | tr '[:upper:]' '[:lower:]')
    local fullscreen=$(echo "$window_info" | jq -r '.fullscreen // false')
    local floating=$(echo "$window_info" | jq -r '.floating // false')
    
    # Protect fullscreen windows (likely games/videos)
    if [[ "$fullscreen" != "false" && "$fullscreen" != "0" ]]; then
        return 0  # Protected
    fi
    
    # Protect common gaming applications
    case "$class" in
        *steam*|*game*|*dota*|*csgo*|*valorant*|*minecraft*|*wow*|*overwatch*|*apex*|*fortnite*|*league*)
            return 0  # Protected
            ;;
        *vlc*|*mpv*|*netflix*|*youtube*|*twitch*)
            # Only protect if fullscreen
            if [[ "$fullscreen" != "false" && "$fullscreen" != "0" ]]; then
                return 0  # Protected
            fi
            ;;
    esac
    
    return 1  # Not protected
}

# Get current window alpha value
get_current_alpha() {
    if [[ -f "$ALPHA_FILE" ]]; then
        cat "$ALPHA_FILE"
    else
        echo "1.0"
    fi
}

# Set window alpha with bounds checking
set_alpha() {
    local new_alpha="$1"
    
    # Safety check for protected windows
    if is_protected_window; then
        local class=$(hyprctl activewindow -j | jq -r '.class // "Unknown"')
        notify-send "🎮 Protected Window" "Cannot change transparency of $class" -t 2000 -u normal
        return 1
    fi
    
    # Ensure alpha is between 0.1 and 1.0 (no cap!)
    if (( $(echo "$new_alpha < 0.1" | bc -l) )); then
        new_alpha="0.1"
    elif (( $(echo "$new_alpha > 1.0" | bc -l) )); then
        new_alpha="1.0"
    fi
    
    # Save the alpha value to file
    echo "$new_alpha" > "$ALPHA_FILE"
    
    # Apply the alpha to the active window
    hyprctl dispatch setprop active opacity "$new_alpha"
    
    # Simple notification with percentage
    local percentage=$(echo "scale=0; $new_alpha * 100 / 1" | bc -l)
    notify-send "Window Opacity" "${percentage}%" -t 800 -h string:x-canonical-private-synchronous:transparency
}

# Simple slider behavior
case "$1" in
    "decrease")
        # Check if transparency is globally disabled
        if [[ -f "/tmp/transparency_disabled" ]]; then
            notify-send "🚫 Transparency Disabled" "Use toggle to re-enable" -t 1000
            exit 0
        fi
        
        current=$(get_current_alpha)
        new_alpha=$(echo "scale=2; $current - 0.1" | bc -l)
        set_alpha "$new_alpha"
        ;;
    "increase")
        # Check if transparency is globally disabled
        if [[ -f "/tmp/transparency_disabled" ]]; then
            notify-send "🚫 Transparency Disabled" "Use toggle to re-enable" -t 1000
            exit 0
        fi
        
        current=$(get_current_alpha)
        new_alpha=$(echo "scale=2; $current + 0.1" | bc -l)
        set_alpha "$new_alpha"
        ;;
    *)
        echo "Usage: $0 {decrease|increase}"
        exit 1
        ;;
esac