#!/usr/bin/env bash

# Simple Enhanced App Tray - Reliable JSON output
# Shows ncspot as Spotify icon with kill functionality

# Simple app check function
check_app() {
    local app="$1"
    case "$app" in
        "spotify")
            # Check for ncspot or spotify
            if pgrep -f "ncspot" > /dev/null 2>&1; then
                echo "󰓇"
                return 0
            elif pgrep -f "spotify" > /dev/null 2>&1; then
                echo "󰓇"
                return 0
            elif flatpak ps --columns=application 2>/dev/null | grep -q "com.spotify.Client"; then
                echo "󰓇"
                return 0
            fi
            ;;
        "steam")
            if pgrep -f "steam" > /dev/null 2>&1 || flatpak ps --columns=application 2>/dev/null | grep -q "com.valvesoftware.Steam"; then
                echo "󰓓"
                return 0
            fi
            ;;
        "discord")
            if pgrep -f "discord" > /dev/null 2>&1 || flatpak ps --columns=application 2>/dev/null | grep -q "com.discordapp.Discord"; then
                echo "󰙯"
                return 0
            fi
            ;;
        "vscode")
            if pgrep -f "code" > /dev/null 2>&1; then
                echo "󰨞"
                return 0
            fi
            ;;
        "firefox")
            if pgrep -f "firefox" > /dev/null 2>&1 || flatpak ps --columns=application 2>/dev/null | grep -q "org.mozilla.firefox"; then
                echo "󰈹"
                return 0
            fi
            ;;
    esac
    return 1
}

# Build the tray
apps=("spotify" "steam" "discord" "vscode" "firefox")
running_icons=()
tooltips=()

for app in "${apps[@]}"; do
    if icon=$(check_app "$app"); then
        running_icons+=("$icon")
        case "$app" in
            "spotify") tooltips+=("Spotify (ncspot) - Left: Focus | Right: Kill") ;;
            "steam") tooltips+=("Steam - Left: Focus | Right: Kill") ;;
            "discord") tooltips+=("Discord - Left: Focus | Right: Kill") ;;
            "vscode") tooltips+=("VS Code - Left: Focus | Right: Kill") ;;
            "firefox") tooltips+=("Firefox - Left: Focus | Right: Kill") ;;
        esac
    fi
done

# Output JSON
if [[ ${#running_icons[@]} -eq 0 ]]; then
    echo '{"text": "", "tooltip": "No apps running", "class": "empty"}'
else
    text=$(IFS=' '; echo "${running_icons[*]}")
    tooltip=$(printf '%s\n' "${tooltips[@]}" | sed ':a;N;$!ba;s/\n/\\n/g')
    echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\", \"class\": \"running\"}"
fi