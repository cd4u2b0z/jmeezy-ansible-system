#!/bin/bash
# Update Manager - Clean TUI

CACHE_DIR="/tmp/update-manager"
CACHE_DURATION=120
mkdir -p "$CACHE_DIR" 2>/dev/null

R='\033[0;31m'; O='\033[0;33m'; Y='\033[1;33m'; G='\033[0;32m'
B='\033[0;34m'; P='\033[0;35m'; C='\033[0;36m'; D='\033[0;90m'
W='\033[1;37m'; N='\033[0m'

is_cache_valid() {
    [[ -f "$1" ]] && [[ $(($(date +%s) - $(stat -c %Y "$1" 2>/dev/null || echo 0))) -lt $CACHE_DURATION ]]
}

get_priority_info() {
    case "$1" in
        systemd*|glibc*|openssl*|gnupg*|pacman*|archlinux-keyring*|linux|linux-lts|linux-zen)
            echo -e "${R}󰚌 CRITICAL${N} - System/Security" ;;
        nvidia*|lib32-nvidia*) echo -e "${O}󰀪 HIGH${N} - RTX 3090 drivers" ;;
        mesa*|vulkan*|lib32-mesa*|lib32-vulkan*) echo -e "${O}󰀪 HIGH${N} - Graphics" ;;
        firefox*|brave*|chromium*|librewolf*) echo -e "${O}󰀪 HIGH${N} - Browser" ;;
        hyprland*|wayland*) echo -e "${O}󰀪 HIGH${N} - Window manager" ;;
        pipewire*|wireplumber*) echo -e "${Y}󰋼 MEDIUM${N} - Audio" ;;
        steam*|lutris*|heroic*|bottles*|wine*|dxvk*|gamemode*|mangohud*)
            echo -e "${Y}󰋼 MEDIUM${N} - Gaming" ;;
        waybar*|mako*|wofi*|kitty*) echo -e "${Y}󰋼 MEDIUM${N} - Desktop" ;;
        *font*|ttf-*|otf-*) echo -e "${D}LOW${N} - Fonts" ;;
        *) echo -e "${D}LOW${N}" ;;
    esac
}

refresh_waybar() {
    rm -f "$CACHE_DIR"/*.cache 2>/dev/null
    pkill -SIGRTMIN+8 waybar 2>/dev/null || true
}

detect_browser() {
    for b in librewolf brave firefox chromium; do
        command -v "$b" &>/dev/null && echo "$b" && return
    done
    echo "xdg-open"
}

main() {
    clear
    echo -e "${W}╔══════════════════════════════════════════════════════════════════╗${N}"
    echo -e "${W}║                    󰚥  UPDATE MANAGER                            ║${N}"
    echo -e "${W}╚══════════════════════════════════════════════════════════════════╝${N}"
    
    local pacman_count=0 aur_count=0 flatpak_count=0
    local pacman_updates="" aur_updates="" flatpak_updates=""
    
    echo -e "\n${C}┌─────────────────────────────────────────────────────────────────┐${N}"
    echo -e "${C}│  󰏗  Official Repositories                                       │${N}"
    echo -e "${C}└─────────────────────────────────────────────────────────────────┘${N}"
    echo -ne "  ${D}󰍉 Checking pacman...${N}"
    
    local pacman_cache="$CACHE_DIR/pacman.cache"
    if is_cache_valid "$pacman_cache"; then
        pacman_updates=$(cat "$pacman_cache" 2>/dev/null)
        echo -ne " ${D}(cached)${N}"
    else
        pacman_updates=$(timeout 20 checkupdates 2>/dev/null || echo "")
        [[ -n "$pacman_updates" ]] && echo "$pacman_updates" > "$pacman_cache"
    fi
    echo -e " ${G}󰄬${N}"
    
    if [[ -n "$pacman_updates" ]]; then
        pacman_count=$(echo "$pacman_updates" | grep -c .)
        echo -e "\n  ${W}$pacman_count package(s) available:${N}\n"
        while IFS= read -r line; do
            local pkg=$(echo "$line" | awk '{print $1}')
            local ver=$(echo "$line" | awk '{print $2 " → " $4}')
            printf "    ${C}%-28s${N} ${D}%s${N}\n" "$pkg" "$ver"
            printf "      %b\n" "$(get_priority_info "$pkg")"
        done <<< "$pacman_updates"
    else
        echo -e "\n  ${G}󰄬 All official packages up to date${N}"
    fi
    
    echo -e "\n${P}┌─────────────────────────────────────────────────────────────────┐${N}"
    echo -e "${P}│  󰊤  AUR (Arch User Repository)                                  │${N}"
    echo -e "${P}└─────────────────────────────────────────────────────────────────┘${N}"
    echo -ne "  ${D}󰍉 Checking AUR...${N}"
    
    local aur_cache="$CACHE_DIR/aur.cache"
    if command -v yay &>/dev/null; then
        if is_cache_valid "$aur_cache"; then
            aur_updates=$(cat "$aur_cache" 2>/dev/null)
            echo -ne " ${D}(cached)${N}"
        else
            aur_updates=$(timeout 30 yay -Qum 2>/dev/null || echo "")
            [[ -n "$aur_updates" ]] && echo "$aur_updates" > "$aur_cache"
        fi
        echo -e " ${G}󰄬${N}"
        
        if [[ -n "$aur_updates" ]]; then
            aur_count=$(echo "$aur_updates" | grep -c .)
            echo -e "\n  ${W}$aur_count package(s) available:${N}\n"
            while IFS= read -r line; do
                local pkg=$(echo "$line" | awk '{print $1}')
                printf "    ${P}%-28s${N}\n" "$pkg"
                printf "      %b\n" "$(get_priority_info "$pkg")"
            done <<< "$aur_updates"
        else
            echo -e "\n  ${G}󰄬 All AUR packages up to date${N}"
        fi
    else
        echo -e " ${G}󰄬${N}\n  ${D}yay not installed${N}"
    fi
    
    echo -e "\n${B}┌─────────────────────────────────────────────────────────────────┐${N}"
    echo -e "${B}│  󰏖  Flatpak Applications                                        │${N}"
    echo -e "${B}└─────────────────────────────────────────────────────────────────┘${N}"
    echo -ne "  ${D}󰍉 Checking Flatpak...${N}"
    
    local flatpak_cache="$CACHE_DIR/flatpak.cache"
    if command -v flatpak &>/dev/null; then
        if is_cache_valid "$flatpak_cache"; then
            flatpak_updates=$(cat "$flatpak_cache" 2>/dev/null)
            echo -ne " ${D}(cached)${N}"
        else
            flatpak_updates=$(timeout 15 flatpak remote-ls --updates 2>/dev/null || echo "")
            [[ -n "$flatpak_updates" ]] && echo "$flatpak_updates" > "$flatpak_cache"
        fi
        echo -e " ${G}󰄬${N}"
        
        if [[ -n "$flatpak_updates" ]]; then
            flatpak_count=$(echo "$flatpak_updates" | grep -c .)
            echo -e "\n  ${W}$flatpak_count app(s) available:${N}\n"
            while IFS= read -r line; do
                printf "    ${B}󰏖 %s${N}\n" "$(echo "$line" | awk '{print $1}')"
            done <<< "$flatpak_updates"
        else
            echo -e "\n  ${G}󰄬 All Flatpak apps up to date${N}"
        fi
    else
        echo -e " ${G}󰄬${N}\n  ${D}Flatpak not installed${N}"
    fi
    
    local total=$((pacman_count + aur_count + flatpak_count))
    
    echo -e "\n${W}╔══════════════════════════════════════════════════════════════════╗${N}"
    printf "${W}║  TOTAL: %-3d updates     ${N}" "$total"
    printf "${D}(Pacman: %d │ AUR: %d │ Flatpak: %d)${N}" "$pacman_count" "$aur_count" "$flatpak_count"
    echo -e "${W}      ║${N}"
    echo -e "${W}╚══════════════════════════════════════════════════════════════════╝${N}"
    
    echo -e "\n${W}  󰏔  Actions${N}"
    echo -e "${D}  ─────────────────────────────────────────────────────────────────${N}"
    echo -e "    ${C}1${N}   Install Pacman updates           ${D}sudo pacman -Syu${N}"
    echo -e "    ${P}2${N}   Install AUR updates              ${D}yay -Sua${N}"
    echo -e "    ${B}3${N}   Install Flatpak updates          ${D}flatpak update${N}"
    echo -e "    ${G}4${N}   Install ALL updates              ${D}yay -Syu + flatpak${N}"
    echo -e "    ${Y}5${N}   Search package in browser        ${D}$(detect_browser)${N}"
    echo -e "    ${D}6${N}   Refresh cache"
    echo -e "    ${R}q${N}   Exit"
    echo -e "${D}  ─────────────────────────────────────────────────────────────────${N}"
    
    read -rp "  Select [1-6/q]: " choice
    
    case "$choice" in
        1) [[ $pacman_count -gt 0 ]] && { echo -e "\n${Y}  󰀦 Update $pacman_count package(s)?${N}"; read -rp "  [y/N]: " c; [[ "$c" =~ ^[Yy]$ ]] && sudo pacman -Syu && refresh_waybar; } || echo -e "\n${D}  No updates.${N}" ;;
        2) [[ $aur_count -gt 0 ]] && { echo -e "\n${Y}  󰀦 Update $aur_count package(s)?${N}"; read -rp "  [y/N]: " c; [[ "$c" =~ ^[Yy]$ ]] && yay -Sua && refresh_waybar; } || echo -e "\n${D}  No updates.${N}" ;;
        3) [[ $flatpak_count -gt 0 ]] && { echo -e "\n${Y}  󰀦 Update $flatpak_count app(s)?${N}"; read -rp "  [y/N]: " c; [[ "$c" =~ ^[Yy]$ ]] && flatpak update -y && refresh_waybar; } || echo -e "\n${D}  No updates.${N}" ;;
        4) [[ $total -gt 0 ]] && { echo -e "\n${Y}  󰀦 Update ALL $total?${N}"; read -rp "  [y/N]: " c; [[ "$c" =~ ^[Yy]$ ]] && { [[ $((pacman_count+aur_count)) -gt 0 ]] && yay -Syu; [[ $flatpak_count -gt 0 ]] && flatpak update -y; refresh_waybar; }; } || echo -e "\n${G}  Up to date"Part 3 done"{N}" ;;
        5) read -rp "  Package: " p; [[ -n "$p" ]] && $(detect_browser) "https://archlinux.org/packages/?q=$p" &>/dev/null & ;;
        6) rm -f "$CACHE_DIR"/*.cache && exec "$0" ;;
        q|Q) echo -e "\n${D}  󰗼 Bye"Part 3 done"{N}"; exit 0 ;;
        *) echo -e "\n${R}  Invalid${N}" ;;
    esac
    
    echo; read -n 1 -s -r -p "  Press any key..."; exec "$0"
}

main
