#!/bin/bash

# Get system stats tooltip from your existing script  
stats=$(~/.config/waybar/scripts/system-monitor.sh 2>/dev/null | jq -r '.tooltip')

# Output JSON with microchip icon and tooltip containing the stats
echo "{\"text\":\"󰍛\",\"tooltip\":\"$stats\"}"
