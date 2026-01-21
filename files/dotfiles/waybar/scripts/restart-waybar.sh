#!/bin/bash

# Emergency Waybar restart script
echo "🔧 Waybar Emergency Restart"

# Check if Waybar is running
if pgrep waybar >/dev/null; then
    echo "✅ Waybar is currently running"
    read -p "Do you want to restart it anyway? (y/N): " restart
    if [[ ! "$restart" =~ ^[Yy]$ ]]; then
        echo "👍 Waybar restart cancelled"
        exit 0
    fi
fi

echo "🛑 Stopping Waybar..."
killall waybar 2>/dev/null || true
sleep 2

echo "🚀 Starting Waybar..."
nohup waybar > /dev/null 2>&1 &

sleep 2

if pgrep waybar >/dev/null; then
    echo "✅ SUCCESS: Waybar restarted successfully!"
    notify-send "🛡️ Waybar Restarted" "Your bar is back online!" -t 3000
else
    echo "❌ ERROR: Failed to restart Waybar"
    echo "Try running: waybar &"
fi