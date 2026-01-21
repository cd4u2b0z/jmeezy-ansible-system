#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════════╗
# ║  🎨 THEME SWITCHER - System-wide theming with animations         ║
# ║  Powered by wallust + swww for craig@grim-reefer                 ║
# ╚══════════════════════════════════════════════════════════════════╝

# Use -u (undefined vars) and pipefail but NOT -e (exit on error)
# -e causes silent failures from keybinds when commands return non-zero
set -uo pipefail

# Error trapping for debugging
trap 'log "ERROR at line $LINENO: command \"$BASH_COMMAND\" failed with exit code $?"' ERR

# ═══════════════════════════════════════════════════════════════════
# � ENVIRONMENT SETUP (needed when running from keybind)
# ═══════════════════════════════════════════════════════════════════

# Ensure we have proper Wayland/Hyprland environment
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export HYPRLAND_INSTANCE_SIGNATURE="${HYPRLAND_INSTANCE_SIGNATURE:-$(ls -t "$XDG_RUNTIME_DIR/hypr/" 2>/dev/null | head -1)}"

# Ensure dbus session is available for gsettings
if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
fi

# ═══════════════════════════════════════════════════════════════════
# �📂 CONFIGURATION
# ═══════════════════════════════════════════════════════════════════

readonly WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
readonly THEME_DIR="$HOME/.config/themes"
readonly CONFIG_DIR="$HOME/.config/theme-switcher"
readonly CURRENT_THEME_FILE="$CONFIG_DIR/current-theme"
readonly LOG_FILE="$HOME/.local/log/theme-switcher.log"

# Transition settings for swww
readonly TRANSITION_TYPE="${SWWW_TRANSITION:-grow}"
readonly TRANSITION_DURATION="${SWWW_DURATION:-2}"
readonly TRANSITION_POS="${SWWW_POS:-center}"
readonly TRANSITION_FPS="${SWWW_FPS:-60}"

# ═══════════════════════════════════════════════════════════════════
# 🎨 POPULAR THEMES (wallust built-in + mapped wallpapers)
# ═══════════════════════════════════════════════════════════════════

declare -A THEME_WALLPAPERS=(
    ["Nord"]="girlinsnow.jpg"
    ["Gruvbox-Dark"]="stormiscoming.jpg"
    ["Catppuccin-Mocha"]="blue_woods.png"
    ["Dracula"]="Alex3.jpg"
    ["Tokyo-Night"]="blue_woods.png"
    ["Rosé-Pine"]="girlinsnow.jpg"
    ["Everforest-Dark-Medium"]="blue_woods.png"
    ["Solarized-Dark"]="white_dragon.png"
    ["One-Dark"]="stormiscoming.jpg"
    ["Kanagawa-Wave"]="white_dragon.png"
)

# Papirus folder colors mapped to themes
declare -A THEME_FOLDER_COLORS=(
    ["Nord"]="nordic"
    ["Gruvbox-Dark"]="brown"
    ["Gruvbox"]="brown"
    ["Catppuccin-Mocha"]="violet"
    ["Catppuccin-Macchiato"]="violet"
    ["Catppuccin-Frappé"]="violet"
    ["Catppuccin-Latte"]="violet"
    ["Dracula"]="violet"
    ["Tokyo-Night"]="blue"
    ["Tokyo-Night-Storm"]="blue"
    ["Rosé-Pine"]="pink"
    ["Rosé-Pine-Moon"]="pink"
    ["Rosé-Pine-Dawn"]="pink"
    ["Everforest-Dark-Medium"]="green"
    ["Solarized-Dark"]="cyan"
    ["One-Dark"]="blue"
    ["Kanagawa-Wave"]="indigo"
    ["Ayu-Dark"]="orange"
    ["Ayu-Mirage"]="orange"
)

# ═══════════════════════════════════════════════════════════════════
# 📝 LOGGING
# ═══════════════════════════════════════════════════════════════════

ensure_dirs() {
    mkdir -p "$CONFIG_DIR" "$THEME_DIR" "$(dirname "$LOG_FILE")"
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

notify() {
    notify-send -t 2000 -i preferences-desktop-theme "Theme Switcher" "$*" 2>/dev/null || true
}

# ═══════════════════════════════════════════════════════════════════
# 🖼️ SWWW WALLPAPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════

ensure_swww() {
    if ! pgrep -x swww-daemon &>/dev/null; then
        log "Starting swww daemon..."
        swww-daemon &
        sleep 1
    fi
}

set_wallpaper() {
    local wallpaper="$1"
    local full_path="$WALLPAPER_DIR/$wallpaper"
    
    if [[ ! -f "$full_path" ]]; then
        log "Wallpaper not found: $full_path"
        return 1
    fi
    
    ensure_swww
    
    log "Setting wallpaper: $wallpaper with $TRANSITION_TYPE transition"
    swww img "$full_path" \
        --transition-type "$TRANSITION_TYPE" \
        --transition-duration "$TRANSITION_DURATION" \
        --transition-pos "$TRANSITION_POS" \
        --transition-fps "$TRANSITION_FPS"
    
    # Sync hyprlock background to match
    sync_hyprlock_wallpaper "$full_path"
}

# ═══════════════════════════════════════════════════════════════════
# 🔒 HYPRLOCK SYNC FUNCTION
# ═══════════════════════════════════════════════════════════════════

sync_hyprlock_wallpaper() {
    local wallpaper_path="$1"
    local hyprlock_conf="$HOME/.config/hypr/hyprlock.conf"
    
    if [[ ! -f "$hyprlock_conf" ]]; then
        log "Hyprlock config not found at $hyprlock_conf"
        return 1
    fi
    
    # Update the background path in hyprlock.conf
    sed -i "/^background {/,/^}/ s|^\([[:space:]]*path = \).*|\1${wallpaper_path}|" "$hyprlock_conf"
    
    log "Synced hyprlock wallpaper: $(basename "$wallpaper_path")"
}

# ═══════════════════════════════════════════════════════════════════
# 🎨 WALLUST THEME FUNCTIONS
# ═══════════════════════════════════════════════════════════════════

apply_theme() {
    local theme="$1"
    
    log "Applying wallust theme: $theme"
    
    # Apply theme with wallust
    if ! wallust theme "$theme" 2>/dev/null; then
        log "ERROR: Failed to apply theme $theme"
        notify "Failed to apply theme: $theme"
        return 1
    fi
    
    # Save current theme
    echo "$theme" > "$CURRENT_THEME_FILE"
    
    log "Theme applied: $theme"
}

apply_from_wallpaper() {
    local wallpaper="$1"
    local full_path="$WALLPAPER_DIR/$wallpaper"
    
    if [[ ! -f "$full_path" ]]; then
        log "Wallpaper not found for color extraction: $full_path"
        return 1
    fi
    
    log "Extracting colors from: $wallpaper"
    wallust run "$full_path"
    
    echo "wallpaper:$wallpaper" > "$CURRENT_THEME_FILE"
}

# ═══════════════════════════════════════════════════════════════════
# 🔄 RELOAD APPLICATIONS
# ═══════════════════════════════════════════════════════════════════

set_folder_color() {
    local theme="$1"
    local color="${THEME_FOLDER_COLORS[$theme]:-blue}"
    
    if command -v papirus-folders &>/dev/null; then
        # Change folder color (uses user icons in ~/.local/share/icons)
        papirus-folders -C "$color" --theme Papirus-Dark </dev/null &>/dev/null &
        log "Set Papirus folder color: $color"
    fi
    
    # Check for visible Thunar window FIRST (before killing anything)
    local has_window=false
    if hyprctl clients | grep -qi "class: thunar"; then
        has_window=true
    fi
    
    # Kill thunar if running (daemon or window) so it picks up new GTK colors on next launch
    if pgrep -x thunar &>/dev/null; then
        pkill -9 thunar &>/dev/null || true
        sleep 0.3
        
        # Only reopen if there was an actual visible window
        if [[ "$has_window" == "true" ]]; then
            hyprctl dispatch exec thunar </dev/null &>/dev/null &
            log "Restarted Thunar window"
        else
            # Don't restart daemon - it will start fresh with correct colors next time user opens Thunar
            log "Killed Thunar daemon (will reload with new colors on next use)"
        fi
    fi
}

reload_apps() {
    log "Reloading applications..."
    
    
    # Merge cava config (base + colors)
    if [[ -f "$HOME/.config/cava/config-base" ]] && [[ -f "$HOME/.config/cava/wallust-colors" ]]; then
        cat "$HOME/.config/cava/config-base" "$HOME/.config/cava/wallust-colors" > "$HOME/.config/cava/config"
        log "Merged cava config"
    fi
    
    # Reload kitty (if running with remote control)
    if command -v kitty &>/dev/null; then
        pkill -USR1 kitty &>/dev/null || true
        log "Reloaded kitty"
    fi
    
    # Reload waybar - full restart to pick up new colors
    pkill -9 waybar &>/dev/null || true
    sleep 0.2
    # Launch waybar in background, don't wait
    hyprctl dispatch exec waybar </dev/null &>/dev/null &
    log "Restarted waybar"
    
    # Update Hyprland border colors from wallust-generated file
    if [[ -f "$HOME/.config/hypr/wallust-colors.conf" ]]; then
        # Extract colors from the generated file (preserve spaces for gradients)
        local active_border inactive_border
        active_border=$(grep 'col.active_border' "$HOME/.config/hypr/wallust-colors.conf" | head -1 | sed 's/.*col.active_border = //')
        inactive_border=$(grep 'col.inactive_border' "$HOME/.config/hypr/wallust-colors.conf" | head -1 | sed 's/.*col.inactive_border = //')
        
        if [[ -n "$active_border" ]]; then
            hyprctl keyword general:col.active_border "$active_border" &>/dev/null || true
            log "Set active border: $active_border"
        fi
        if [[ -n "$inactive_border" ]]; then
            hyprctl keyword general:col.inactive_border "$inactive_border" &>/dev/null || true
            log "Set inactive border: $inactive_border"
        fi
    fi
    
    # Reload tmux colors
    if command -v tmux &>/dev/null && tmux list-sessions &>/dev/null; then
        tmux source-file ~/.config/tmux/wallust-colors.conf &>/dev/null || true
        log "Reloaded tmux colors"
    fi

    # Restart cava if running
    if pgrep -x cava &>/dev/null; then
        pkill -USR1 cava &>/dev/null || true
        log "Reloaded cava"
    fi
    
    log "Application reload complete"
}

# ═══════════════════════════════════════════════════════════════════
# 🎯 FULL THEME SWITCH
# ═══════════════════════════════════════════════════════════════════

switch_theme() {
    local theme="$1"
    local wallpaper="${THEME_WALLPAPERS[$theme]:-}"
    
    log "=== Switching to theme: $theme ==="
    
    # Set wallpaper with animation (if mapped) - background
    if [[ -n "$wallpaper" ]]; then
        set_wallpaper "$wallpaper" &
    fi
    
    # Apply wallust theme
    apply_theme "$theme"
    
    # Set folder icon color (fast, with timeouts)
    set_folder_color "$theme"
    
    # Reload all apps
    reload_apps
    
    notify "Theme: $theme"
    log "=== Theme switch complete: $theme ==="
}

switch_from_wallpaper() {
    local wallpaper="$1"
    
    log "=== Switching theme from wallpaper: $wallpaper ==="
    
    # Set wallpaper with animation
    set_wallpaper "$wallpaper" &
    
    # Extract and apply colors
    apply_from_wallpaper "$wallpaper"
    
    # Wait for wallpaper transition to start
    sleep 0.5
    
    # Reload all apps
    reload_apps
    
    notify "Theme from: $wallpaper"
    log "=== Wallpaper theme switch complete ==="
}

# ═══════════════════════════════════════════════════════════════════
# 📋 MENU FUNCTIONS
# ═══════════════════════════════════════════════════════════════════

get_theme_list() {
    # Popular themes first
    echo "󰔎 Nord"
    echo "󰔎 Gruvbox-Dark"
    echo "󰔎 Catppuccin-Mocha"
    echo "󰔎 Dracula"
    echo "󰔎 Tokyo-Night"
    echo "󰔎 Rosé-Pine"
    echo "󰔎 Everforest-Dark-Medium"
    echo "󰔎 Solarized-Dark"
    echo "󰔎 One-Dark"
    echo "󰔎 Kanagawa-Wave"
    echo "───────────────"
    echo "󰔎 Catppuccin-Latte"
    echo "󰔎 Catppuccin-Frappé"
    echo "󰔎 Catppuccin-Macchiato"
    echo "󰔎 Gruvbox"
    echo "󰔎 Gruvbox-Material-Dark"
    echo "󰔎 Tokyo-Night-Storm"
    echo "󰔎 Rosé-Pine-Moon"
    echo "󰔎 Rosé-Pine-Dawn"
    echo "󰔎 Nord-Light"
    echo "󰔎 Ayu-Dark"
    echo "󰔎 Ayu-Mirage"
    echo "───────────────"
    echo "󰸉 From Current Wallpaper"
    echo "󰸉 Random Wallpaper"
    echo "───────────────"
    echo "󱗃 All Themes..."
}

get_all_themes() {
    wallust theme -l 2>/dev/null | tr ',' '\n' | sed 's/^ *//' | sort | while read -r theme; do
        [[ -n "$theme" ]] && echo "󰔎 $theme"
    done
}

get_wallpaper_list() {
    find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | while read -r file; do
        echo "󰸉 $(basename "$file")"
    done
}

show_menu() {
    local choice
    
    choice=$(get_theme_list | fuzzel --dmenu --prompt "Theme: " --width 40 --lines 20)
    
    [[ -z "$choice" ]] && exit 0
    
    # Parse choice
    local selection="${choice#* }"  # Remove icon prefix
    
    case "$selection" in
        "From Current Wallpaper")
            # Get current wallpaper from swww
            local current_wp
            current_wp=$(swww query 2>/dev/null | grep -oP 'image: \K.*' | head -1)
            if [[ -n "$current_wp" ]]; then
                switch_from_wallpaper "$(basename "$current_wp")"
            else
                notify "No wallpaper detected"
            fi
            ;;
        "Random Wallpaper")
            local random_wp
            random_wp=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)
            [[ -n "$random_wp" ]] && switch_from_wallpaper "$(basename "$random_wp")"
            ;;
        "All Themes...")
            local all_choice
            all_choice=$(get_all_themes | fuzzel --dmenu --prompt "All Themes: " --width 45 --lines 25)
            [[ -n "$all_choice" ]] && switch_theme "${all_choice#* }"
            ;;
        "───────────────")
            # Separator, do nothing
            show_menu
            ;;
        *)
            switch_theme "$selection"
            ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════
# 🚀 MAIN
# ═══════════════════════════════════════════════════════════════════

main() {
    ensure_dirs
    
    case "${1:-menu}" in
        "menu"|"")
            show_menu
            ;;
        "theme")
            [[ -z "${2:-}" ]] && { echo "Usage: $0 theme <theme-name>"; exit 1; }
            switch_theme "$2"
            ;;
        "wallpaper")
            [[ -z "${2:-}" ]] && { echo "Usage: $0 wallpaper <wallpaper-file>"; exit 1; }
            switch_from_wallpaper "$2"
            ;;
        "reload")
            reload_apps
            ;;
        "current")
            [[ -f "$CURRENT_THEME_FILE" ]] && cat "$CURRENT_THEME_FILE" || echo "No theme set"
            ;;
        "list")
            get_theme_list
            ;;
        "help"|"--help"|"-h")
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  menu         Show theme picker menu (default)"
            echo "  theme NAME   Apply theme by name"
            echo "  wallpaper F  Extract theme from wallpaper"
            echo "  reload       Reload apps with current colors"
            echo "  current      Show current theme"
            echo "  list         List available themes"
            echo "  help         Show this help"
            ;;
        *)
            # Assume it's a theme name
            switch_theme "$1"
            ;;
    esac
}

main "$@"
