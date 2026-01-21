#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# 🔄 WAYBAR LAUNCHER & RESTART SCRIPT
# Clean restart of Waybar with error handling
# ═══════════════════════════════════════════════════════════════════

# Kill existing Waybar instances
pkill waybar 2>/dev/null

# Wait a moment for clean shutdown
sleep 1

# Check if config exists
if [ ! -f "$HOME/.config/waybar/config" ]; then
    echo "❌ Waybar config not found at $HOME/.config/waybar/config"
    exit 1
fi

if [ ! -f "$HOME/.config/waybar/style.css" ]; then
    echo "❌ Waybar style not found at $HOME/.config/waybar/style.css"
    exit 1
fi

# Launch Waybar in background (survives terminal closure)
echo "🚀 Starting Waybar in background..."
nohup waybar -c "$HOME/.config/waybar/config" -s "$HOME/.config/waybar/style.css" > /dev/null 2>&1 &

# Check if it started successfully
sleep 2
if pgrep waybar >/dev/null; then
    echo "✅ Waybar started successfully and running in background!"
    echo "🌨️ Your wild Nordic Waybar is now immortal - it will survive terminal closures!"
else
    echo "❌ Failed to start Waybar. Check configuration."
    exit 1
fi