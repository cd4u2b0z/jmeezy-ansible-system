#!/bin/bash
# Dynamic Music Player for Waybar - Spotify/ncspot priority

escape_pango() {
    echo "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g'
}

# Find spotify or ncspot player specifically
PLAYER=$(playerctl -l 2>/dev/null | grep -E "spotify|ncspot" | head -1)

# No music player found
if [[ -z "$PLAYER" ]]; then
    echo '{"text": "", "class": "hidden"}'
    exit 0
fi

# Get status from the specific player
STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)

# Get metadata from specific player
ARTIST_RAW=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null | cut -c1-25)
TITLE_RAW=$(playerctl -p "$PLAYER" metadata title 2>/dev/null | cut -c1-30)
ALBUM_RAW=$(playerctl -p "$PLAYER" metadata album 2>/dev/null)

# If no title, hide
if [[ -z "$TITLE_RAW" ]]; then
    echo '{"text": "", "class": "hidden"}'
    exit 0
fi

ARTIST=$(escape_pango "$ARTIST_RAW")
TITLE=$(escape_pango "$TITLE_RAW")
ALBUM=$(escape_pango "$ALBUM_RAW")

# Icon and class based on status
if [[ "$STATUS" == "Playing" ]]; then
    ICON=""
    CLASS="playing"
elif [[ "$STATUS" == "Paused" ]]; then
    ICON=""
    CLASS="paused"
else
    ICON=""
    CLASS="paused"
fi

# Build display text
if [[ -n "$ARTIST" && -n "$TITLE" ]]; then
    TEXT="$ICON  $ARTIST - $TITLE"
else
    TEXT="$ICON  $TITLE"
fi

TOOLTIP="$TITLE\\n$ARTIST\\n$ALBUM"

echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
