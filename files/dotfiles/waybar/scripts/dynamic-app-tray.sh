#!/bin/bash

# Dynamic App Tray - Shows different apps when running
# Improved detection with better process checking

# Function to check if process is running (more precise)
is_running() {
    local process="$1"
    # Use pgrep with exact matching and check if processes are actually running
    if pgrep -x "$process" > /dev/null 2>&1 || pgrep -f "$process" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Function to check if flatpak app is running (more reliable)
is_flatpak_running() {
    local app_id="$1"
    # Check flatpak ps output more reliably
    if flatpak ps --columns=application 2>/dev/null | grep -q "^$app_id$"; then
        return 0
    fi
    return 1
}

# Function to check if window exists (additional verification)
window_exists() {
    local class_name="$1"
    # Use hyprctl to check if window actually exists (if available)
    if command -v hyprctl > /dev/null 2>&1; then
        hyprctl clients -j 2>/dev/null | grep -qi "$class_name" && return 0
    fi
    return 1
}

# Function to get app info
get_app_info() {
    local app_name="$1"
    local icon="$2"
    local tooltip="$3"
    local class="$4"
    
    echo "{\"text\":\"$icon\",\"tooltip\":\"$tooltip\",\"class\":\"$class\"}"
}

# Enhanced detection with multiple verification methods
check_spotify() {
    # Multiple ways to detect Spotify
    if is_flatpak_running "com.spotify.Client" ||
       is_running "spotify" ||
       window_exists "Spotify" ||
       (playerctl -l 2>/dev/null | grep -q "spotify" && playerctl -p spotify status 2>/dev/null | grep -q "Playing\|Paused"); then
        return 0
    fi
    return 1
}

check_steam() {
    if is_flatpak_running "com.valvesoftware.Steam" ||
       is_running "steam" ||
       window_exists "steam" ||
       window_exists "Steam"; then
        return 0
    fi
    return 1
}

check_discord() {
    if is_flatpak_running "com.discordapp.Discord" ||
       is_running "discord" ||
       is_running "Discord" ||
       window_exists "discord" ||
       window_exists "Discord"; then
        return 0
    fi
    return 1
}

check_obs() {
    if is_running "obs" ||
       is_running "obs-studio" ||
       window_exists "obs" ||
       window_exists "com.obsproject.Studio"; then
        return 0
    fi
    return 1
}

# Main detection logic with priority order
if check_spotify; then
    get_app_info "Spotify" "󰓇" "Spotify - Click to play/pause" "spotify"
elif check_obs; then
    get_app_info "OBS Studio" "󰑋" "OBS Studio - Recording/Streaming" "obs"  
elif check_steam; then
    get_app_info "Steam" "󰓓" "Steam - Click to open" "steam"
elif check_discord; then
    get_app_info "Discord" "󰙯" "Discord - Voice & Chat" "discord"
elif is_running "code" || is_running "code-oss" || window_exists "code"; then
    get_app_info "VS Code" "󰨞" "Visual Studio Code" "vscode"
elif is_flatpak_running "org.mozilla.firefox" || is_running "firefox" || window_exists "firefox"; then
    get_app_info "Firefox" "󰈹" "Firefox Browser" "firefox"
elif is_flatpak_running "com.google.Chrome" || is_running "google-chrome" || is_running "chromium" || window_exists "chrome"; then
    get_app_info "Chrome" "󰊯" "Chrome Browser" "chrome"
elif is_flatpak_running "org.gimp.GIMP" || is_running "gimp" || window_exists "gimp"; then
    get_app_info "GIMP" "󰉦" "GIMP Image Editor" "gimp"
elif is_flatpak_running "org.blender.Blender" || is_running "blender" || window_exists "blender"; then
    get_app_info "Blender" "󰂫" "Blender 3D" "blender"
elif is_flatpak_running "org.telegram.desktop" || is_running "telegram" || window_exists "telegram"; then
    get_app_info "Telegram" "󰔗" "Telegram Messaging" "telegram"
elif is_flatpak_running "us.zoom.Zoom" || is_running "zoom" || window_exists "zoom"; then
    get_app_info "Zoom" "󰍫" "Zoom Meeting" "zoom"
elif is_flatpak_running "org.videolan.VLC" || is_running "vlc" || window_exists "vlc"; then
    get_app_info "VLC" "󰕼" "VLC Media Player" "vlc"
else
    # Default tray icon when no special apps are running
    get_app_info "Apps" "󰀻" "Application Tray" "default"
fi