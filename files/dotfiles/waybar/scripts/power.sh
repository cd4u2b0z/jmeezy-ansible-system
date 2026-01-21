#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# ⚡ WAYBAR POWER MENU - Gaming-Focused Power Management
# Beautiful rofi menu with gaming considerations
# ═══════════════════════════════════════════════════════════════════

# Colors (Nord theme)
declare -A COLORS=(
    ["bg"]="#2e3440"
    ["fg"]="#eceff4"
    ["accent"]="#5e81ac"
    ["red"]="#bf616a"
    ["green"]="#a3be8c"
    ["yellow"]="#ebcb8b"
    ["blue"]="#88c0d0"
)

# Power options
POWER_OPTIONS="󰐥 Shutdown\n󰜉 Restart\n󰤄 Sleep\n󰍃 Logout\n󰒲 Hibernate\n󰌾 Lock"

# Gaming-aware shutdown function
gaming_aware_shutdown() {
    local action="$1"
    local message="$2"
    
    # Check for running games/important processes
    local gaming_processes=""
    
    # Check for Steam games
    if pgrep -f "steamapps" >/dev/null; then
        gaming_processes="Steam games, "
    fi
    
    # Check for other gaming platforms
    if pgrep -f "lutris" >/dev/null; then
        gaming_processes="${gaming_processes}Lutris games, "
    fi
    
    if pgrep -f "heroic" >/dev/null; then
        gaming_processes="${gaming_processes}Epic Games, "
    fi
    
    # Check for VMs
    if pgrep -f "qemu\|virtualbox" >/dev/null; then
        gaming_processes="${gaming_processes}Virtual machines, "
    fi
    
    # Remove trailing comma
    gaming_processes="${gaming_processes%, }"
    
    if [ -n "$gaming_processes" ]; then
        local warning_msg="⚠️ Warning: $gaming_processes currently running!\n\nProceed with $message?"
        
        local confirm=$(echo -e "Yes\nNo" | rofi -dmenu \
            -theme-str "window { width: 400px; }" \
            -theme-str "listview { lines: 2; }" \
            -theme-str "element selected { background-color: ${COLORS[red]}; }" \
            -p "⚠️ Gaming Warning" \
            -mesg "$warning_msg")
        
        if [ "$confirm" != "Yes" ]; then
            exit 0
        fi
    fi
    
    # Execute the action
    case "$action" in
        "shutdown") systemctl poweroff ;;
        "restart") systemctl reboot ;;
        "sleep") systemctl suspend ;;
        "hibernate") systemctl hibernate ;;
        "logout") hyprctl dispatch exit ;;
        "lock") swaylock -f ;;
    esac
}

# Rofi theme configuration
ROFI_THEME="
window {
    width: 300px;
    background-color: ${COLORS[bg]}ee;
    border: 2px solid ${COLORS[accent]};
    border-radius: 12px;
    padding: 20px;
}

listview {
    lines: 6;
    spacing: 8px;
    background-color: transparent;
    border: none;
}

element {
    padding: 12px;
    border-radius: 8px;
    background-color: transparent;
    text-color: ${COLORS[fg]};
    font: \"JetBrainsMono Nerd Font 14\";
}

element selected {
    background-color: ${COLORS[accent]};
    text-color: ${COLORS[bg]};
}

element-text {
    horizontal-align: 0.5;
    vertical-align: 0.5;
}

prompt {
    enabled: false;
}

inputbar {
    enabled: false;
}

mainbox {
    children: [listview];
}
"

# Show power menu
show_menu() {
    local choice=$(echo -e "$POWER_OPTIONS" | rofi -dmenu \
        -theme-str "$ROFI_THEME" \
        -selected-row 0 \
        -no-custom \
        -format 'i:s')
    
    case "$choice" in
        "0:󰐥 Shutdown")
            gaming_aware_shutdown "shutdown" "shutdown"
            ;;
        "1:󰜉 Restart")
            gaming_aware_shutdown "restart" "restart"
            ;;
        "2:󰤄 Sleep")
            gaming_aware_shutdown "sleep" "sleep"
            ;;
        "3:󰍃 Logout")
            gaming_aware_shutdown "logout" "logout"
            ;;
        "4:󰒲 Hibernate")
            gaming_aware_shutdown "hibernate" "hibernation"
            ;;
        "5:󰌾 Lock")
            gaming_aware_shutdown "lock" "lock screen"
            ;;
    esac
}

# Quick actions without menu
quick_action() {
    case "$1" in
        "lock")
            swaylock -f
            ;;
        "sleep")
            gaming_aware_shutdown "sleep" "sleep"
            ;;
        "logout")
            gaming_aware_shutdown "logout" "logout"
            ;;
        *)
            show_menu
            ;;
    esac
}

# Handle different invocation methods
case "${1:-menu}" in
    "menu")
        show_menu
        ;;
    "lock"|"sleep"|"logout")
        quick_action "$1"
        ;;
    "icon")
        echo "⏻"
        ;;
    "tooltip")
        echo "Power Menu
Left: Full menu
Right: Quick lock
Middle: Sleep"
        ;;
esac