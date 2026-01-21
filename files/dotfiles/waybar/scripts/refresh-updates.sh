#!/bin/bash
# Quick script to refresh the update module
# Use this if the update count gets stuck

echo "🔄 Refreshing Waybar update module..."

# Clear the cache
rm -f /tmp/waybar_updates_cache 2>/dev/null

# Signal Waybar to refresh
pkill -SIGRTMIN+8 waybar 2>/dev/null

# Run the updates wrapper to get fresh status
~/.config/waybar/scripts/updates-wrapper.sh

echo "✅ Update module refreshed!"
