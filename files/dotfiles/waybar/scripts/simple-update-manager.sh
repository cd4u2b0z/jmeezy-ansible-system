#!/bin/bash

# Enhanced Update Manager with Package Descriptions
# Author: GitHub Copilot
# Description: Smart update manager with package descriptions and browser integration

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

# Function to get package description with system-specific reasoning
get_package_description() {
    local pkg="$1"
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
        pipewire*|wireplumber*) system_reason=" ${YELLOW}[HIGH for your audio system]${NC}" ;;
        kitty*) system_reason=" ${GREEN}[MEDIUM for your terminal]${NC}" ;;
        firefox*|brave*|chromium*) system_reason=" ${YELLOW}[HIGH for web security]${NC}" ;;
        steam*|proton*|lutris*|heroic*|bottles*|protontricks*|winetricks*) system_reason=" ${GREEN}[MEDIUM for gaming compatibility]${NC}" ;;
        wine*|dxvk*|vkd3d*|lib32-*) system_reason=" ${GREEN}[MEDIUM for Windows game compatibility]${NC}" ;;
        gamemode*|mangohud*) system_reason=" ${GREEN}[MEDIUM for gaming performance]${NC}" ;;
        nvidia*|lib32-nvidia*) system_reason=" ${YELLOW}[HIGH for RTX 3090 drivers]${NC}" ;;
        ncspot*) system_reason=" ${BLUE}[LOW for your Spotify client]${NC}" ;;
        gcc*|rust*|python*) system_reason=" ${GREEN}[MEDIUM for development]${NC}" ;;
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
    # Clear update cache files
    rm -f ~/.cache/waybar-updates-* 2>/dev/null
    
    # Use a safer approach - just clear cache and let Waybar refresh naturally
    # This prevents accidentally killing Waybar during updates
    echo "Update cache cleared. Waybar will refresh automatically."
    
    # Waybar will automatically refresh when it detects the cache files are missing
    # This is much safer than sending kill signals during package installations
}

# Main function
main() {
    echo -e "${SEARCH} System Updates"
    echo -e "━━━━━━━━━━━━━━━━"
    echo

    # Check for pacman updates
    echo -e "\nPackages"
    pacman_updates=$(checkupdates 2>/dev/null)
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
    
    # Show options
    echo "======================================="
        echo -e "\n${SHIELD} Update Options"
    echo -e "━━━━━━━━━━━━━━━━"
    echo "├ 1. Install pacman updates only (pacman -Syu)"
    echo "├ 2. Install AUR updates only (yay -Syu --aur)"
    echo "├ 3. Install all updates (yay -Syu)"
    echo "├ 4. Show package details in browser ($(detect_browser | tr '[:lower:]' '[:upper:]'))"
    echo "└ 5. Exit without updating"
    echo
    
    # Get user choice
    read -p "Choose an option [1-5]: " choice
    
    case $choice in
        1)
            if [[ $pacman_count -gt 0 ]]; then
                echo -e "${INFO} Installing pacman updates..."
                sudo pacman -Syu
                refresh_waybar
            else
                echo -e "${INFO} No pacman updates to install."
            fi
            ;;
        2)
            if [[ $aur_count -gt 0 ]]; then
                echo -e "${INFO} Installing AUR updates..."
                yay -Syu --aur
                refresh_waybar
            else
                echo -e "${INFO} No AUR updates to install."
            fi
            ;;
        3)
            if [[ $((pacman_count + aur_count)) -gt 0 ]]; then
                echo -e "${INFO} Installing all updates..."
                yay -Syu
                refresh_waybar
            else
                echo -e "${INFO} No updates to install."
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
            echo -e "${EXIT} Exiting without updating"
            ;;
        *)
            echo -e "${CROSS} Invalid option. Please choose 1-5."
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