#!/bin/bash

# Enhanced Window Transparency Controller with Visual Feedback
# Shows transparency level with progress bar in notifications

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current window alpha value
get_current_alpha() {
    # Get the active window's alpha property
    hyprctl activewindow -j | jq -r '.alpha // 1.0' 2>/dev/null || echo "1.0"
}

# Create visual progress bar for transparency
create_progress_bar() {
    local percentage="$1"
    local bar_length=10
    local filled=$(( percentage * bar_length / 100 ))
    local empty=$(( bar_length - filled ))
    
    printf "["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "]"
}

# Set window alpha with bounds checking and enhanced feedback
set_alpha() {
    local new_alpha="$1"
    local change_type="$2"
    
    # Ensure alpha is between 0.1 and 1.0
    if (( $(echo "$new_alpha < 0.1" | bc -l) )); then
        new_alpha="0.1"
    elif (( $(echo "$new_alpha > 1.0" | bc -l) )); then
        new_alpha="1.0"
    fi
    
    # Apply the alpha to the active window
    hyprctl dispatch setprop active alpha "$new_alpha"
    
    # Calculate percentage and create visual feedback
    local percentage=$(echo "scale=0; $new_alpha * 100 / 1" | bc -l)
    local progress_bar=$(create_progress_bar "$percentage")
    
    # Determine icon and message based on transparency level
    local icon="🪟"
    local message="Window Opacity"
    local urgency="normal"
    
    if (( percentage >= 90 )); then
        icon="⬜"  # Nearly opaque
        message="Almost Opaque"
    elif (( percentage >= 70 )); then
        icon="🔲"  # Mostly opaque
        message="Mostly Opaque"
    elif (( percentage >= 50 )); then
        icon="⬜"  # Semi-transparent
        message="Semi-Transparent"
    elif (( percentage >= 30 )); then
        icon="🔳"  # Very transparent
        message="Very Transparent"
        urgency="low"
    else
        icon="👻"  # Almost invisible
        message="Nearly Invisible"
        urgency="low"
    fi
    
    # Show enhanced notification
    notify-send "$icon $message" "$progress_bar ${percentage}%" \
        -t 1500 \
        -u "$urgency" \
        -h string:x-canonical-private-synchronous:transparency \
        -h int:value:"$percentage"
    
    # Optional: Print to terminal for debugging
    echo -e "${BLUE}Window Transparency:${NC} $progress_bar ${percentage}% ($new_alpha alpha)"
}

# Get window information for context
get_window_info() {
    local window_class=$(hyprctl activewindow -j | jq -r '.class // "Unknown"')
    local window_title=$(hyprctl activewindow -j | jq -r '.title // "Unknown"' | cut -c1-30)
    echo "Active: $window_class - $window_title"
}

# Main function with enhanced options
case "$1" in
    "decrease"|"down"|"-")
        current=$(get_current_alpha)
        new_alpha=$(echo "scale=2; $current - 0.1" | bc -l)
        echo -e "${YELLOW}Decreasing transparency...${NC}"
        get_window_info
        set_alpha "$new_alpha" "decrease"
        ;;
    "increase"|"up"|"+")
        current=$(get_current_alpha)
        new_alpha=$(echo "scale=2; $current + 0.1" | bc -l)
        echo -e "${GREEN}Increasing transparency...${NC}"
        get_window_info
        set_alpha "$new_alpha" "increase"
        ;;
    "big-decrease"|"down5")
        current=$(get_current_alpha)
        new_alpha=$(echo "scale=2; $current - 0.2" | bc -l)
        echo -e "${YELLOW}Big decrease in transparency...${NC}"
        get_window_info
        set_alpha "$new_alpha" "big_decrease"
        ;;
    "big-increase"|"up5")
        current=$(get_current_alpha)
        new_alpha=$(echo "scale=2; $current + 0.2" | bc -l)
        echo -e "${GREEN}Big increase in transparency...${NC}"
        get_window_info
        set_alpha "$new_alpha" "big_increase"
        ;;
    "reset"|"1"|"opaque")
        echo -e "${BLUE}Resetting to fully opaque...${NC}"
        get_window_info
        set_alpha "1.0" "reset"
        ;;
    "half"|"0.5")
        echo -e "${BLUE}Setting to 50% opacity...${NC}"
        get_window_info
        set_alpha "0.5" "preset"
        ;;
    "quarter"|"0.25")
        echo -e "${BLUE}Setting to 25% opacity...${NC}"
        get_window_info
        set_alpha "0.25" "preset"
        ;;
    "status"|"info")
        current=$(get_current_alpha)
        percentage=$(echo "scale=0; $current * 100 / 1" | bc -l)
        progress_bar=$(create_progress_bar "$percentage")
        echo -e "${BLUE}Current Transparency:${NC} $progress_bar ${percentage}% ($current alpha)"
        get_window_info
        ;;
    *)
        echo -e "${RED}Usage:${NC} $0 {decrease|increase|big-decrease|big-increase|reset|half|quarter|status}"
        echo "  decrease/down/-      : Decrease opacity by 10%"
        echo "  increase/up/+        : Increase opacity by 10%"
        echo "  big-decrease/down5   : Decrease opacity by 20%"
        echo "  big-increase/up5     : Increase opacity by 20%"
        echo "  reset/1/opaque       : Reset to fully opaque"
        echo "  half/0.5             : Set to 50% opacity"
        echo "  quarter/0.25         : Set to 25% opacity"
        echo "  status/info          : Show current transparency status"
        exit 1
        ;;
esac