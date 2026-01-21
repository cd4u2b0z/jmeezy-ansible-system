#!/bin/bash

# Ultra-Fast Update Manager - Optimized for Speed & Safety
# No typewriter effect - instant display

set -euo pipefail

# Speed Configuration
CACHE_DIR="/tmp/update-manager"
CACHE_DURATION=300
TIMEOUT=20

# Create cache directory
mkdir -p "$CACHE_DIR" 2>/dev/null || true

# Colors (Nord)
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# Pre-calculated symbols for speed
readonly CHECK="├ 󰄬"
readonly INFO="├ 󰋽" 
readonly SEARCH="󰏖"
readonly PACKAGE="├ 󰷐"
readonly BUILD="├ 󰜎"
readonly SHIELD="󰚥"
readonly EXIT="└ 󰗼"

# Fast cache check
is_cache_valid() {
    [[ -f "$1" ]] && [[ $(($(date +%s) - $(stat -c %Y "$1" 2>/dev/null || echo 0))) -lt $CACHE_DURATION ]]
}

# Function to get package description with system-specific reasoning (CACHED)
get_package_description() {
    local pkg="$1"
    local cache_file="$CACHE_DIR/desc_$pkg"
    
    # Return cached description if valid
    if is_cache_valid "$cache_file"; then
        cat "$cache_file" 2>/dev/null
        return
    fi
    
    local desc=""
    local system_reason=""
    
    # Try pacman first (fast)
    desc=$(pacman -Si "$pkg" 2>/dev/null | grep "^Description" | cut -d':' -f2- | sed 's/^ *//' | head -1)
    
    # Add system-specific reasoning for your setup
    case "$pkg" in
        linux*) system_reason=" ${YELLOW}[CRITICAL for system kernel]${NC}" ;;
        nvidia*|lib32-nvidia*) system_reason=" ${RED}[CRITICAL for RTX 3090]${NC}" ;;
        intel-ucode*) system_reason=" ${YELLOW}[HIGH for Intel i9-12900K]${NC}" ;;
        hyprland*) system_reason=" ${RED}[CRITICAL for window manager]${NC}" ;;
        waybar*|mako*|wofi*) system_reason=" ${YELLOW}[HIGH for Nord desktop]${NC}" ;;
        pipewire*|wireplumber*) system_reason=" ${YELLOW}[HIGH for audio system]${NC}" ;;
        firefox*|brave*|chromium*) system_reason=" ${YELLOW}[HIGH for web security]${NC}" ;;
        steam*|lutris*|heroic*) system_reason=" ${GREEN}[MEDIUM for gaming]${NC}" ;;
        wine*|dxvk*|gamemode*) system_reason=" ${GREEN}[MEDIUM for Windows games]${NC}" ;;
        mesa*|vulkan*) system_reason=" ${YELLOW}[HIGH for graphics]${NC}" ;;
        systemd*|glibc*) system_reason=" ${RED}[CRITICAL system component]${NC}" ;;
        *font*|noto*) system_reason=" ${CYAN}[LOW for fonts]${NC}" ;;
        *) system_reason="" ;;
    esac
    
    # Cache and return result
    local result="$desc$system_reason"
    echo "$result" > "$cache_file" 2>/dev/null || true
    echo "$result"
}

# Browser detection and integration  
detect_browser() {
    if command -v brave >/dev/null 2>&1; then
        echo "brave"
    elif command -v firefox >/dev/null 2>&1; then
        echo "firefox"
    elif command -v chromium >/dev/null 2>&1; then
        echo "chromium"
    else
        echo "xdg-open"
    fi
}

# Show package in browser
show_package_in_browser() {
    local pkg="$1"
    local browser=$(detect_browser)
    local url="https://archlinux.org/packages/?q=$pkg"
    
    # Check if it's AUR package
    if yay -Si "$pkg" 2>/dev/null | grep -q "^Repository.*aur"; then
        url="https://aur.archlinux.org/packages/$pkg"
    fi
    
    $browser "$url" >/dev/null 2>&1 &
}

# Instant display - no delays
show_updates() {
    clear  # Instant clear
    
    # Header (no processing delays)
    printf "%s System Updates\n━━━━━━━━━━━━━━━━\n\n" "$SEARCH"
    
    # Pacman section
    local pacman_cache="$CACHE_DIR/pacman.cache"
    local pacman_updates=""
    
    echo "Packages"
    if is_cache_valid "$pacman_cache"; then
        pacman_updates=$(cat "$pacman_cache" 2>/dev/null)
    else
        if command -v checkupdates >/dev/null 2>&1; then
            pacman_updates=$(timeout $TIMEOUT checkupdates 2>/dev/null || echo "")
            echo "$pacman_updates" > "$pacman_cache" 2>/dev/null || true
        fi
    fi
    
    if [[ -n "$pacman_updates" ]]; then
        local count=0
        while IFS= read -r line && ((count < 8)); do
            [[ -z "$line" ]] && continue
            local pkg=$(echo "$line" | cut -d' ' -f1)
            local priority=$(get_priority "$pkg")
            printf "├ 󰷐 %s%s%s %s\n" "$CYAN" "$pkg" "$NC" "$priority"
            ((count++))
        done <<< "$pacman_updates"
        
        local total=$(echo "$pacman_updates" | wc -l)
        [[ $count -eq 8 && $total -gt 8 ]] && printf "└ 󰇘 ...and %d more\n" $((total - 8))
    else
        printf "%s No pacman updates\n" "$CHECK"
    fi
    
    echo -e "\nAUR"
    
    # Quick AUR check (non-blocking)
    local aur_cache="$CACHE_DIR/aur.cache"
    local aur_updates=""
    
    if is_cache_valid "$aur_cache"; then
        aur_updates=$(cat "$aur_cache" 2>/dev/null)
        if [[ -n "$aur_updates" ]]; then
            local count=0
            while IFS= read -r line && ((count < 5)); do
                [[ -z "$line" ]] && continue
                local pkg=$(echo "$line" | cut -d' ' -f1)
                printf "├ 󰜎 %s%s%s\n" "$PURPLE" "$pkg" "$NC"
                ((count++))
            done <<< "$aur_updates"
        else
            printf "%s No AUR updates\n" "$CHECK"
        fi
    else
        printf "%s Checking AUR...\n" "$INFO"
        # Background AUR check for next time
        (timeout $TIMEOUT yay -Qum 2>/dev/null || echo "") > "$aur_cache" 2>/dev/null &
    fi
}

# Simple menu
show_menu() {
    printf "\n%s Update Options\n━━━━━━━━━━━━━━━━\n" "$SHIELD"
    printf "├ 1. Pacman updates\n├ 2. AUR updates\n├ 3. All updates\n├ 4. Refresh\n└ 5. Exit\n\n"
}

# Safety check
safety_check() {
    if pgrep -x "pacman\|yay" >/dev/null 2>&1; then
        printf "❌ Package manager already running\n"
        return 1
    fi
    return 0
}

# Main loop
while true; do
    show_updates
    show_menu
    
    read -p "Choose [1-5]: " -n 1 -r choice
    echo
    
    case "$choice" in
        1) safety_check && { printf "Installing pacman updates...\n"; sudo pacman -Syu; } ;;
        2) safety_check && { printf "Installing AUR updates...\n"; yay -Syu --aur; } ;;  
        3) safety_check && { printf "Installing all updates...\n"; yay -Syu; } ;;
        4) rm -f "$CACHE_DIR"/*.cache 2>/dev/null; printf "Cache cleared\n"; sleep 1 ;;
        5) printf "%s Goodbye!\n" "$EXIT"; exit 0 ;;
        *) printf "Invalid choice\n"; sleep 1 ;;
    esac
    
    [[ "$choice" =~ [1-3] ]] && { printf "Press any key..."; read -n 1 -s; }
done