#!/usr/bin/env bash
# Test script for battery notifications, including charger session durations

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

CAPACITY=$(cat "$BATTERY_PATH/capacity")
STATUS=$(cat "$BATTERY_PATH/status")

echo "Current battery level: $CAPACITY%"
echo "Current status: $STATUS"

# Duration formatter mirroring battery-notify.nix
format_duration() {
    local seconds="$1"
    if (( seconds < 60 )); then
        echo "${seconds}s"
    elif (( seconds < 3600 )); then
        printf '%dm %ds' $((seconds / 60)) $((seconds % 60))
    else
        printf '%dh %dm' $((seconds / 3600)) $(((seconds % 3600) / 60))
    fi
}

echo
echo "Testing threshold notifications..."

notify-send -u normal -i "battery-low" "Battery Alert" \
    "Test: Battery at ${CAPACITY}% - Consider plugging in charger"
sleep 2

notify-send -u critical -i "battery-caution" "Battery Alert" \
    "Test: Battery at ${CAPACITY}% - Plug in charger immediately!"
sleep 2

notify-send -u low -i "battery-full-charged" "Battery Alert" \
    "Test: Battery fully charged at ${CAPACITY}% - Consider unplugging"
sleep 2

echo
echo "Testing charger connect notification (with discharge duration)..."
DISCHARGE_SECONDS=$((2 * 3600 + 37 * 60))  # simulate 2h 37m off charger
CONNECT_DURATION=$(format_duration "$DISCHARGE_SECONDS")
notify-send -u low -i "battery-full-charged" "Battery Alert" \
    "Charger connected - Battery charging at ${CAPACITY}%
Went ${CONNECT_DURATION} without a charge"
sleep 3

echo "Testing charger disconnect notification (with time-to-full)..."
CHARGE_SECONDS=$((1 * 3600 + 12 * 60))  # simulate 1h 12m to reach 100%
DISCONNECT_DURATION=$(format_duration "$CHARGE_SECONDS")
notify-send -u normal -i "battery-caution" "Battery Alert" \
    "Charger disconnected - Battery discharging at ${CAPACITY}%
Took ${DISCONNECT_DURATION} to reach 100%"
sleep 3

echo "Testing sub-minute duration formatting..."
SHORT_DURATION=$(format_duration 45)
notify-send -u low -i "battery-full-charged" "Battery Alert" \
    "Charger connected - Battery charging at ${CAPACITY}%
Went ${SHORT_DURATION} without a charge"

echo
echo "Test notifications sent! Check your notification system."
echo "For end-to-end verification, plug/unplug the charger with battery-monitor running."
