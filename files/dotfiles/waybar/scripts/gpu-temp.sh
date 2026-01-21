#!/bin/bash

# GPU temperature monitoring script for Waybar
# Works with both NVIDIA and AMD GPUs

get_gpu_temp() {
    # Try NVIDIA first
    if command -v nvidia-smi >/dev/null 2>&1; then
        temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
        if [[ $? -eq 0 && -n "$temp" ]]; then
            echo "$temp"
            return 0
        fi
    fi
    
    # Try AMD/Intel via hwmon
    for hwmon in /sys/class/hwmon/hwmon*/; do
        if [[ -f "$hwmon/name" ]]; then
            name=$(cat "$hwmon/name")
            if [[ "$name" =~ (amdgpu|radeon|i915) ]]; then
                if [[ -f "$hwmon/temp1_input" ]]; then
                    temp_millidegree=$(cat "$hwmon/temp1_input")
                    temp=$((temp_millidegree / 1000))
                    echo "$temp"
                    return 0
                fi
            fi
        fi
    done
    
    # Fallback - no GPU found
    echo "N/A"
    return 1
}

# Get temperature and create JSON output
temp=$(get_gpu_temp)

if [[ "$temp" =~ ^[0-9]+$ ]]; then
    # Determine temperature level for icon
    if [[ $temp -le 40 ]]; then
        level="cool"
    elif [[ $temp -le 60 ]]; then
        level="warm"
    elif [[ $temp -le 75 ]]; then
        level="hot"
    elif [[ $temp -le 85 ]]; then
        level="critical"
    else
        level="danger"
    fi
    
    echo "{\"text\":\"$temp\",\"alt\":\"$temp\",\"tooltip\":\"GPU Temperature: ${temp}°C\",\"class\":\"$level\"}"
else
    echo "{\"text\":\"N/A\",\"alt\":\"N/A\",\"tooltip\":\"GPU Temperature: Not Available\",\"class\":\"unknown\"}"
fi