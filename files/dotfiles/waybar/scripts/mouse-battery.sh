#!/bin/bash

# Mouse battery monitoring script for Waybar
# Monitors wireless mouse battery levels via upower

get_mouse_battery() {
    # Find mouse device
    mouse_device=$(upower -e | grep -E "(mouse|Mouse)" | head -1)
    
    if [[ -z "$mouse_device" ]]; then
        # Try alternative device paths
        mouse_device=$(upower -e | grep -E "BAT.*mouse|mouse.*BAT" | head -1)
    fi
    
    if [[ -z "$mouse_device" ]]; then
        echo "{\"text\":\"N/A\",\"alt\":\"N/A\",\"tooltip\":\"No wireless mouse detected\",\"class\":\"unknown\"}"
        return 1
    fi
    
    # Get battery info
    info=$(upower -i "$mouse_device" 2>/dev/null)
    
    if [[ -z "$info" ]]; then
        echo "{\"text\":\"N/A\",\"alt\":\"N/A\",\"tooltip\":\"Mouse battery info unavailable\",\"class\":\"unknown\"}"
        return 1
    fi
    
    # Extract percentage
    percentage=$(echo "$info" | grep -E "percentage" | grep -o '[0-9]*')
    
    if [[ -z "$percentage" ]]; then
        echo "{\"text\":\"N/A\",\"alt\":\"N/A\",\"tooltip\":\"Mouse battery percentage unavailable\",\"class\":\"unknown\"}"
        return 1
    fi
    
    # Determine battery level
    if [[ $percentage -le 15 ]]; then
        level="critical"
        class="critical"
    elif [[ $percentage -le 30 ]]; then
        level="low"
        class="low"
    elif [[ $percentage -le 60 ]]; then
        level="medium"
        class="medium"
    elif [[ $percentage -le 90 ]]; then
        level="high"
        class="high"
    else
        level="full"
        class="full"
    fi
    
    # Get device name for tooltip
    device_name=$(echo "$info" | grep -E "model:" | cut -d: -f2 | xargs)
    if [[ -z "$device_name" ]]; then
        device_name="Wireless Mouse"
    fi
    
    echo "{\"text\":\"$percentage\",\"alt\":\"$percentage\",\"tooltip\":\"$device_name: ${percentage}%\",\"class\":\"$class\"}"
}

# Handle script arguments
case "${1:-info}" in
    "info"|"")
        get_mouse_battery
        ;;
    "refresh")
        get_mouse_battery
        ;;
    *)
        get_mouse_battery
        ;;
esac