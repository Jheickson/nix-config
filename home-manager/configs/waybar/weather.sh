#!/usr/bin/env bash

# Weather script for waybar using wttr.in
# Displays temperature in Celsius and weather condition

# Cache file to avoid excessive API calls
CACHE_FILE="/tmp/waybar_weather_cache"
CACHE_DURATION=1800  # 30 minutes in seconds

# Location - you can change this to your city
LOCATION="santarem-pa"

# Function to fetch weather data
fetch_weather() {
    local url
    if [ -n "$LOCATION" ]; then
        url="https://wttr.in/${LOCATION}?format=%t+%c"
    else
        url="https://wttr.in/?format=%t+%c"
    fi
    
    # Try to fetch weather data
    local weather_data
    weather_data=$(curl -s --max-time 5 "$url" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$weather_data" ]; then
        # Parse temperature and condition
        local temp=$(echo "$weather_data" | cut -d' ' -f1)
        local condition=$(echo "$weather_data" | cut -d' ' -f2-)
        
        # Save to cache
        echo "{\"temp\":\"$temp\",\"condition\":\"$condition\",\"timestamp\":$(date +%s)}" > "$CACHE_FILE"
        echo "$temp|$condition"
    else
        # Return cached data if available and not expired
        if [ -f "$CACHE_FILE" ]; then
            local cached_data=$(cat "$CACHE_FILE")
            local cached_temp=$(echo "$cached_data" | sed 's/.*"temp":"\([^"]*\)".*/\1/')
            local cached_condition=$(echo "$cached_data" | sed 's/.*"condition":"\([^"]*\)".*/\1/')
            local cached_timestamp=$(echo "$cached_data" | sed 's/.*"timestamp":\([0-9]*\).*/\1/')
            
            local current_timestamp=$(date +%s)
            local age=$((current_timestamp - cached_timestamp))
            
            if [ $age -lt $CACHE_DURATION ]; then
                echo "$cached_temp|$cached_condition"
                return 0
            fi
        fi
        
        # Fallback if no cache or cache expired
        echo "--|No data"
    fi
}

# Function to get weather icon based on condition
get_weather_icon() {
    local condition="$1"
    
    # If condition is already an emoji, use it directly
    if [[ "$condition" =~ [☀⛅☁🌧⛈❄🌫] ]]; then
        echo "$condition"
    else
        # Handle text conditions
        condition=$(echo "$condition" | tr '[:upper:]' '[:lower:]')
        case "$condition" in
            *"sunny"*|*"clear"*) echo "☀️" ;;
            *"partly cloudy"*|*"few clouds"*|*"partly"*) echo "⛅" ;;
            *"cloudy"*|*"overcast"*|*"clouds"*) echo "☁️" ;;
            *"rain"*|*"drizzle"*|*"shower"*) echo "🌧️" ;;
            *"thunderstorm"*|*"storm"*) echo "⛈️" ;;
            *"snow"*|*"sleet"*) echo "❄️" ;;
            *"mist"*|*"fog"*|*"haze"*) echo "🌫️" ;;
            *) echo "🌡️" ;;
        esac
    fi
}

# Main execution
weather_data=$(fetch_weather)
IFS='|' read -r temperature condition <<< "$weather_data"

# Clean up condition text
condition=$(echo "$condition" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

# Format output for waybar
icon=$(get_weather_icon "$condition")

# Output JSON for waybar with icon before temperature
echo "{\"text\":\"$icon $temperature\", \"tooltip\":\"$condition\", \"class\":\"weather\"}"
