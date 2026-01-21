#!/bin/bash

# Transparency Toggle - Enable/Disable globally
TOGGLE_FILE="/tmp/transparency_disabled"

if [[ -f "$TOGGLE_FILE" ]]; then
    rm "$TOGGLE_FILE"
    notify-send "🪟 Transparency Enabled" "Ctrl+- and Ctrl+= will work again" -t 2000
    echo "Transparency enabled"
else
    touch "$TOGGLE_FILE"
    notify-send "🚫 Transparency Disabled" "Ctrl+- and Ctrl+= are temporarily disabled" -t 2000
    echo "Transparency disabled"
fi