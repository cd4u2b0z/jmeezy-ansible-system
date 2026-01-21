#!/usr/bin/env python3
"""
Dynamic Weather Script for Waybar
Location: Summerville, South Carolina
Uses OpenMeteo API with Nord-themed weather icons
"""

import json
import requests
import sys
from datetime import datetime

# Summerville, SC coordinates
LATITUDE = 32.4840
LONGITUDE = -80.1756

# Nord-themed weather mapping (monochrome symbols)
WEATHER_CODES = {
    0: "☀",    # Clear sky
    1: "🌤",   # Mainly clear
    2: "⛅",   # Partly cloudy  
    3: "☁",    # Overcast
    45: "🌫",  # Fog
    48: "🌫",  # Depositing rime fog
    51: "🌦",  # Light drizzle
    53: "🌦",  # Moderate drizzle
    55: "🌦",  # Dense drizzle
    56: "🌨",  # Light freezing drizzle
    57: "🌨",  # Dense freezing drizzle
    61: "🌧",  # Slight rain
    63: "🌧",  # Moderate rain
    65: "🌧",  # Heavy rain
    66: "🌨",  # Light freezing rain
    67: "🌨",  # Heavy freezing rain
    71: "❄",   # Slight snow fall
    73: "❄",   # Moderate snow fall
    75: "❄",   # Heavy snow fall
    77: "❄",   # Snow grains
    80: "🌦",  # Slight rain showers
    81: "🌦",  # Moderate rain showers
    82: "🌦",  # Violent rain showers
    85: "❄",   # Slight snow showers
    86: "❄",   # Heavy snow showers
    95: "⛈",   # Thunderstorm
    96: "⛈",   # Thunderstorm with slight hail
    99: "⛈"    # Thunderstorm with heavy hail
}

def get_weather():
    """Fetch weather data from OpenMeteo API"""
    try:
        url = f"https://api.open-meteo.com/v1/forecast"
        params = {
            "latitude": LATITUDE,
            "longitude": LONGITUDE,
            "current": ["temperature_2m", "weather_code", "wind_speed_10m"],
            "timezone": "America/New_York",
            "temperature_unit": "fahrenheit",
            "wind_speed_unit": "mph"
        }
        
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        current = data["current"]
        temp = round(current["temperature_2m"])
        weather_code = current["weather_code"]
        wind_speed = round(current["wind_speed_10m"])
        
        # Get weather icon
        icon = WEATHER_CODES.get(weather_code, "?")
        
        # Format output for Waybar
        return {
            "text": f"{icon} {temp}°F",
            "tooltip": f"Summerville, SC\nTemperature: {temp}°F\nWind: {wind_speed} mph\nUpdated: {datetime.now().strftime('%H:%M')}",
            "class": "weather"
        }
        
    except requests.exceptions.RequestException as e:
        return {
            "text": "☁ Weather unavailable",
            "tooltip": f"Failed to fetch weather: {str(e)}",
            "class": "weather-error"
        }
    except Exception as e:
        return {
            "text": "☁ Error",
            "tooltip": f"Weather error: {str(e)}",
            "class": "weather-error"
        }

if __name__ == "__main__":
    weather_data = get_weather()
    print(json.dumps(weather_data))