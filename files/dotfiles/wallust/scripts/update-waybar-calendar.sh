#!/bin/bash
# Updates waybar config calendar colors from wallust-generated CSS

CSS=~/.config/waybar/wallust-colors.css
CONFIG=~/.config/waybar/config

# Extract colors from CSS
background=$(grep '@define-color background' "$CSS" | sed 's/.*#\([0-9A-Fa-f]\{6\}\).*/\1/')
foreground=$(grep '@define-color foreground' "$CSS" | sed 's/.*#\([0-9A-Fa-f]\{6\}\).*/\1/')
color2=$(grep '@define-color color2' "$CSS" | sed 's/.*#\([0-9A-Fa-f]\{6\}\).*/\1/')
color4=$(grep '@define-color color4' "$CSS" | sed 's/.*#\([0-9A-Fa-f]\{6\}\).*/\1/')
color8=$(grep '@define-color color8' "$CSS" | sed 's/.*#\([0-9A-Fa-f]\{6\}\).*/\1/')

# Update calendar colors
sed -i "s|\"months\": \"<span color='#[0-9A-Fa-f]\{6\}'|\"months\": \"<span color='#$foreground'|" "$CONFIG"
sed -i "s|\"days\": \"<span color='#[0-9A-Fa-f]\{6\}'|\"days\": \"<span color='#$foreground'|" "$CONFIG"
sed -i "s|\"weeks\": \"<span color='#[0-9A-Fa-f]\{6\}'|\"weeks\": \"<span color='#$color8'|" "$CONFIG"
sed -i "s|\"weekdays\": \"<span color='#[0-9A-Fa-f]\{6\}'|\"weekdays\": \"<span color='#$color4'|" "$CONFIG"
sed -i "s|\"today\": \"<span background='#[0-9A-Fa-f]\{6\}' color='#[0-9A-Fa-f]\{6\}'|\"today\": \"<span background='#$color2' color='#$background'|" "$CONFIG"

# Restart waybar to apply
pkill waybar
sleep 0.3
waybar &
