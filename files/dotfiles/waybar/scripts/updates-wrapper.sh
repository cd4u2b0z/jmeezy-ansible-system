#!/bin/bash

# Enhanced Updates Wrapper for Waybar
# Integrates with simple-update-manager-enhanced.sh for intelligent update descriptions

CACHE_DIR="/tmp/update-manager"
CACHE_DURATION=60 # 5 minutes (sync with enhanced script)
PACMAN_CACHE="$CACHE_DIR/pacman.cache"
AUR_CACHE="$CACHE_DIR/aur.cache"
FLATPAK_CACHE="$CACHE_DIR/flatpak.cache"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR" 2>/dev/null

# Colors for Waybar JSON output (Nord theme)
CRITICAL_COLOR="#BF616A"    # Nord Red
HIGH_COLOR="#D08770"        # Nord Orange  
MEDIUM_COLOR="#EBCB8B"      # Nord Yellow
LOW_COLOR="#A3BE8C"         # Nord Green
DEFAULT_COLOR="#D8DEE9"     # Nord Light Gray

# Function to check if cache is valid (sync with enhanced script)
is_cache_valid() {
    local cache_file="$1"
    [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $CACHE_DURATION ]]
}

# Function to check updates with intelligent prioritization
check_updates() {
    local pacman_count=0
    local aur_count=0
    local flatpak_count=0
    local critical_count=0
    local high_count=0
    local tooltip_text=""
    local primary_color="$DEFAULT_COLOR"
    
    # Check pacman updates (use shared cache)
    if command -v pacman >/dev/null 2>&1; then
        local pacman_updates
        if is_cache_valid "$PACMAN_CACHE"; then
            pacman_updates=$(cat "$PACMAN_CACHE" 2>/dev/null)
        else
            # Run checkupdates in background for faster response
            pacman_updates=$(timeout 10 pacman -Qu 2>/dev/null)
            echo "$pacman_updates" > "$PACMAN_CACHE" 2>/dev/null || true
        fi
        if [[ -n "$pacman_updates" ]]; then
            pacman_count=$(echo "$pacman_updates" | wc -l)
            tooltip_text+="Pacman Updates ($pacman_count):\\n"
            
            while IFS= read -r line; do
                local pkg_name=$(echo "$line" | cut -d' ' -f1)
                local pkg_info="$line"
                
                # Count critical and high priority packages
                case "$pkg_name" in
                    systemd*|glibc*|openssl*|gnupg*|pacman*|archlinux-keyring*)
                        ((critical_count++))
                        primary_color="$CRITICAL_COLOR"
                        tooltip_text+="  $pkg_info\\n"
                        ;;
                    firefox*|brave*|chromium*|nvidia*|mesa*|vulkan*|lib32-vulkan*)
                        ((high_count++))
                        [[ "$primary_color" != "$CRITICAL_COLOR" ]] && primary_color="$HIGH_COLOR"
                        tooltip_text+="  $pkg_info\\n"
                        ;;
                    steam*|lutris*|wine*|dxvk*|gamemode*|mangohud*|heroic*|bottles*)
                        [[ "$primary_color" == "$DEFAULT_COLOR" ]] && primary_color="$MEDIUM_COLOR"
                        tooltip_text+="  $pkg_info (Gaming)\\n"
                        ;;
                    *)
                        tooltip_text+="  $pkg_info\\n"
                        ;;
                esac
            done <<< "$pacman_updates"
        fi
    fi
    
    # Check AUR updates (use shared cache)
    if command -v yay >/dev/null 2>&1; then
        local aur_updates
        if is_cache_valid "$AUR_CACHE"; then
            aur_updates=$(cat "$AUR_CACHE" 2>/dev/null)
        else
            # Reduced timeout for better responsiveness
            aur_updates=$(timeout 30 yay -Qu --aur 2>/dev/null)
            echo "$aur_updates" > "$AUR_CACHE" 2>/dev/null || true
        fi
        if [[ -n "$aur_updates" ]]; then
            aur_count=$(echo "$aur_updates" | wc -l)
            tooltip_text+="\\nAUR Updates ($aur_count):\\n"
            
            while IFS= read -r line; do
                local pkg_name=$(echo "$line" | cut -d' ' -f1)
                tooltip_text+="📦 $line\\n"
                
                # Gaming-related AUR packages get medium priority
                case "$pkg_name" in
                    *gaming*|*wine*|*proton*|*steam*|heroic*|bottles*)
                        [[ "$primary_color" == "$DEFAULT_COLOR" ]] && primary_color="$MEDIUM_COLOR"
                        ;;
                esac
            done <<< "$aur_updates"
        fi
    fi
    
    # Check flatpak updates
    if command -v flatpak >/dev/null 2>&1; then
        local flatpak_updates
        if is_cache_valid "$FLATPAK_CACHE"; then
            flatpak_updates=$(cat "$FLATPAK_CACHE" 2>/dev/null)
        else
            # Check for flatpak updates
            flatpak_updates=$(timeout 15 flatpak remote-ls --updates 2>/dev/null)
            echo "$flatpak_updates" > "$FLATPAK_CACHE" 2>/dev/null || true
        fi
        if [[ -n "$flatpak_updates" ]]; then
            flatpak_count=$(echo "$flatpak_updates" | wc -l)
            tooltip_text+="\\nFlatpak Updates ($flatpak_count):\\n"
            
            while IFS= read -r line; do
                local app_name=$(echo "$line" | awk '{print $1}')
                tooltip_text+="📱 $app_name\\n"
                
                # Gaming-related flatpaks get medium priority
                case "$app_name" in
                    *dolphin*|*emulator*|*retroarch*|*steam*|*gaming*)
                        [[ "$primary_color" == "$DEFAULT_COLOR" ]] && primary_color="$MEDIUM_COLOR"
                        ;;
                esac
            done <<< "$flatpak_updates"
        fi
    fi
    
    # Calculate total and create output
    local total_count=$((pacman_count + aur_count + flatpak_count))
    
    if [[ $total_count -eq 0 ]]; then
        echo "{\"text\": \"󰏖\", \"tooltip\": \"System is up to date\nClick to open update manager\", \"class\": \"updated\", \"color\": \"$LOW_COLOR\"}"
    else
        # Limit tooltip length for performance with large update lists
        if [[ ${#tooltip_text} -gt 2000 ]]; then
            tooltip_text="${tooltip_text:0:1900}\\n... (truncated for performance)"
        fi
        local text_icon="󰏔"
        local priority_info=""
        
        # Add priority indicators (restore original functionality)
        if [[ $critical_count -gt 0 ]]; then
            priority_info+="  $critical_count"
        fi
        if [[ $high_count -gt 0 ]]; then
            priority_info+="  $high_count"
        fi
        
        # Add helpful tooltip
        tooltip_text+="\\n\\n  Priority Levels:"
        tooltip_text+="\\n  Critical (Security/System)"
        tooltip_text+="\\n  High (Browsers/Drivers/RTX)"  
        tooltip_text+="\\n  Medium (Gaming/Development)"
        tooltip_text+="\\n  Low (Fonts/Misc)"
        tooltip_text+="\\n\\nClick to open intelligent update manager"
        
        echo "{\"text\": \"$text_icon $total_count$priority_info\", \"tooltip\": \"$tooltip_text\", \"class\": \"updates-available\", \"color\": \"$primary_color\"}"
    fi
}

# Main execution
main() {
    # Clear old cache files (garbage collection)
    find /tmp -name "waybar_updates_*" -mmin +60 -delete 2>/dev/null
    
    # If cache is older than 10 minutes, force refresh to avoid stale data
    if [[ -f "$PACMAN_CACHE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$PACMAN_CACHE"))) -gt 600 ]]; then
        rm -f "$PACMAN_CACHE" "$AUR_CACHE"
    fi
    
    # Generate new update info
    local result
    result=$(check_updates)
    
    # Output result
    echo "$result"
}

# Handle refresh signals
if [[ "$1" == "--refresh" ]]; then
    rm -f "$PACMAN_CACHE" "$AUR_CACHE"
fi

main
