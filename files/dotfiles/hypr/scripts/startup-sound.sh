#!/bin/bash
# Wait for PipeWire to be fully ready before playing startup sound

LOG="/tmp/startup-sound.log"
SOUND_FILE="$HOME/.local/share/sounds/Windows_Vista_Boot.wav"
MAX_WAIT=15

echo "$(date): Script started" > "$LOG"

# Wait for PipeWire AND a valid sink
for i in $(seq 1 $MAX_WAIT); do
    if pw-cli info 0 &>/dev/null && pactl get-sink-volume @DEFAULT_SINK@ &>/dev/null; then
        echo "$(date): PipeWire ready after $i seconds" >> "$LOG"
        sleep 1
        echo "$(date): Playing sound" >> "$LOG"
        pw-play "$SOUND_FILE" 2>> "$LOG"
        echo "$(date): Done (exit code: $?)" >> "$LOG"
        exit 0
    fi
    echo "$(date): Waiting... ($i/$MAX_WAIT)" >> "$LOG"
    sleep 1
done

echo "$(date): Timeout - trying anyway" >> "$LOG"
pw-play "$SOUND_FILE" 2>> "$LOG"
echo "$(date): Fallback done (exit code: $?)" >> "$LOG"
