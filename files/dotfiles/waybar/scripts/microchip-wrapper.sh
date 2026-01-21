#!/bin/bash

# Get system stats from your original script and extract just the tooltip content
original_output=$(~/.config/waybar/scripts/system-monitor.sh 2>/dev/null)

# Extract the tooltip content between the quotes after "tooltip":"
tooltip=$(echo "$original_output" | sed 's/.*"tooltip":"\([^"]*\)".*/\1/')

# Output just the microchip icon with the system stats as tooltip and class for styling
echo "{\"text\":\"󰘚\",\"tooltip\":\"$tooltip\",\"class\":\"system-stats\"}"
