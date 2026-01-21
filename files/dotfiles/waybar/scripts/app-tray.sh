#!/usr/bin/env bash
apps=()

# Check ncspot (show as Spotify)
if pgrep -x "ncspot" > /dev/null; then
    apps+=("Spotify")
fi

# Check other common apps
for app in firefox discord code; do
    if pgrep -x "$app" > /dev/null; then
        apps+=("$app")
    fi
done

# Output JSON
if [ ${#apps[@]} -eq 0 ]; then
    echo '{"text": "", "tooltip": "No apps running", "class": "empty"}'
else
    text="${apps[0]}"
    tooltip="Running: ${apps[*]} (Right-click to kill)"
    echo '{"text": "'$text'", "tooltip": "'$tooltip'", "class": "running"}'
fi
