#!/bin/bash
# App Manager - Fast Focus/Kill/Launch menu with proper window handling

# Get all running windows once (faster than multiple calls)
WINDOWS=$(hyprctl clients -j 2>/dev/null)
WINDOW_CLASSES=$(echo "$WINDOWS" | jq -r '.[].class // empty' | tr '[:upper:]' '[:lower:]')

# Fast window check
is_running() { echo "$WINDOW_CLASSES" | grep -qi "^$1$"; }

# Focus window by class (brings all windows of that app to focus)
focus_app() {
    local class="$1"
    hyprctl dispatch focuswindow "class:(?i)$class" 2>/dev/null
}

# Kill all windows of an app gracefully
kill_app() {
    local class="$1"
    # Get all window addresses for this class
    local addrs=$(echo "$WINDOWS" | jq -r ".[] | select(.class | test(\"(?i)$class\")) | .address")
    for addr in $addrs; do
        hyprctl dispatch closewindow "address:$addr" 2>/dev/null
    done
}

# App definitions: key|name|icon|class|launch
APPS="brave|Brave|󰊽|brave-browser|brave
brave|Brave|󰊽|brave-browser|brave
librewolf|LibreWolf|󰈹|librewolf|librewolf
firefox|Firefox|󰈹|firefox|firefox
vscode|VS Code|󰨞|code|code
kitty|Kitty|󰄛|kitty|kitty
thunar|Thunar|󰉋|thunar|thunar
spotify|Spotify||spotify|spotify
ncspot|ncspot|󰎆|ncspot|kitty -e ncspot
discord|Discord|󰙯|discord|discord
steam|Steam|󰓓|steam|steam
obs|OBS|󰑋|obs|obs-studio
gimp|GIMP|󰏘|gimp|gimp
blender|Blender|󰂫|blender|blender"

menu=""
actions=""

# Build menu - running apps first (Focus and Close options)
while IFS='|' read -r key name icon class launch; do
    if is_running "$class"; then
        menu+="$icon  Focus $name\n"
        actions+="focus|$class|$name\n"
        menu+="󰅖  Close $name\n"
        actions+="close|$class|$name\n"
    fi
done <<< "$APPS"

# Track if we have running apps
[[ -n "$menu" ]] && has_running=1 || has_running=0

# Add launchable apps (not currently running)
launch_menu=""
launch_actions=""
while IFS='|' read -r key name icon class launch; do
    if ! is_running "$class" && command -v "${launch%% *}" >/dev/null 2>&1; then
        launch_menu+="$icon  Launch $name\n"
        launch_actions+="launch|$launch|$name\n"
    fi
done <<< "$APPS"

# Combine with separator
if [[ $has_running -eq 1 && -n "$launch_menu" ]]; then
    menu+="─────────────────\n"
    actions+="sep||\n"
fi
menu+="$launch_menu"
actions+="$launch_actions"

# Exit if nothing
[[ -z "$menu" ]] && { notify-send "App Manager" "No apps available" -t 800; exit 0; }

# Show fuzzel menu
selection=$(echo -e "${menu%\\n}" | fuzzel --anchor=top-left --x-margin=10 --y-margin=48 \
    --dmenu --prompt "  " --width 32)

[[ -z "$selection" || "$selection" == "─────────────────" ]] && exit 0

# Find and execute action
idx=1
while IFS= read -r line; do
    menu_line=$(echo -e "$menu" | sed -n "${idx}p")
    if [[ "$menu_line" == "$selection" ]]; then
        action=$(echo -e "$actions" | sed -n "${idx}p")
        IFS='|' read -r cmd arg name <<< "$action"
        case "$cmd" in
            focus) focus_app "$arg" ;;
            close) kill_app "$arg" ;;
            launch) eval "$arg > /dev/null 2>&1 &" ;;
        esac
        break
    fi
    ((idx++))
done <<< "$(echo -e "$menu")"
