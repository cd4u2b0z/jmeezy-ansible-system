#!/bin/bash

# Fast & Safe Update Manager for Waybar
# Optimized for speed with safety measures and intelligent caching

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Performance and Safety Configuration
CACHE_DIR="/tmp/update-manager"
PACMAN_CACHE="$CACHE_DIR/pacman.cache"
AUR_CACHE="$CACHE_DIR/aur.cache"
CACHE_DURATION=300  # 5 minutes
TIMEOUT_SHORT=15    # Quick operations
TIMEOUT_LONG=45     # Longer operations
MAX_RETRIES=2

# Create cache directory
mkdir -p "$CACHE_DIR"

# Colors (Nord theme)
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# Fast symbols (pre-calculated to avoid repeated Unicode processing)
CHECK="├ 󰄬"
CROSS="├ 󰅙"
INFO="├ 󰋽"
SEARCH="󰏖"
PACKAGE="├ 󰷐"
BUILD="├ 󰜎"
SHIELD="󰚥"
EXIT="└ 󰗼"
BROWSER="├ 󱟿"

# Performance: Pre-compile critical functions
declare -A PKG_PRIORITIES=(
    ["systemd"]="🔴 CRITICAL"
    ["glibc"]="🔴 CRITICAL"
    ["openssl"]="🔴 CRITICAL"
    ["pacman"]="🔴 CRITICAL"
    ["archlinux-keyring"]="🔴 CRITICAL"
    ["firefox"]="🟠 HIGH"
    ["brave"]="🟠 HIGH"
    ["nvidia"]="🟠 HIGH"
    ["mesa"]="🟠 HIGH"
    ["vulkan"]="🟠 HIGH"
    ["steam"]="🟡 MEDIUM"
    ["lutris"]="🟡 MEDIUM"
    ["wine"]="🟡 MEDIUM"
    ["dxvk"]="🟡 MEDIUM"
    ["gamemode"]="🟡 MEDIUM"
    ["ncspot"]="⚪ LOW"
    ["font"]="⚪ LOW"
)

# Fast package description lookup
get_package_priority() {
    local pkg="$1"
    local base_pkg="${pkg%%-*}"  # Remove version suffixes
    
    # Direct lookup first (fastest)
    [[ -n "${PKG_PRIORITIES[$pkg]:-}" ]] && echo "${PKG_PRIORITIES[$pkg]}" && return
    [[ -n "${PKG_PRIORITIES[$base_pkg]:-}" ]] && echo "${PKG_PRIORITIES[$base_pkg]}" && return
    
    # Pattern matching (fallback)
    case "$pkg" in
        *systemd*|*glibc*|*openssl*|*gnupg*|*pacman*) echo "🔴 CRITICAL" ;;
        *firefox*|*brave*|*nvidia*|*mesa*|*vulkan*) echo "🟠 HIGH" ;;
        *steam*|*wine*|*dxvk*|*gamemode*|*heroic*|*bottles*) echo "🟡 GAMING" ;;
        *font*|*ttf-*|*ncspot*) echo "⚪ LOW" ;;
        *) echo "── STANDARD" ;;
    esac
}

# Cache validation (fast file stat)
is_cache_valid() {
    local cache_file="$1"
    [[ -f "$cache_file" ]] && 
    [[ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $CACHE_DURATION ]]
}

# Safe command execution with timeout and retries
safe_execute() {
    local cmd="$1"
    local timeout_val="$2"
    local retries="${3:-$MAX_RETRIES}"
    
    for ((i=1; i<=retries; i++)); do
        if timeout "$timeout_val" bash -c "$cmd" 2>/dev/null; then
            return 0
        fi
        [[ $i -lt $retries ]] && sleep 0.5
    done
    return 1
}

# Fast parallel update checking
check_updates_parallel() {
    local pacman_updates=""
    local aur_updates=""
    
    # Check pacman updates (with cache)
    if is_cache_valid "$PACMAN_CACHE"; then
        pacman_updates=$(cat "$PACMAN_CACHE" 2>/dev/null || echo "")
    else
        if command -v checkupdates >/dev/null 2>&1; then
            pacman_updates=$(safe_execute "checkupdates" "$TIMEOUT_SHORT")
            echo "$pacman_updates" > "$PACMAN_CACHE" 2>/dev/null || true
        fi
    fi
    
    # Check AUR updates (with cache) - run in background for speed
    if is_cache_valid "$AUR_CACHE"; then
        aur_updates=$(cat "$AUR_CACHE" 2>/dev/null || echo "")
    else
        if command -v yay >/dev/null 2>&1; then
            # Background AUR check for speed
            (
                aur_result=$(safe_execute "yay -Qum" "$TIMEOUT_LONG")
                echo "$aur_result" > "$AUR_CACHE" 2>/dev/null || true
            ) &
            local aur_pid=$!
            
            # Don't wait for AUR if it takes too long on first run
            sleep 2
            if kill -0 $aur_pid 2>/dev/null; then
                aur_updates="[⏳ Checking AUR in background...]"
            else
                wait $aur_pid
                aur_updates=$(cat "$AUR_CACHE" 2>/dev/null || echo "")
            fi
        fi
    fi
    
    # Display results immediately (no waiting)
    display_updates_fast "$pacman_updates" "$aur_updates"
}

# Fast display with minimal processing
display_updates_fast() {
    local pacman_updates="$1"
    local aur_updates="$2"
    
    # Clear screen for instant feel
    clear
    
    # Fast header (no processing)
    printf "%s System Updates\n━━━━━━━━━━━━━━━━\n\n" "$SEARCH"
    
    # Pacman section
    echo "Packages"
    if [[ -n "$pacman_updates" && "$pacman_updates" != "[⏳"* ]]; then
        local count=0
        while IFS= read -r line && [[ $count -lt 10 ]]; do  # Limit display for speed
            [[ -z "$line" ]] && continue
            local pkg=$(echo "$line" | cut -d' ' -f1)
            local priority=$(get_package_priority "$pkg")
            printf "├ 󰷐 %s%s%s %s\n" "$CYAN" "$pkg" "$NC" "$priority"
            ((count++))
        done <<< "$pacman_updates"
        
        local total=$(echo "$pacman_updates" | wc -l)
        [[ $count -eq 10 && $total -gt 10 ]] && printf "└ 󰇘 ...and %d more\n" $((total - 10))
    else
        printf "%s No pacman updates available\n" "$CHECK"
    fi
    
    echo
    
    # AUR section  
    echo "AUR"
    if [[ -n "$aur_updates" ]]; then
        if [[ "$aur_updates" == "[⏳"* ]]; then
            printf "%s %s\n" "$INFO" "$aur_updates"
        else
            local count=0
            while IFS= read -r line && [[ $count -lt 5 ]]; do  # Limit AUR display
                [[ -z "$line" ]] && continue
                local pkg=$(echo "$line" | cut -d' ' -f1)
                printf "├ 󰜎 %s%s%s\n" "$PURPLE" "$pkg" "$NC"
                ((count++))
            done <<< "$aur_updates"
            
            local total=$(echo "$aur_updates" | wc -l)
            [[ $count -eq 5 && $total -gt 5 ]] && printf "└ 󰇘 ...and %d more\n" $((total - 5))
        fi
    else
        printf "%s No AUR updates available\n" "$CHECK"
    fi
}

# Fast menu with minimal options
show_menu_fast() {
    printf "\n%s Update Options\n━━━━━━━━━━━━━━━━\n" "$SHIELD"
    printf "├ 1. Install pacman updates only\n"
    printf "├ 2. Install AUR updates only\n" 
    printf "├ 3. Install all updates\n"
    printf "├ 4. Refresh cache & recheck\n"
    printf "├ 5. Show detailed view\n"
    printf "└ 6. Exit\n\n"
}

# Cache management
flush_cache() {
    rm -f "$PACMAN_CACHE" "$AUR_CACHE" 2>/dev/null || true
    printf "%s Cache cleared\n" "$INFO"
}

# Safety check before updates
safety_check() {
    # Check for critical operations
    if pgrep -x "pacman\|yay" >/dev/null; then
        printf "%s Another package manager is running. Please wait.\n" "$CROSS"
        return 1
    fi
    
    # Check disk space (need at least 1GB free)
    local free_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $free_space -lt 1048576 ]]; then  # 1GB in KB
        printf "%s Warning: Low disk space (less than 1GB free)\n" "$CROSS"
        read -p "Continue anyway? [y/N]: " -n 1 -r
        [[ ! $REPLY =~ ^[Yy]$ ]] && return 1
    fi
    
    return 0
}

# Fallback update method
fallback_update() {
    local method="$1"
    printf "%s Using fallback update method...\n" "$INFO"
    
    case "$method" in
        1) sudo pacman -Syu || true ;;
        2) yay -Syu --aur || true ;;
        3) yay -Syu || true ;;
    esac
}

# Main execution
main() {
    # Fast startup - show interface immediately
    trap 'printf "\n%s Operation cancelled\n" "$CROSS"; exit 130' INT
    
    # Background cache cleanup
    find "$CACHE_DIR" -name "*.cache" -mmin +60 -delete 2>/dev/null &
    
    # Main loop
    while true; do
        check_updates_parallel
        show_menu_fast
        
        read -p "Choose an option [1-6]: " -n 1 -r choice
        echo
        
        case "$choice" in
            1|2|3)
                if safety_check; then
                    case "$choice" in
                        1) safe_execute "sudo pacman -Syu" 120 || fallback_update 1 ;;
                        2) safe_execute "yay -Syu --aur" 300 || fallback_update 2 ;;
                        3) safe_execute "yay -Syu" 300 || fallback_update 3 ;;
                    esac
                    printf "\n%s Update completed. Press any key to continue..." "$CHECK"
                    read -n 1 -s
                fi
                ;;
            4)
                flush_cache
                sleep 1
                ;;
            5)
                # Launch detailed version
                exec ~/.config/waybar/scripts/simple-update-manager-detailed.sh 2>/dev/null || 
                printf "%s Detailed view not available\n" "$INFO"
                ;;
            6)
                printf "%s Exiting...\n" "$EXIT"
                exit 0
                ;;
            *)
                printf "%s Invalid option. Try again.\n" "$CROSS"
                sleep 1
                ;;
        esac
    done
}

# Performance optimization: reduce subshells
export TIMEFORMAT=''  # Disable bash timing
main "$@"