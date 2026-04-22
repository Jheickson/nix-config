#!/usr/bin/env bash
# Test script for battery notifications: thresholds, charger sessions, ETA, progress bar.

set -euo pipefail

echo "Testing battery notification system..."

BATTERY_PATH=""
for p in /sys/class/power_supply/BAT*; do
    [[ -d "$p" ]] || continue
    BATTERY_PATH="$p"
    break
done

if [[ -z "$BATTERY_PATH" ]]; then
    echo "No battery found!"
    exit 1
fi

echo "Battery found at: $BATTERY_PATH"

CAPACITY=$(cat "$BATTERY_PATH/capacity")
STATUS=$(cat "$BATTERY_PATH/status")

echo "Current battery level: $CAPACITY%"
echo "Current status: $STATUS"

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

get_battery_icon() {
    local level="$1" status="$2"
    local bucket=$(( (level / 10) * 10 ))
    (( bucket > 100 )) && bucket=100
    if [[ "$status" == "Full" ]] || (( level >= 100 )); then
        echo "battery-level-100-charged-symbolic"
    elif [[ "$status" == "Charging" ]]; then
        echo "battery-level-${bucket}-charging-symbolic"
    else
        echo "battery-level-${bucket}-symbolic"
    fi
}

# category → synchronous hint (replaces prior notification in same category)
notify() {
    local category="$1" urgency="$2" icon="$3" level="$4" title="$5" message="$6"
    local timeout="${7:-10000}"
    notify-send \
        -u "$urgency" \
        -i "$icon" \
        -h "string:x-canonical-private-synchronous:$category" \
        -h "int:value:$level" \
        -t "$timeout" \
        "$title" "$message"
}

echo
echo "1. Threshold notifications (each replaces previous in 'battery-threshold' category)"
notify battery-threshold normal   "$(get_battery_icon 20 Discharging)" 20 \
    "Battery Low" "Battery at 20% - Consider plugging in"
sleep 2
notify battery-threshold critical "$(get_battery_icon 10 Discharging)" 10 \
    "Battery Low" "Battery at 10% - Plug in immediately" 0
sleep 2
notify battery-threshold critical "$(get_battery_icon 5 Discharging)"  5 \
    "Battery Critical" "Battery at 5% - Plug in now!" 0
sleep 2
notify battery-threshold low      "$(get_battery_icon 100 Full)"       100 \
    "Battery Charged" "Battery at 100% - Consider unplugging"
sleep 2

echo
echo "2. Charger connect (with discharge duration + ETA to full)"
DISCHARGE=$(format_duration $((2 * 3600 + 37 * 60)))
ETA_FULL=$(format_duration $((1 * 3600 + 12 * 60)))
notify battery-charger low "$(get_battery_icon "$CAPACITY" Charging)" "$CAPACITY" \
    "Battery" "Charger connected - Battery at ${CAPACITY}%
Went ${DISCHARGE} without a charge
~${ETA_FULL} until full"
sleep 3

echo "3. Charger disconnect (with time-to-full + ETA remaining)"
TO_FULL=$(format_duration $((1 * 3600 + 12 * 60)))
ETA_EMPTY=$(format_duration $((4 * 3600 + 18 * 60)))
notify battery-charger normal "$(get_battery_icon "$CAPACITY" Discharging)" "$CAPACITY" \
    "Battery" "Charger disconnected - Battery at ${CAPACITY}%
Took ${TO_FULL} to reach 100%
~${ETA_EMPTY} remaining"
sleep 3

echo "4. Sub-minute duration formatting"
SHORT=$(format_duration 45)
notify battery-charger low "$(get_battery_icon "$CAPACITY" Charging)" "$CAPACITY" \
    "Battery" "Charger connected - Battery at ${CAPACITY}%
Went ${SHORT} without a charge"

echo
echo "Done. Verify:"
echo "  - threshold toasts replace in place (no stacking)"
echo "  - charger toasts show progress bar + duration lines"
echo "  - critical toasts persist until dismissed (timeout 0)"
echo "  - end-to-end: 'systemctl --user restart battery-monitor' then plug/unplug"
