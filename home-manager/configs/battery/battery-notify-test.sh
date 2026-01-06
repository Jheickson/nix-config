#!/usr/bin/env bash
# Test script for battery notifications

echo "Testing battery notification system..."

# Check if battery exists
if [ -d "/sys/class/power_supply/BAT0" ]; then
    BATTERY_PATH="/sys/class/power_supply/BAT0"
elif [ -d "/sys/class/power_supply/BAT1" ]; then
    BATTERY_PATH="/sys/class/power_supply/BAT1"
else
    echo "No battery found!"
    exit 1
fi

echo "Battery found at: $BATTERY_PATH"

# Get current battery info
CAPACITY=$(cat "$BATTERY_PATH/capacity")
STATUS=$(cat "$BATTERY_PATH/status")

echo "Current battery level: $CAPACITY%"
echo "Current status: $STATUS"

# Test notifications
echo "Testing notifications..."

# Test low battery notification
notify-send -u normal -i "battery-low" "Battery Alert" "Test: Battery at ${CAPACITY}% - Consider plugging in charger"

sleep 2

# Test critical battery notification
notify-send -u critical -i "battery-caution" "Battery Alert" "Test: Battery at ${CAPACITY}% - Plug in charger immediately!"

sleep 2

# Test full battery notification
notify-send -u low -i "battery-full-charged" "Battery Alert" "Test: Battery fully charged at ${CAPACITY}% - Consider unplugging"

echo "Test notifications sent! Check your notification system."
