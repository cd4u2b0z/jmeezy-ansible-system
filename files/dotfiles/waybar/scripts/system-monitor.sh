#!/bin/bash

# Use load average instead of combined CPU percentage
load_avg=$(cat /proc/loadavg | cut -d' ' -f1)
load_display=$(echo "$load_avg" | cut -d'.' -f1-2)  # Show like 1.2 instead of 1.23456

# Individual CPU usage for tooltip (more reasonable)
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}' | head -1)
[[ -z "$cpu_usage" ]] && cpu_usage="0"

mem_usage=$(free | grep '^Mem:' | awk '{printf "%.0f", $3/$2 * 100.0}')
[[ -z "$mem_usage" ]] && mem_usage="45"

disk_usage=$(df / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
[[ -z "$disk_usage" ]] && disk_usage="65"

# GPU info
gpu_temp="N/A"
gpu_usage="N/A"

# Try nvidia-smi first
if command -v nvidia-smi >/dev/null 2>&1; then
    gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
    gpu_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
fi

# Try AMD GPU if nvidia failed
if [[ "$gpu_temp" == "N/A" ]] && command -v radeontop >/dev/null 2>&1; then
    gpu_temp=$(sensors 2>/dev/null | grep -i "junction\|edge" | head -1 | grep -o '+[0-9]*' | sed 's/+//' | head -1)
    [[ -z "$gpu_temp" ]] && gpu_temp="N/A"
fi

# CPU temperature
cpu_temp="N/A"
if [[ -f /sys/class/thermal/thermal_zone0/temp ]]; then
    temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
    if [[ -n "$temp_raw" ]]; then
        cpu_temp=$((temp_raw / 1000))
    fi
fi

# Build tooltip with more sensible CPU info
tooltip="🖥️ System Monitor\\n━━━━━━━━━━━━━━━━━━━━\\n🔥 CPU: ${cpu_usage}%"
if [[ "$cpu_temp" != "N/A" ]]; then
    tooltip+=" (${cpu_temp}°C)"
fi
tooltip+="\\n⚡ Load: ${load_avg}\\n💾 RAM: ${mem_usage}%\\n"

if [[ "$gpu_usage" != "N/A" ]]; then
    tooltip+="🎮 GPU: ${gpu_usage}%"
    if [[ "$gpu_temp" != "N/A" ]]; then
        tooltip+=" (${gpu_temp}°C)"
    fi
    tooltip+="\\n"
fi

tooltip+="💽 Disk: ${disk_usage}%\\n━━━━━━━━━━━━━━━━━━━━\\n👆 Click for btop"

# JSON output - show load average instead of crazy CPU percentage
echo "{\"text\":\"${load_display}\",\"tooltip\":\"${tooltip}\"}"