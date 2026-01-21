#!/usr/bin/env bash

# Enhanced App Manager - Ultra-smooth interactions
# Optimized for speed and responsiveness

# Cache running apps for instant response
CACHE_FILE="/tmp/waybar_apps_cache"

# App definitions with launch commands
declare -A APPS=(
    ["spotify"]="󰓇|Spotify|com.spotify.Client|flatpak run com.spotify.Client|Spotify"
    ["steam"]="󰓓|Steam|steam|steam|steam"
    ["discord"]="󰙯|Discord|com.discordapp.Discord|flatpak run com.discordapp.Discord|discord"
    ["obs"]="󰑋|OBS Studio|obs-studio|obs-studio|obs"
    ["vscode"]="󰨞|VS Code|code|code|code"
    ["firefox"]="󰈹|Firefox|firefox|firefox|firefox"
)

# Fast app detection
is_app_running() {
    local app="$1"
    local app_data="${APPS[$app]}"
    IFS='|' read -r icon name flatpak_id launch_cmd window <<< "$app_data"
    
    # Check processes
    if pgrep -x "${launch_cmd%% *}" >/dev/null 2>&1; then
        return 0
    fi
    
    # Check flatpaks
    if [[ -n "$flatpak_id" ]]; then
        if flatpak ps --columns=application 2>/dev/null | grep -q "^$flatpak_id$"; then
            return 0
        fi
    fi
    
    # Special case for Spotify
    if [[ "$app" == "spotify" && $(playerctl -l 2>/dev/null | grep -c spotify) -gt 0 ]]; then
        return 0
    fi
    
    return 1
}

# Fast focus function
focus_app() {
    local window="$1"
    local name="$2"
    
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl dispatch focuswindow "class:$window" 2>/dev/null
        notify-send "󱂬 App Manager" "Focused $name" -t 1000 -h string:category:app-manager
    fi
}

# Fast launch function
launch_app() {
    local cmd="$1"
    local name="$2"
    
    eval "$cmd >/dev/null 2>&1 &"
    notify-send "󱂬 App Manager" "Launching $name..." -t 1500 -h string:category:app-manager
    
    # Clear cache to force immediate refresh
    rm -f "$CACHE_FILE" 2>/dev/null
    pkill -RTMIN+8 waybar 2>/dev/null
}

# Build menu dynamically
build_menu() {
    local menu_items=()
    local running_count=0
    
    # Running apps section
    for app in spotify obs steam discord vscode firefox; do
        if is_app_running "$app"; then
            local app_data="${APPS[$app]}"
            IFS='|' read -r icon name flatpak_id launch_cmd window <<< "$app_data"
            
            menu_items+=("$icon  Focus $name|focus|$window|$name")
            menu_items+=("󰅖  Close $name|close|$app|$name")
            ((running_count++))
        fi
    done
    
    # Separator if needed
    if [[ $running_count -gt 0 ]]; then
        local non_running_count=0
        for app in spotify obs steam discord vscode firefox; do
            if ! is_app_running "$app"; then
                ((non_running_count++))
            fi
        done
        
        if [[ $non_running_count -gt 0 ]]; then
            menu_items+=("────────────────|separator||")
        fi
    fi
    
    # Launch apps section
    for app in spotify obs steam discord vscode firefox; do
        if ! is_app_running "$app"; then
            local app_data="${APPS[$app]}"
            IFS='|' read -r icon name flatpak_id launch_cmd window <<< "$app_data"
            
            menu_items+=("$icon  Launch $name|launch|$launch_cmd|$name")
        fi
    done
    
    printf '%s\n' "${menu_items[@]}"
}

# Show menu with wofi
show_menu() {
    local menu_content
    menu_content=$(build_menu)
    
    if [[ -z "$menu_content" ]]; then
        notify-send "󱂬 App Manager" "No apps available" -t 1500
        exit 0
    fi
    
    # Format menu for display
    local display_menu
    display_menu=$(echo "$menu_content" | cut -d'|' -f1)
    
    if command -v wofi >/dev/null 2>&1; then
        local selection
        selection=$(echo "$display_menu" | wofi \
            --dmenu \
            --prompt "󱂬 App Manager" \
            --height 400 \
            --width 320 \
            --xoffset -10 \
            --yoffset 55 \
            --location top_left \
            --allow-markup \
            --hide-scroll \
            --no-actions \
            --style ~/.config/wofi/style.css 2>/dev/null)
        
        if [[ -n "$selection" && "$selection" != "────────────────" ]]; then
            # Find and execute the action
            while IFS= read -r line; do
                local display_text action param name
                IFS='|' read -r display_text action param name <<< "$line"
                
                if [[ "$display_text" == "$selection" ]]; then
                    case "$action" in
                        "focus")
                            focus_app "$param" "$name"
                            ;;
                        "launch")
                            launch_app "$param" "$name"
                            ;;
                        "close")
                            pkill -f "$param" 2>/dev/null
                            if [[ "$param" == "spotify" ]]; then
                                flatpak kill com.spotify.Client 2>/dev/null
                            elif [[ "$param" == "discord" ]]; then
                                flatpak kill com.discordapp.Discord 2>/dev/null
                            fi
                            notify-send "󱂬 App Manager" "Closed $name" -t 1000
                            rm -f "$CACHE_FILE" 2>/dev/null
                            pkill -RTMIN+8 waybar 2>/dev/null
                            ;;
                    esac
                    break
                fi
            done <<< "$menu_content"
        fi
    else
        notify-send "󱂬 App Manager" "Wofi not found - install wofi for app management" -t 3000
    fi
}

show_menu