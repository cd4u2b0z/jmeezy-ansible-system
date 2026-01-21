#!/bin/bash

# Keyboard battery monitoring script for Waybar
# Monitors wireless keyboard battery levels via upower

get_keyboard_battery() {
    # Find keyboard device
    keyboard_device=$(upower -e | grep -E "(kbd|keyboard|Keyboard)" | head -1)
    
    if [[ -z "$keyboard_device" ]]; then
        # Try alternative device paths
        keyboard_device=$(upower -e | grep -E "BAT.*kbd|kbd.*BAT|wireless.*keyboard" | head -1)
    fi
    
    if [[ -z "$keyboard_device" ]]; then
        echo "{\"text\":\"N/A\",\"alt\":\"N/A\",\"tooltip\":\"No wireless keyboard detected\",\"class\":\"unknown\"}"
        return 1
    fi
    
    # Get battery info
    info=$(upower -i "$keyboard_device" 2>/dev/null)
    
    if [[ -z "$info" ]]; then
        echo "{\"text\":\"N/A\",\"alt\":\"N/A\",\"tooltip\":\"Keyboard battery info unavailable\",\"class\":\"unknown\"}"
        return 1
    fi
    
    # Extract percentage
    percentage=$(echo "$info" | grep -E "percentage" | grep -o '[0-9]*')
    
    if [[ -z "$percentage" ]]; then
        echo "{\"text\":\"N/A\",\"alt\":\"N/A\",\"tooltip\":\"Keyboard battery percentage unavailable\",\"class\":\"unknown\"}"
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
        device_name="Wireless Keyboard"
    fi
    
    echo "{\"text\":\"$percentage\",\"alt\":\"$percentage\",\"tooltip\":\"$device_name: ${percentage}%\",\"class\":\"$class\"}"
}

# Handle script arguments
case "${1:-info}" in
    "info"|"")
        get_keyboard_battery
        ;;
    "refresh")
        get_keyboard_battery
        ;;
    *)
        get_keyboard_battery
        ;;
esac