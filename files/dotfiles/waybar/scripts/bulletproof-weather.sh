#!/bin/bash

# 🌤️ Bulletproof Weather Script with OpenWeatherMap API
# Primary: OpenWeatherMap API, Fallback: wttr.in

CACHE_FILE="/tmp/waybar_weather"
API_KEY="69def8ba31d3be7da6226b6d51b2b655"
CITY_ID="4597040"  # Summerville, SC
ZIP_CODE="29465"
MAX_CACHE_AGE=900  # 15 minutes (more frequent updates with API)

# Check cache first
if [[ -f "$CACHE_FILE" ]]; then
    cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [[ $cache_age -lt $MAX_CACHE_AGE ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Method 1: OpenWeatherMap API (most reliable)
get_openweather() {
    local response
    response=$(timeout 8 curl -s --max-time 6 \
        "https://api.openweathermap.org/data/2.5/weather?id=${CITY_ID}&appid=${API_KEY}&units=metric" 2>/dev/null)
    
    if [[ $? -eq 0 && -n "$response" ]]; then
        # Parse JSON response
        local temp=$(echo "$response" | jq -r '.main.temp // empty' 2>/dev/null)
        local desc=$(echo "$response" | jq -r '.weather[0].description // empty' 2>/dev/null)
        
        if [[ -n "$temp" && "$temp" != "null" && "$temp" != "empty" ]]; then
            # Format temperature and capitalize description
            local temp_int=$(printf "%.0f" "$temp" 2>/dev/null)
            local desc_cap=$(echo "$desc" | sed 's/\b\w/\U&/g' 2>/dev/null)
            echo "${temp_int}°C ${desc_cap}"
            return 0
        fi
    fi
    return 1
}

# Method 2: OpenWeatherMap by ZIP (backup API call)
get_openweather_zip() {
    local response
    response=$(timeout 8 curl -s --max-time 6 \
        "https://api.openweathermap.org/data/2.5/weather?zip=${ZIP_CODE},US&appid=${API_KEY}&units=metric" 2>/dev/null)
    
    if [[ $? -eq 0 && -n "$response" ]]; then
        local temp=$(echo "$response" | jq -r '.main.temp // empty' 2>/dev/null)
        if [[ -n "$temp" && "$temp" != "null" ]]; then
            local temp_int=$(printf "%.0f" "$temp" 2>/dev/null)
            echo "${temp_int}°C"
            return 0
        fi
    fi
    return 1
}

# Method 3: wttr.in fallback
get_wttr_weather() {
    timeout 6 curl -s --max-time 5 "wttr.in/${ZIP_CODE}?format=%t&m" 2>/dev/null | \
    grep -E '^[+-]?[0-9]+°C' | head -1
}

# Try all methods in order - API first, then fallbacks
weather=""

# Primary: OpenWeatherMap API with city ID
weather=$(get_openweather)
if [[ -n "$weather" ]]; then
    echo "$weather" > "$CACHE_FILE"
    echo "$weather"
    exit 0
fi

# Backup 1: OpenWeatherMap API with ZIP code
weather=$(get_openweather_zip)
if [[ -n "$weather" ]]; then
    echo "$weather" > "$CACHE_FILE"
    echo "$weather"
    exit 0
fi

# Backup 2: wttr.in fallback
weather=$(get_wttr_weather)
if [[ -n "$weather" ]]; then
    echo "$weather" > "$CACHE_FILE"
    echo "$weather"
    exit 0
fi

# Final fallback: cached result or error indicator
if [[ -f "$CACHE_FILE" && -s "$CACHE_FILE" ]]; then
    echo "🕐 $(cat "$CACHE_FILE")"  # Prefix with clock to show it's cached
else
    echo "🌡️ --°C Weather Unavailable"
fi