#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# 📦 SYSTEM UPDATES CHECKER - Professional Update Management
# Check for available updates and manage system upgrades
# ═══════════════════════════════════════════════════════════════════

check_updates() {
    # Check for updates without downloading
    local updates=$(checkupdates 2>/dev/null | wc -l)
    
    if [ "$updates" -gt 0 ]; then
        echo "$updates"
    else
        echo "0"
    fi
}

upgrade_system() {
    # Launch terminal with upgrade command
    if command -v alacritty >/dev/null 2>&1; then
        alacritty -e bash -c "sudo pacman -Syu; read -p 'Press Enter to close...'"
    elif command -v kitty >/dev/null 2>&1; then
        kitty bash -c "sudo pacman -Syu; read -p 'Press Enter to close...'"
    else
        # Fallback to hyprland terminal
        hyprctl dispatch exec "[float] alacritty -e bash -c 'sudo pacman -Syu; read -p \"Press Enter to close...\"'"
    fi
}

case "${1:-check}" in
    "check")
        check_updates
        ;;
    "upgrade")
        upgrade_system
        ;;
    "tooltip")
        local updates=$(check_updates)
        if [ "$updates" -gt 0 ]; then
            echo "$updates package updates available
Click to upgrade system"
        else
            echo "System up to date
No updates available"
        fi
        ;;
esac