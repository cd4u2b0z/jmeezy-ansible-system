#!/bin/bash

# Window Transparency Controller for Hyprland
# Mimics Linux Mint's Ctrl+- and Ctrl++ transparency controls

# Get current window alpha value
get_current_alpha() {
    # Get the active window's alpha property
    hyprctl activewindow -j | jq -r '.alpha // 1.0' 2>/dev/null || echo "1.0"
}

# Set window alpha with bounds checking
set_alpha() {
    local new_alpha="$1"
    
    # Ensure alpha is between 0.1 and 1.0
    if (( $(echo "$new_alpha < 0.1" | bc -l) )); then
        new_alpha="0.1"
    elif (( $(echo "$new_alpha > 1.0" | bc -l) )); then
        new_alpha="1.0"
    fi
    
    # Apply the alpha to the active window
    hyprctl dispatch setprop active alpha "$new_alpha"
    
    # Show notification with transparency percentage
    local percentage=$(echo "scale=0; $new_alpha * 100 / 1" | bc -l)
    notify-send "Window Transparency" "Opacity: ${percentage}%" -t 1000 -h string:x-canonical-private-synchronous:transparency
}

# Main function
case "$1" in
    "decrease"|"down"|"-")
        current=$(get_current_alpha)
        new_alpha=$(echo "scale=2; $current - 0.1" | bc -l)
        set_alpha "$new_alpha"
        ;;
    "increase"|"up"|"+")
        current=$(get_current_alpha)
        new_alpha=$(echo "scale=2; $current + 0.1" | bc -l)
        set_alpha "$new_alpha"
        ;;
    "reset"|"1"|"opaque")
        set_alpha "1.0"
        ;;
    "half"|"0.5")
        set_alpha "0.5"
        ;;
    "quarter"|"0.25")
        set_alpha "0.25"
        ;;
    *)
        echo "Usage: $0 {decrease|increase|reset|half|quarter}"
        echo "  decrease/down/-  : Decrease opacity by 10%"
        echo "  increase/up/+    : Increase opacity by 10%"
        echo "  reset/1/opaque   : Reset to fully opaque"
        echo "  half/0.5         : Set to 50% opacity"
        echo "  quarter/0.25     : Set to 25% opacity"
        exit 1
        ;;
esac