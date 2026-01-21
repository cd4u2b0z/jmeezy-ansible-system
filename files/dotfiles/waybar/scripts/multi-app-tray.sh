#!/usr/bin/env bash
set -u
export LANG=C LC_ALL=C

# Dependency check
if ! command -v hyprctl >/dev/null 2>&1; then
    printf '{"text":"󰀻","tooltip":"hyprctl not found","class":"error"}\n'
    exit 0
fi
if ! command -v jq >/dev/null 2>&1; then
    printf '{"text":"󰀻","tooltip":"jq not found","class":"error"}\n'
    exit 0
fi

# Only check for actual WINDOWS, not background processes
window_exists() { hyprctl clients -j 2>/dev/null | jq -r '.[].class // empty' | grep -qi "^$1$"; }

# App checks (case-insensitive)
check_brave() { window_exists "brave-browser" || window_exists "Brave-browser"; }
check_librewolf() { window_exists "librewolf" || window_exists "LibreWolf"; }
check_firefox() { window_exists "firefox" || window_exists "Firefox"; }
check_vscode() { window_exists "code" || window_exists "Code"; }
check_kitty() { window_exists "kitty" || window_exists "Kitty"; }
check_thunar() { window_exists "thunar" || window_exists "Thunar"; }
check_spotify() { window_exists "Spotify" || window_exists "spotify"; }
check_ncspot() { pgrep -x ncspot >/dev/null 2>&1; }
check_discord() { window_exists "discord" || window_exists "Discord"; }
check_steam() { window_exists "steam" || window_exists "Steam"; }
check_obs() { window_exists "obs" || window_exists "com.obsproject.Studio"; }
check_gimp() { window_exists "gimp" || window_exists "Gimp"; }
check_blender() { window_exists "blender" || window_exists "Blender"; }

apps=() classes=() names=()

# Build app list with nerd font icons
check_brave && { apps+=("󰊽"); classes+=("brave"); names+=("Brave"); }
check_librewolf && { apps+=("󰈹"); classes+=("librewolf"); names+=("LibreWolf"); }
check_firefox && { apps+=("󰈹"); classes+=("firefox"); names+=("Firefox"); }
check_vscode && { apps+=("󰨞"); classes+=("vscode"); names+=("VS Code"); }
check_kitty && { apps+=("󰄛"); classes+=("kitty"); names+=("Kitty"); }
check_thunar && { apps+=("󰉋"); classes+=("thunar"); names+=("Thunar"); }
check_spotify && { apps+=(""); classes+=("spotify"); names+=("Spotify"); }
check_ncspot && { apps+=(""); classes+=("ncspot"); names+=("ncspot"); }
check_discord && { apps+=("󰙯"); classes+=("discord"); names+=("Discord"); }
check_steam && { apps+=("󰓓"); classes+=("steam"); names+=("Steam"); }
check_obs && { apps+=("󰑋"); classes+=("obs"); names+=("OBS"); }
check_gimp && { apps+=("󰏘"); classes+=("gimp"); names+=("GIMP"); }
check_blender && { apps+=("󰂫"); classes+=("blender"); names+=("Blender"); }

if [ ${#apps[@]} -eq 0 ]; then
    printf '{"text":"󰀻","tooltip":"No apps running","class":"empty"}\n'
else
    text=$(IFS='  '; echo "${apps[*]}")
    tooltip="${#apps[@]} running: $(IFS=', '; echo "${names[*]}")"
    class="${classes[*]}"
    printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$class"
fi
