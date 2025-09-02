#!/usr/bin/env bash
# Test script for charger connection/disconnection notifications

echo "Testing charger notification system..."

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

# Test charger notifications
echo "Testing charger notifications..."

# Test charger connected notification (simulate charging status)
notify-send -u low -i "battery-full-charged" "Battery Alert" "Charger connected - Battery charging at ${CAPACITY}%"

sleep 3

# Test charger disconnected notification (simulate discharging status)
notify-send -u low -i "battery-low" "Battery Alert" "Charger disconnected - Battery discharging at ${CAPACITY}%"

echo "Test charger notifications sent! Check your notification system."
echo ""
echo "To test the actual implementation:"
echo "1. Apply the configuration with 'nixos-rebuild switch'"
echo "2. Start the battery monitor service: 'systemctl --user start battery-monitor'"
echo "3. Connect/disconnect your charger and watch for low-urgency notifications"
