#!/bin/bash

# Enhanced Update Manager with Package Descriptions + Performance Cache
# Author: GitHub Copilot
# Description: Smart update manager with package descriptions and browser integration

# Performance Cache Configuration
CACHE_DIR="/tmp/update-manager"
CACHE_DURATION=300
TIMEOUT=20
mkdir -p "$CACHE_DIR" 2>/dev/null || true

# Cache validation function
is_cache_valid() {
    [[ -f "$1" ]] && [[ $(($(date +%s) - $(stat -c %Y "$1" 2>/dev/null || echo 0))) -lt $CACHE_DURATION ]]
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis for better UX
CHECK="├ 󰄬"
CROSS="├ 󰅙"
INFO="├ 󰋽"
SEARCH="󰏖"
PACKAGE="├ 󰏗"
BUILD="├ 󰊤"
SHIELD="󰚥"
EXIT="└ 󰗼"
BROWSER="├ 󰖟"

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
    
    # Try to get description from pacman first
    desc=$(pacman -Si "$pkg" 2>/dev/null | grep "^Description" | cut -d':' -f2- | sed 's/^ *//')
    
    # If not found, try yay for AUR packages
    if [[ -z "$desc" ]]; then
        desc=$(yay -Si "$pkg" 2>/dev/null | grep "^Description" | cut -d':' -f2- | sed 's/^ *//')
    fi
    
    # Add system-specific reasoning (Linux Mint style)
    case "$pkg" in
        linux*) system_reason=" ${YELLOW}[CRITICAL for your system kernel]${NC}" ;;
        nvidia*|lib32-nvidia*) system_reason=" ${RED}[CRITICAL for your RTX 3090]${NC}" ;;
        intel-ucode*) system_reason=" ${YELLOW}[HIGH for your Intel i7-9700K]${NC}" ;;
        hyprland*) system_reason=" ${RED}[CRITICAL for your window manager]${NC}" ;;
        waybar*|mako*|wofi*) system_reason=" ${YELLOW}[HIGH for your Nord desktop]${NC}" ;;
        gtk*|gtk4*|gtk3*|gtk-*) system_reason=" ${YELLOW}[HIGH for desktop GUI]${NC}" ;;
        cmake*|make*) system_reason=" ${GREEN}[MEDIUM for development tools]${NC}" ;;
        pipewire*|wireplumber*) system_reason=" ${YELLOW}[HIGH for your audio system]${NC}" ;;
        kitty*) system_reason=" ${GREEN}[MEDIUM for your terminal]${NC}" ;;
        firefox*|brave*|chromium*) system_reason=" ${YELLOW}[HIGH for web security]${NC}" ;;
        steam*|proton*|lutris*|heroic*|bottles*|protontricks*|winetricks*) system_reason=" ${GREEN}[MEDIUM for gaming compatibility]${NC}" ;;
        wine*|dxvk*|vkd3d*|lib32-*) system_reason=" ${GREEN}[MEDIUM for Windows game compatibility]${NC}" ;;
        gamemode*|mangohud*) system_reason=" ${GREEN}[MEDIUM for gaming performance]${NC}" ;;
        nvidia*|lib32-nvidia*) system_reason=" ${YELLOW}[HIGH for RTX 3090 drivers]${NC}" ;;
        ncspot*) system_reason=" ${BLUE}[LOW for your Spotify client]${NC}" ;;
        gcc*|rust*|python*|python-*) system_reason=" ${GREEN}[MEDIUM for development]${NC}" ;;
        obs-studio*) system_reason=" ${GREEN}[MEDIUM for streaming]${NC}" ;;
        systemd*|glibc*) system_reason=" ${RED}[CRITICAL system libraries]${NC}" ;;
        openssl*|gnupg*|ca-certificates*) system_reason=" ${RED}[CRITICAL security]${NC}" ;;
        pacman*|archlinux-keyring*) system_reason=" ${RED}[CRITICAL for package management]${NC}" ;;
        mesa*|lib32-mesa*) system_reason=" ${YELLOW}[HIGH for graphics acceleration]${NC}" ;;
        vulkan*|lib32-vulkan*) system_reason=" ${YELLOW}[HIGH for Vulkan graphics on RTX 3090]${NC}" ;;
        *font*|ttf-*) system_reason=" ${BLUE}[LOW for font rendering]${NC}" ;;
    esac
    
    # Return description with system reasoning
    if [[ -n "$desc" ]]; then
        echo "$desc$system_reason"
    else
        echo "No description available$system_reason"
    fi
}

# Function to detect preferred browser
detect_browser() {
    if command -v brave >/dev/null 2>&1; then
        echo "brave"
    elif command -v librewolf >/dev/null 2>&1; then
        echo "librewolf"
    elif command -v firefox >/dev/null 2>&1; then
        echo "firefox"
    else
        echo "xdg-open"
    fi
}

# Function to show package details in browser
show_package_in_browser() {
    local pkg="$1"
    local browser=$(detect_browser)
    local url="https://archlinux.org/packages/?q=$pkg"
    
    echo -e "${INFO} Opening package details for $pkg in browser..."
    $browser "$url" &>/dev/null &
}

# Function to refresh Waybar after updates
refresh_waybar() {
    # Clear both old and new cache files
    rm -f ~/.cache/waybar-updates-* 2>/dev/null
    rm -f "$CACHE_DIR"/*.cache 2>/dev/null
    
    # Also clear checkupdates cache to prevent stale data
    sudo rm -rf /tmp/checkup-db-* 2>/dev/null || true
    
    # Signal Waybar to refresh immediately
    pkill -SIGRTMIN+8 waybar 2>/dev/null || true
    
    echo "Update cache cleared and Waybar refreshed."
}

# Main function
main() {
    clear
    echo -e "${SEARCH} System Updates"
    echo "================="
    echo
    
    # Check for pacman updates (with caching)
    echo "Checking for pacman updates..."
    local pacman_cache="$CACHE_DIR/pacman.cache"
    if is_cache_valid "$pacman_cache"; then
        pacman_updates=$(cat "$pacman_cache" 2>/dev/null)
        echo "(using cached data)"
    else
        pacman_updates=$(timeout $TIMEOUT checkupdates 2>/dev/null || echo "")
        echo "$pacman_updates" > "$pacman_cache" 2>/dev/null || true
    fi
    pacman_count=0
    
    if [[ -n "$pacman_updates" ]]; then
        pacman_count=$(echo "$pacman_updates" | wc -l)
        local count=0
        while IFS= read -r line; do
            pkg=$(echo "$line" | awk '{print $1}')
            desc=$(get_package_description "$pkg")
            count=$((count + 1))
            if [[ $count -eq $pacman_count ]]; then
                echo -e "└ 󰏗 ${CYAN}$pkg${NC}: $desc"
            else
                echo -e "├ 󰏗 ${CYAN}$pkg${NC}: $desc"
            fi
        done <<< "$pacman_updates"
        echo
    else
        echo -e "${CHECK} No pacman updates available"
        echo
    fi
    
    # Check for AUR updates
    echo -e "\nAUR"
    aur_updates=$(yay -Qum 2>/dev/null)
    aur_count=0
    flatpak_count=0
    
    if [[ -n "$aur_updates" ]]; then
        aur_count=$(echo "$aur_updates" | wc -l)
        local count=0
        while IFS= read -r line; do
            pkg=$(echo "$line" | awk '{print $1}')
            desc=$(get_package_description "$pkg")
            count=$((count + 1))
            if [[ $count -eq $aur_count ]]; then
                echo -e "└ 󰊤 ${PURPLE}$pkg${NC}: $desc"
            else
                echo -e "├ 󰊤 ${PURPLE}$pkg${NC}: $desc"
            fi
        done <<< "$aur_updates"
        echo
    else
        echo -e "${CHECK} No AUR updates available"
        echo
    fi
    
    # Check for Flatpak updates
    echo -e "\nFlatpak"
    flatpak_updates=$(flatpak remote-ls --updates 2>/dev/null)
    
    if [[ -n "$flatpak_updates" ]]; then
        flatpak_count=$(echo "$flatpak_updates" | wc -l)
        echo -e "${PACKAGE} $flatpak_count flatpak update(s) available:"
        echo "$flatpak_updates" | head -10
        [[ $(echo "$flatpak_updates" | wc -l) -gt 10 ]] && echo "... and $(($(echo "$flatpak_updates" | wc -l) - 10)) more"
    else
        echo -e "${CHECK} No flatpak updates available"
        echo
    fi
    echo
    # Show options
    echo "======================================="
        echo -e "\n${SHIELD} Update Options"
    echo -e "━━━━━━━━━━━━━━━━"
    echo "├ 1. Install pacman updates only (pacman -Syu)"
    echo "├ 2. Install AUR updates only (yay -Syu --aur)"
    echo "├ 3. Install all updates (yay -Syu)"
    echo "├ 3b. Install flatpak updates only (flatpak update -y)"
    echo "├ 4. Show package details in browser ($(detect_browser | tr '[:lower:]' '[:upper:]'))"
    echo "├ 5. Refresh cache and recheck"
    echo "└ 6. Exit without updating"
    echo
    
    # Get user choice
    read -p "Choose an option [1-6]: " choice
    
    case $choice in
        1)
            if [[ $pacman_count -gt 0 ]]; then
                echo -e "${INFO} Installing pacman updates..."
                sudo pacman -Syu
                # Clear cache immediately after successful installation
                rm -f "$CACHE_DIR"/*.cache 2>/dev/null
                refresh_waybar
            else
                echo -e "${INFO} No pacman updates to install."
            fi
            ;;
        2)
            if [[ $aur_count -gt 0 ]]; then
                echo -e "${INFO} Installing AUR updates..."
                yay -Syu --aur
                # Clear cache immediately after successful installation
                rm -f "$CACHE_DIR"/*.cache 2>/dev/null
                refresh_waybar
            else
                echo -e "${INFO} No AUR updates to install."
            fi
            ;;
        3)
            if [[ $((pacman_count + aur_count + flatpak_count)) -gt 0 ]]; then
                echo -e "${INFO} Installing all updates..."
                yay -Syu
                # Clear cache immediately after successful installation
                rm -f "$CACHE_DIR"/*.cache 2>/dev/null
                refresh_waybar
            else
                echo -e "${INFO} No updates to install."
            fi
            ;;
        3b)
            echo -e "${INFO} Checking for flatpak updates..."
            if command -v flatpak >/dev/null 2>&1; then
                flatpak_updates=$(flatpak remote-ls --updates 2>/dev/null)
                if [[ -n "$flatpak_updates" ]]; then
                    echo -e "${INFO} Installing flatpak updates..."
                    flatpak update -y
                    rm -f "$CACHE_DIR/flatpak.cache" 2>/dev/null
                    refresh_waybar
                else
                    echo -e "${INFO} No flatpak updates available."
                fi
            else
                echo -e "${WARNING} Flatpak not found on system."
            fi
            ;;
        4)
            if [[ $((pacman_count + aur_count)) -gt 0 ]]; then
                echo -e "${BROWSER} Opening package details..."
                if [[ -n "$pacman_updates" ]]; then
                    while IFS= read -r line; do
                        pkg=$(echo "$line" | awk '{print $1}')
                        show_package_in_browser "$pkg"
                        sleep 1
                    done <<< "$pacman_updates"
                fi
                if [[ -n "$aur_updates" ]]; then
                    while IFS= read -r line; do
                        pkg=$(echo "$line" | awk '{print $1}')
                        show_package_in_browser "$pkg"
                        sleep 1
                    done <<< "$aur_updates"
                fi
            else
                echo -e "${INFO} No packages to show."
            fi
            ;;
        5)
            echo -e "${INFO} Refreshing cache..."
            rm -f "$CACHE_DIR"/*.cache 2>/dev/null || true
            echo "Cache cleared. Restarting..."
            sleep 1
            exec "$0"
            ;;
        6)
            echo -e "${EXIT} Exiting without updating"
            ;;
        *)
            echo -e "${CROSS} Invalid option. Please choose 1-6."
            ;;
    esac
    
    echo
    echo "Press any key to close..."
    read -n 1
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi