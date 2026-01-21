#!/usr/bin/env bash
set -u
export LANG=C LC_ALL=C

# Window-only detection (consistent with multi-app-tray.sh)
window_exists() { 
    command -v hyprctl >/dev/null 2>&1 || return 1
    command -v jq >/dev/null 2>&1 || return 1
    hyprctl clients -j 2>/dev/null | jq -r '.[].class // empty' | grep -qi "^$1$"
}

focus() { hyprctl dispatch focuswindow "class:$1" 2>/dev/null; }

# All checks use window_exists only (no pgrep)
check_brave() { window_exists "brave-browser" || window_exists "Brave-browser"; }
check_librewolf() { window_exists "librewolf" || window_exists "LibreWolf"; }
check_firefox() { window_exists "firefox" || window_exists "Firefox"; }
check_vscode() { window_exists "code" || window_exists "Code"; }
check_kitty() { window_exists "kitty"; }
check_thunar() { window_exists "thunar" || window_exists "Thunar"; }
check_spotify() { window_exists "Spotify" || window_exists "spotify"; }
check_discord() { window_exists "discord" || window_exists "Discord"; }
check_steam() { window_exists "steam" || window_exists "Steam"; }
check_obs() { window_exists "obs" || window_exists "com.obsproject.Studio"; }

# Focus first running app (same order as tray)
if check_brave; then focus "brave-browser" || focus "Brave-browser"
elif check_librewolf; then focus "librewolf" || focus "LibreWolf"
elif check_firefox; then focus "firefox" || focus "Firefox"
elif check_vscode; then focus "code" || focus "Code"
elif check_kitty; then focus "kitty"
elif check_thunar; then focus "thunar" || focus "Thunar"
elif check_spotify; then focus "Spotify" || focus "spotify"
elif check_discord; then focus "discord" || focus "Discord"
elif check_steam; then focus "steam" || focus "Steam"
elif check_obs; then focus "obs" || focus "com.obsproject.Studio"
else fuzzel
fi
