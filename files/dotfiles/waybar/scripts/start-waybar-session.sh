#!/bin/bash

# Waybar Session Startup Script
# Starts all necessary daemons and services

echo "Starting Waybar session components..."

# Kill any existing instances to prevent conflicts
killall mako waybar 2>/dev/null || true
~/.config/waybar/scripts/music-monitor.sh stop 2>/dev/null || true

# Wait for cleanup
sleep 2

# Start Mako notification daemon
echo "Starting Mako notification daemon..."
mako &

# Wait for Mako to initialize
sleep 1

# Start music monitor service
echo "Starting music monitor service..."
~/.config/waybar/scripts/music-monitor.sh start &

# Wait for services to initialize
sleep 2

# Start Waybar with custom styling
echo "Starting Waybar..."
waybar -s ~/.config/waybar/style-test.css &

# Test notification to confirm everything is working
sleep 3
notify-send "Waybar Session" "All services started successfully!" --expire-time=3000

echo "Waybar session startup complete!"