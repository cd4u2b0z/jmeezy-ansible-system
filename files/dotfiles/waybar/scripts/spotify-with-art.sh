#!/bin/bash

# Spotify with Album Art - Advanced Ricer Edition
# Returns JSON with album art, song info, and controls

# Check if Spotify is running
if ! pgrep -x "spotify" > /dev/null; then
    echo '{"text": "󰝚 No Music", "class": "stopped", "tooltip": "Spotify is not running"}'
    exit 0
fi

# Get Spotify metadata using playerctl
STATUS=$(playerctl -p spotify status 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$STATUS" ]; then
    echo '{"text": "󰝚 No Music", "class": "stopped", "tooltip": "No media playing"}'
    exit 0
fi

# Get track information
ARTIST=$(playerctl -p spotify metadata artist 2>/dev/null)
TITLE=$(playerctl -p spotify metadata title 2>/dev/null)
ALBUM=$(playerctl -p spotify metadata album 2>/dev/null)
ART_URL=$(playerctl -p spotify metadata mpris:artUrl 2>/dev/null)

# Fallback if no metadata
if [ -z "$ARTIST" ] || [ -z "$TITLE" ]; then
    echo '{"text": "󰝚 Spotify", "class": "unknown", "tooltip": "Getting track info..."}'
    exit 0
fi

# Truncate long strings
if [ ${#ARTIST} -gt 15 ]; then
    ARTIST="${ARTIST:0:15}..."
fi
if [ ${#TITLE} -gt 20 ]; then
    TITLE="${TITLE:0:20}..."
fi

# Status icons
case $STATUS in
    "Playing")
        ICON="󰐊"
        CLASS="playing"
        ;;
    "Paused")
        ICON="󰏤"
        CLASS="paused"
        ;;
    *)
        ICON="󰝚"
        CLASS="stopped"
        ;;
esac

# Create display text
TEXT="$ICON $ARTIST - $TITLE"

# Create tooltip with album info
TOOLTIP="$ARTIST\n$TITLE\n$ALBUM\n\nLeft: Play/Pause\nRight: Next\nMiddle: Previous\nScroll: Volume"

# Output JSON
cat << EOF
{
    "text": "$TEXT",
    "class": "$CLASS",
    "tooltip": "$TOOLTIP"
}
EOF