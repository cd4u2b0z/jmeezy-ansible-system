#!/bin/bash

# 🎵 GRUVBOX TRIPLE-MONITOR MUSIC SETUP
# Advanced TMUX music interface with multi-monitor support

# Colors
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[35m"
ORANGE="\033[38;5;208m"
RESET="\033[0m"

SESSION_NAME="gruvbox-music"
MUSIC_CONFIG="$HOME/.config/tmux/tmux-music.conf"

# Function to check if session exists
session_exists() {
    tmux has-session -t "$SESSION_NAME" 2>/dev/null
}

# Function to create music session
create_music_session() {
    echo -e "${GREEN}🎵 Creating Gruvbox Music Session...${RESET}"
    
    # Create new session with music config
    tmux -f "$MUSIC_CONFIG" new-session -d -s "$SESSION_NAME" -n "Dashboard"
    
    # Window 1: Music Dashboard
    tmux send-keys -t "$SESSION_NAME:Dashboard" "~/.config/hypr/scripts/gruvbox-music-interface.sh" Enter
    
    # Window 2: Spotify (if available)
    tmux new-window -t "$SESSION_NAME" -n "Spotify"
    if command -v spotify &> /dev/null; then
        tmux send-keys -t "$SESSION_NAME:Spotify" "spotify" Enter
    else
        tmux send-keys -t "$SESSION_NAME:Spotify" "echo 'Spotify not installed. Install with: yay -S spotify'" Enter
    fi
    
    # Window 3: ncspot (Terminal Spotify client)
    tmux new-window -t "$SESSION_NAME" -n "ncspot"
    if command -v ncspot &> /dev/null; then
        tmux send-keys -t "$SESSION_NAME:ncspot" "ncspot" Enter
    else
        tmux send-keys -t "$SESSION_NAME:ncspot" "echo 'Installing ncspot...'; yay -S ncspot && ncspot" Enter
    fi
    
    # Window 4: Audio Visualizer
    tmux new-window -t "$SESSION_NAME" -n "Visualizer"
    tmux split-window -h -t "$SESSION_NAME:Visualizer"
    tmux send-keys -t "$SESSION_NAME:Visualizer.0" "cava" Enter
    tmux send-keys -t "$SESSION_NAME:Visualizer.1" "echo -e '🎛️  Audio Controls:\n'; echo 'Volume: Use wpctl or pavucontrol'; echo 'MPD Status:'; systemctl --user status mpd" Enter
    
    # Window 5: MPD Control
    tmux new-window -t "$SESSION_NAME" -n "MPD"
    tmux split-window -v -t "$SESSION_NAME:MPD"
    if command -v ncmpcpp &> /dev/null; then
        tmux send-keys -t "$SESSION_NAME:MPD.0" "ncmpcpp" Enter
    else
        tmux send-keys -t "$SESSION_NAME:MPD.0" "echo 'Installing ncmpcpp...'; sudo pacman -S ncmpcpp && ncmpcpp" Enter
    fi
    tmux send-keys -t "$SESSION_NAME:MPD.1" "watch -n 1 'echo \"🎵 MPD Status:\"; mpc status 2>/dev/null || echo \"MPD not running\"'" Enter
    
    # Window 6: System Monitor (for performance)
    tmux new-window -t "$SESSION_NAME" -n "Monitor"
    tmux split-window -h -t "$SESSION_NAME:Monitor"
    tmux send-keys -t "$SESSION_NAME:Monitor.0" "htop" Enter
    tmux send-keys -t "$SESSION_NAME:Monitor.1" "watch -n 2 'echo \"🔊 Audio Info:\"; wpctl status | head -20'" Enter
    
    # Select first window
    tmux select-window -t "$SESSION_NAME:Dashboard"
    
    echo -e "${GREEN}✅ Music session created successfully!${RESET}"
}

# Function to attach to existing session
attach_session() {
    echo -e "${BLUE}🔗 Attaching to existing music session...${RESET}"
    tmux attach-session -t "$SESSION_NAME"
}

# Function to show session status
show_status() {
    echo -e "${PURPLE}🎵 GRUVBOX MUSIC SESSION STATUS${RESET}"
    echo "=================================="
    
    if session_exists; then
        echo -e "${GREEN}✅ Session Status: Active${RESET}"
        echo -e "${YELLOW}📱 Windows:${RESET}"
        tmux list-windows -t "$SESSION_NAME" -F "  #{window_index}: #{window_name} (#{window_panes} panes)"
        echo ""
        echo -e "${BLUE}🎵 Current Playing:${RESET}"
        playerctl metadata --format "  ♪ {{ artist }} - {{ title }}" 2>/dev/null || echo "  No music playing"
        echo ""
        echo -e "${ORANGE}🔊 Volume:${RESET} $(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)"%"}')"
    else
        echo -e "${YELLOW}⚠️  Session Status: Not running${RESET}"
    fi
}

# Function to kill session
kill_session() {
    if session_exists; then
        tmux kill-session -t "$SESSION_NAME"
        echo -e "${GREEN}✅ Music session terminated${RESET}"
    else
        echo -e "${YELLOW}⚠️  No active music session to kill${RESET}"
    fi
}

# Main menu
main_menu() {
    clear
    echo -e "${PURPLE}🎵 GRUVBOX TRIPLE-MONITOR MUSIC INTERFACE${RESET}"
    echo "=========================================="
    echo ""
    echo "1) 🚀 Start Music Session"
    echo "2) 🔗 Attach to Session"
    echo "3) 📊 Show Status"
    echo "4) 🛑 Kill Session"
    echo "5) 🎛️  Quick Music Controls"
    echo "6) 📱 Launch Individual Apps"
    echo "7) ❌ Exit"
    echo ""
    read -p "Choose option (1-7): " choice
    
    case $choice in
        1)
            if session_exists; then
                echo -e "${YELLOW}⚠️  Session already exists. Attaching...${RESET}"
                attach_session
            else
                create_music_session
                attach_session
            fi
            ;;
        2)
            if session_exists; then
                attach_session
            else
                echo -e "${YELLOW}⚠️  No session exists. Creating new one...${RESET}"
                create_music_session
                attach_session
            fi
            ;;
        3)
            show_status
            echo ""
            read -p "Press Enter to continue..."
            main_menu
            ;;
        4)
            kill_session
            read -p "Press Enter to continue..."
            main_menu
            ;;
        5)
            music_controls
            ;;
        6)
            app_launcher
            ;;
        7)
            echo -e "${GREEN}👋 Goodbye!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Invalid option. Please try again.${RESET}"
            sleep 1
            main_menu
            ;;
    esac
}

# Music controls submenu
music_controls() {
    clear
    echo -e "${BLUE}🎛️  QUICK MUSIC CONTROLS${RESET}"
    echo "========================"
    echo ""
    echo "Current: $(playerctl metadata --format '{{ artist }} - {{ title }}' 2>/dev/null || echo 'No music playing')"
    echo "Volume: $(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)"%"}')"
    echo ""
    echo "1) ⏯️  Play/Pause"
    echo "2) ⏭️  Next Track"
    echo "3) ⏮️  Previous Track"
    echo "4) 🔊 Volume Up"
    echo "5) 🔉 Volume Down"
    echo "6) 🔇 Mute Toggle"
    echo "7) 🔙 Back to Main Menu"
    echo ""
    read -p "Choose option (1-7): " control_choice
    
    case $control_choice in
        1) playerctl play-pause ;;
        2) playerctl next ;;
        3) playerctl previous ;;
        4) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ ;;
        5) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
        6) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
        7) main_menu; return ;;
    esac
    
    sleep 1
    music_controls
}

# App launcher submenu
app_launcher() {
    clear
    echo -e "${ORANGE}📱 INDIVIDUAL APP LAUNCHER${RESET}"
    echo "==========================="
    echo ""
    echo "1) 🎵 Spotify"
    echo "2) 🎼 ncspot (Terminal Spotify)"
    echo "3) 🎵 ncmpcpp (MPD Client)"
    echo "4) 🌊 cava (Audio Visualizer)"
    echo "5) 🎛️  pavucontrol (Audio Control)"
    echo "6) 📊 htop (System Monitor)"
    echo "7) 🔙 Back to Main Menu"
    echo ""
    read -p "Choose app (1-7): " app_choice
    
    case $app_choice in
        1) spotify & ;;
        2) kitty -e ncspot & ;;
        3) kitty -e ncmpcpp & ;;
        4) kitty -e cava & ;;
        5) pavucontrol & ;;
        6) kitty -e htop & ;;
        7) main_menu; return ;;
    esac
    
    echo -e "${GREEN}✅ Launching app...${RESET}"
    sleep 1
    app_launcher
}

# Ensure tmux config exists
if [[ ! -f "$MUSIC_CONFIG" ]]; then
    echo -e "${YELLOW}⚠️  TMUX music config not found. Please run the Ansible playbook first.${RESET}"
    exit 1
fi

# Start main menu
main_menu
