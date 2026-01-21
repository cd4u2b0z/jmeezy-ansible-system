#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# 🎮 GAMING APPS MONITOR - Steam & Discord Status
# Shows status and provides quick access to gaming platforms
# ═══════════════════════════════════════════════════════════════════

APP="$1"
ACTION="${2:-status}"

steam_status() {
    if pgrep -x "steam" >/dev/null; then
        # Check if user is in a game
        if pgrep -f "steamapps" >/dev/null; then
            echo "🎮 Gaming"
            return 0
        else
            echo "🎮 Steam"
            return 0
        fi
    else
        echo "🎮"
        return 1
    fi
}

discord_status() {
    if pgrep -x "discord" >/dev/null || pgrep -x "Discord" >/dev/null; then
        echo "💬 Discord"
        return 0
    else
        echo "💬"
        return 1
    fi
}

steam_tooltip() {
    if pgrep -x "steam" >/dev/null; then
        if pgrep -f "steamapps" >/dev/null; then
            echo "Steam: Gaming Active
Left: Open Steam
Right: Show recent games
Middle: Open Big Picture"
        else
            echo "Steam: Online
Left: Open Steam
Right: Show library
Middle: Open Big Picture"
        fi
    else
        echo "Steam: Offline
Click to launch Steam"
    fi
}

discord_tooltip() {
    if pgrep -x "discord" >/dev/null || pgrep -x "Discord" >/dev/null; then
        echo "Discord: Online
Left: Show Discord
Right: Mute/Unmute
Middle: Settings"
    else
        echo "Discord: Offline
Click to launch Discord"
    fi
}

steam_click() {
    case "$1" in
        "left")
            if pgrep -x "steam" >/dev/null; then
                # Bring Steam to front
                hyprctl dispatch focuswindow title:Steam
            else
                # Launch Steam
                steam &
            fi
            ;;
        "right")
            if pgrep -x "steam" >/dev/null; then
                # Open Steam library
                steam steam://nav/games/library &
            else
                steam &
            fi
            ;;
        "middle")
            if pgrep -x "steam" >/dev/null; then
                # Open Big Picture mode
                steam steam://open/bigpicture &
            else
                steam -bigpicture &
            fi
            ;;
    esac
}

discord_click() {
    case "$1" in
        "left")
            if pgrep -x "discord" >/dev/null || pgrep -x "Discord" >/dev/null; then
                # Bring Discord to front
                hyprctl dispatch focuswindow class:discord
            else
                # Launch Discord
                discord &
            fi
            ;;
        "right")
            # Toggle Discord mute (if running)
            if pgrep -x "discord" >/dev/null || pgrep -x "Discord" >/dev/null; then
                # Send Ctrl+Shift+M to Discord (mute hotkey)
                hyprctl dispatch focuswindow class:discord
                sleep 0.1
                wtype -k ctrl+shift+m
            fi
            ;;
        "middle")
            if pgrep -x "discord" >/dev/null || pgrep -x "Discord" >/dev/null; then
                # Open Discord settings
                hyprctl dispatch focuswindow class:discord
                sleep 0.1
                wtype -k ctrl+comma
            else
                discord &
            fi
            ;;
    esac
}

# Main execution
case "$APP" in
    "steam")
        case "$ACTION" in
            "status")
                steam_status
                ;;
            "tooltip")
                steam_tooltip
                ;;
            "left"|"right"|"middle")
                steam_click "$ACTION"
                ;;
        esac
        ;;
    "discord")
        case "$ACTION" in
            "status")
                discord_status
                ;;
            "tooltip")
                discord_tooltip
                ;;
            "left"|"right"|"middle")
                discord_click "$ACTION"
                ;;
        esac
        ;;
    *)
        echo "Usage: $0 {steam|discord} [status|tooltip|left|right|middle]"
        exit 1
        ;;
esac