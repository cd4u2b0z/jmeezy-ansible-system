#!/bin/bash

# Smart Update Filter - Linux Mint Style for Arch Linux
# Filters updates based on user's specific hardware, software, and usage patterns
# Only shows relevant updates to avoid dependency hell and clutter

# System profile detection
SYSTEM_PROFILE_FILE="/tmp/system_profile_${USER}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Generate system profile for smart filtering
generate_system_profile() {
    echo "Generating system profile for smart filtering..." >&2
    
    # Hardware detection
    CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
    GPU_VENDOR=$(lspci | grep -i "vga\|display" | head -1 | grep -qi "nvidia" && echo "nvidia" || echo "other")
    
    # Software categories based on installed packages
    DESKTOP_ENV=$(pacman -Q | grep -E "(hyprland|gnome|kde|xfce)" | awk '{print $1}' | head -1)
    BROWSER=$(pacman -Q | grep -E "(firefox|brave|chromium)" | awk '{print $1}' | head -1)
    TERMINAL=$(pacman -Q | grep -E "(kitty|alacritty|gnome-terminal)" | awk '{print $1}' | head -1)
    AUDIO_SYSTEM=$(pacman -Q | grep -E "(pipewire|pulseaudio)" | awk '{print $1}' | head -1)
    
    # Development tools
    DEV_TOOLS=$(pacman -Q | grep -E "(gcc|rust|python|node|go|java)" | wc -l)
    
    # Gaming setup
    GAMING=$(pacman -Q | grep -E "(steam|lutris|wine|gamemode)" | wc -l)
    
    # Media tools  
    MEDIA=$(pacman -Q | grep -E "(vlc|mpv|ffmpeg|obs)" | wc -l)
    
    # Create profile
    cat > "$SYSTEM_PROFILE_FILE" << EOF
# System Profile for Smart Updates
CPU_VENDOR="$CPU_VENDOR"
GPU_VENDOR="$GPU_VENDOR"
DESKTOP_ENV="$DESKTOP_ENV"
BROWSER="$BROWSER"
TERMINAL="$TERMINAL" 
AUDIO_SYSTEM="$AUDIO_SYSTEM"
DEV_TOOLS="$DEV_TOOLS"
GAMING="$GAMING"
MEDIA="$MEDIA"
LAST_UPDATED="$(date)"
EOF
}

# Load or generate system profile
load_system_profile() {
    if [[ ! -f "$SYSTEM_PROFILE_FILE" ]] || [[ $(find "$SYSTEM_PROFILE_FILE" -mtime +7) ]]; then
        generate_system_profile
    fi
    source "$SYSTEM_PROFILE_FILE"
}

# Smart filtering logic - only show relevant updates
filter_updates() {
    local updates_raw="$1"
    local filtered_updates=""
    
    while IFS= read -r package; do
        [[ -z "$package" ]] && continue
        
        local pkg_name=$(echo "$package" | awk '{print $1}')
        local is_relevant=false
        
        # Core system packages (always relevant)
        if [[ "$pkg_name" =~ ^(linux|systemd|glibc|gcc|binutils|coreutils|util-linux|pacman|base).*$ ]]; then
            is_relevant=true
        fi
        
        # Hardware-specific packages
        case "$GPU_VENDOR" in
            "nvidia")
                if [[ "$pkg_name" =~ ^(nvidia|lib32-nvidia|cuda).*$ ]]; then
                    is_relevant=true
                fi
                ;;
        esac
        
        # CPU-specific packages
        case "$CPU_VENDOR" in
            "GenuineIntel")
                if [[ "$pkg_name" =~ ^(intel-ucode|intel-media-driver).*$ ]]; then
                    is_relevant=true
                fi
                ;;
            "AuthenticAMD") 
                if [[ "$pkg_name" =~ ^(amd-ucode|amdgpu).*$ ]]; then
                    is_relevant=true
                fi
                ;;
        esac
        
        # Desktop environment specific
        if [[ -n "$DESKTOP_ENV" ]] && [[ "$pkg_name" =~ .*$DESKTOP_ENV.* ]]; then
            is_relevant=true
        fi
        
        # Essential user applications
        if [[ "$pkg_name" =~ ^($BROWSER|$TERMINAL|$AUDIO_SYSTEM).*$ ]]; then
            is_relevant=true
        fi
        
        # Development tools (if user is a developer)
        if [[ "$DEV_TOOLS" -gt 5 ]]; then
            if [[ "$pkg_name" =~ ^(gcc|rust|python|nodejs|npm|git|vim|code).*$ ]]; then
                is_relevant=true
            fi
        fi
        
        # Gaming packages (if user is a gamer)
        if [[ "$GAMING" -gt 2 ]]; then
            if [[ "$pkg_name" =~ ^(steam|wine|dxvk|gamemode|lutris).*$ ]]; then
                is_relevant=true
            fi
        fi
        
        # Media packages (if user does media work)
        if [[ "$MEDIA" -gt 3 ]]; then
            if [[ "$pkg_name" =~ ^(vlc|mpv|ffmpeg|obs|gstreamer).*$ ]]; then
                is_relevant=true
            fi
        fi
        
        # Security packages (always relevant)
        if [[ "$pkg_name" =~ ^(openssl|gnutls|ca-certificates|gnupg).*$ ]]; then
            is_relevant=true
        fi
        
        # Waybar and related (user-specific)
        if [[ "$pkg_name" =~ ^(waybar|mako|wofi|hypr|wlroots).*$ ]]; then
            is_relevant=true
        fi
        
        # Font packages (if significant font usage detected)
        local font_count=$(pacman -Q | grep -c "font")
        if [[ "$font_count" -gt 10 ]] && [[ "$pkg_name" =~ .*font.* ]]; then
            is_relevant=true
        fi
        
        # Add to filtered list if relevant
        if [[ "$is_relevant" == true ]]; then
            filtered_updates+="$package"$'\n'
        fi
    done <<< "$updates_raw"
    
    echo "$filtered_updates"
}

# Get package category, importance, and reason for recommendation
get_package_info() {
    local pkg_name="$1"
    local category="Other"
    local importance="Medium"
    local reason="Part of your installed software"
    
    # Categorize packages with specific reasons
    case "$pkg_name" in
        linux*) 
            category="Kernel"
            importance="Critical"
            reason="Core system kernel - affects hardware compatibility and security"
            ;;
        systemd*|glibc*|gcc-libs*|filesystem*) 
            category="System Core"
            importance="Critical"
            reason="Essential system libraries - required for system stability"
            ;;
        nvidia*|lib32-nvidia*)
            category="Graphics Driver"  
            importance="Critical"
            reason="Your RTX 3090 graphics driver - improves gaming performance and stability"
            ;;
        intel-ucode*)
            category="CPU Microcode"
            importance="High" 
            reason="Intel CPU microcode for your i7-9700K - fixes CPU vulnerabilities"
            ;;
        *font*|ttf-*|noto-*)
            category="Fonts"
            importance="Low"
            reason="Font rendering for your desktop - affects text appearance"
            ;;
        hyprland*|xdg-desktop-portal-hyprland*)
            category="Window Manager"
            importance="Critical"
            reason="Your Hyprland compositor - core to your desktop experience"
            ;;
        waybar*|mako*|wofi*)
            category="Desktop UI"
            importance="High"
            reason="Your Nord-themed desktop components - UI functionality"
            ;;
        firefox*|brave*|chromium*)
            category="Web Browser"
            importance="High"
            reason="Your primary web browser - security and feature updates"
            ;;
        kitty*)
            category="Terminal"
            importance="Medium"
            reason="Your main terminal emulator - functionality improvements"
            ;;
        steam*|proton*)
            category="Gaming Platform"
            importance="Medium"
            reason="Your gaming platform - game compatibility improvements"
            ;;
        wine*|lutris*|gamemode*)
            category="Gaming Tools"
            importance="Medium"
            reason="Gaming compatibility layer - better Windows game support"
            ;;
        gcc*|rust*|python*|nodejs*)
            category="Development"
            importance="Medium"
            reason="Development tools you actively use - compiler/runtime updates"
            ;;
        vlc*|mpv*|ffmpeg*)
            category="Media"
            importance="Medium"
            reason="Media playback tools - codec and format support"
            ;;
        obs-studio*)
            category="Streaming"
            importance="Medium"
            reason="Your streaming/recording software - performance improvements"
            ;;
        pipewire*|wireplumber*)
            category="Audio System"
            importance="High"
            reason="Your audio pipeline - affects music and system sounds"
            ;;
        ncspot*)
            category="Music Player"
            importance="Low"
            reason="Your Spotify TUI client - feature updates"
            ;;
        openssh*|openssl*|gnupg*|ca-certificates*)
            category="Security"
            importance="Critical"
            reason="Security infrastructure - protects against vulnerabilities"
            ;;
        mesa*|lib32-mesa*)
            category="Graphics Libraries"
            importance="High"
            reason="Graphics acceleration libraries - affects performance"
            ;;
        pacman*|archlinux-keyring*)
            category="Package Manager"
            importance="Critical"
            reason="Package management system - required for future updates"
            ;;
    esac
    
    echo "$category|$importance|$reason"
}

# Main filtering function
main() {
    load_system_profile
    
    # Get all available updates
    local all_updates=$(checkupdates 2>/dev/null)
    
    if [[ -z "$all_updates" ]]; then
        echo "No updates available"
        exit 0
    fi
    
    # Filter updates
    local filtered_updates=$(filter_updates "$all_updates")
    local total_count=$(echo "$all_updates" | wc -l)
    local filtered_count=$(echo "$filtered_updates" | grep -c ".")
    
    if [[ "$1" == "--show-stats" ]]; then
        echo -e "${BLUE}Smart Update Filter Statistics:${NC}"
        echo -e "Total available updates: ${YELLOW}$total_count${NC}"
        echo -e "Relevant for your system: ${GREEN}$filtered_count${NC}"
        echo -e "Filtered out: ${RED}$((total_count - filtered_count))${NC}"
        echo ""
        echo -e "${BLUE}Your System Profile:${NC}"
        echo -e "• CPU: Intel i7-9700K (${CPU_VENDOR})"
        echo -e "• GPU: RTX 3090 (${GPU_VENDOR})"
        echo -e "• Desktop: ${DESKTOP_ENV} with Nord theme"
        echo -e "• Audio: ${AUDIO_SYSTEM}"
        echo -e "• Development tools: ${DEV_TOOLS} packages"
        echo -e "• Gaming setup: ${GAMING} packages"
        echo -e "• Media tools: ${MEDIA} packages"
        echo ""
    fi
    
    if [[ "$1" == "--explain" ]]; then
        echo -e "${BLUE}Why These Updates Are Recommended for Your System:${NC}"
        echo ""
        while IFS= read -r package; do
            [[ -z "$package" ]] && continue
            local pkg_name=$(echo "$package" | awk '{print $1}')
            local info=$(get_package_info "$pkg_name")
            local category=$(echo "$info" | cut -d'|' -f1)
            local importance=$(echo "$info" | cut -d'|' -f2)
            local reason=$(echo "$info" | cut -d'|' -f3)
            
            case "$importance" in
                "Critical") echo -e "${RED}🔴 CRITICAL${NC}: $pkg_name" ;;
                "High") echo -e "${YELLOW}🟡 HIGH${NC}: $pkg_name" ;;
                "Medium") echo -e "${GREEN}🟢 MEDIUM${NC}: $pkg_name" ;;
                "Low") echo -e "${BLUE}🔵 LOW${NC}: $pkg_name" ;;
            esac
            echo -e "   $reason"
            echo ""
        done <<< "$filtered_updates"
        return
    fi
    
    if [[ "$1" == "--categorized" ]]; then
        # Show categorized output with detailed explanations
        declare -A categories
        
        while IFS= read -r package; do
            [[ -z "$package" ]] && continue
            local pkg_name=$(echo "$package" | awk '{print $1}')
            local pkg_version=$(echo "$package" | awk '{print $2"->"$3}')
            local info=$(get_package_info "$pkg_name")
            local category=$(echo "$info" | cut -d'|' -f1)
            local importance=$(echo "$info" | cut -d'|' -f2)
            local reason=$(echo "$info" | cut -d'|' -f3)
            
            # Color code by importance
            local importance_color=""
            case "$importance" in
                "Critical") importance_color="$RED" ;;
                "High") importance_color="$YELLOW" ;;
                "Medium") importance_color="$GREEN" ;;
                "Low") importance_color="$BLUE" ;;
            esac
            
            categories["$category"]+="  ${importance_color}●${NC} $pkg_name ($pkg_version) - ${importance_color}$importance${NC}"$'\n'"    ↳ $reason"$'\n\n'
        done <<< "$filtered_updates"
        
        # Display by category with enhanced formatting
        for category in "Kernel" "System Core" "Security" "CPU Microcode" "Graphics Driver" "Graphics Libraries" "Window Manager" "Desktop UI" "Audio System" "Web Browser" "Terminal" "Music Player" "Gaming Platform" "Gaming Tools" "Streaming" "Development" "Media" "Package Manager" "Fonts" "Other"; do
            if [[ -n "${categories[$category]}" ]]; then
                echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${BLUE}📦 $category${NC}"
                echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${categories[$category]}" | head -c -2  # Remove last newline
            fi
        done
    else
        # Simple filtered output
        echo "$filtered_updates"
    fi
}

# Run with parameters
main "$@"