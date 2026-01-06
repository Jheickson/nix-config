{ config, pkgs, ... }:

let
  batteryScript = pkgs.writeShellScriptBin "battery-monitor" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Battery monitoring script with priority notifications and charger event detection
    # Monitors battery level and sends notifications at specific thresholds
    # Also detects charger connection/disconnection events

    # Configuration
    readonly NOTIFICATION_ICON_PREFIX="battery"
    readonly NOTIFICATION_TIMEOUT=10000
    readonly CHECK_INTERVAL=30
    readonly DEBOUNCE_THRESHOLD=5  # Minimum time between similar notifications (seconds)
    readonly BATTERY_THRESHOLDS=(20 10 5)  # Warn at 20%, 10%, 5%

    # Get battery info
    get_battery_info() {
        local battery_path="/sys/class/power_supply/BAT0"
        [[ -d "$battery_path" ]] || battery_path="/sys/class/power_supply/BAT1"
        
        if [[ ! -d "$battery_path" ]]; then
            echo "No battery found" >&2
            return 1
        fi
        
        echo "$battery_path"
    }

    # Get current battery percentage (with whitespace trimming)
    get_battery_percentage() {
        local battery_path="$1"
        cat "$battery_path/capacity" 2>/dev/null | tr -d ' \n' || echo "0"
    }

    # Get charging status
    get_charging_status() {
        local battery_path="$1"
        cat "$battery_path/status" 2>/dev/null | tr -d ' \n' || echo "Unknown"
    }

    # Send notification with appropriate urgency
    send_notification() {
        local urgency="$1"
        local icon="$2"
        local message="$3"
        
        ${pkgs.libnotify}/bin/notify-send \
            -u "$urgency" \
            -i "$icon" \
            "Battery Alert" \
            "$message" \
            -t "$NOTIFICATION_TIMEOUT"
    }

    # Send charger-specific notification
    send_charger_notification() {
        local event="$1"
        local battery_level="$2"
        
        local icon=""
        local message=""
        local urgency="low"
        
        case "$event" in
            Charging)
                icon="battery-full-charged"
                message="Charger connected - Battery charging at $battery_level%"
                ;;
            Discharging)
                icon="battery-caution"
                message="Charger disconnected - Battery discharging at $battery_level%"
                urgency="normal"
                ;;
            *)
                return 0
                ;;
        esac
        
        send_notification "$urgency" "$icon" "$message"
    }

    # Main monitoring function
    monitor_battery() {
        local battery_path
        battery_path=$(get_battery_info) || return 1
        
        # Tracking last notification times
        local last_notified_20=0
        local last_notified_10=0
        local last_notified_5=0
        local last_notified_full=0
        local last_charger_state=""
        local last_charger_notification=0
        
        while true; do
            local current_level
            local charging_status
            local current_time
            
            current_level=$(get_battery_percentage "$battery_path")
            charging_status=$(get_charging_status "$battery_path")
            current_time=$(date +%s)
            
            # Validate battery level is numeric
            if ! [[ "$current_level" =~ ^[0-9]+$ ]]; then
                sleep "$CHECK_INTERVAL"
                continue
            fi
            
            # Monitor charger state changes with debouncing
            if [[ "$charging_status" != "$last_charger_state" ]]; then
                if [[ $((current_time - last_charger_notification)) -gt "$DEBOUNCE_THRESHOLD" ]]; then
                    send_charger_notification "$charging_status" "$current_level"
                    last_charger_notification=$current_time
                    last_charger_state="$charging_status"
                fi
            fi
            
            # Low battery notifications (only when discharging)
            if [[ "$charging_status" == "Discharging" ]]; then
                # 20% warning
                if [[ $current_level -le 20 && $current_level -gt 10 ]] && \
                   [[ $((current_time - last_notified_20)) -gt 300 ]]; then
                    send_notification "normal" "battery-low" \
                        "Battery at $current_level% - Consider plugging in charger"
                    last_notified_20=$current_time
                fi
                
                # 10% warning
                if [[ $current_level -le 10 && $current_level -gt 5 ]] && \
                   [[ $((current_time - last_notified_10)) -gt 300 ]]; then
                    send_notification "critical" "battery-caution" \
                        "Battery at $current_level% - Plug in charger immediately!"
                    last_notified_10=$current_time
                fi
                
                # 5% critical
                if [[ $current_level -le 5 ]] && \
                   [[ $((current_time - last_notified_5)) -gt 300 ]]; then
                    send_notification "critical" "battery-empty" \
                        "Battery at $current_level% - Critical! Plug in now!"
                    last_notified_5=$current_time
                fi
                
                # Reset full notification when discharging
                last_notified_full=0
                
            # Full battery notification (only when charging and above 97%)
            elif [[ "$charging_status" == "Charging" ]] || [[ "$charging_status" == "Full" ]]; then
                if [[ $current_level -ge 97 ]] && \
                   [[ $((current_time - last_notified_full)) -gt 300 ]]; then
                    send_notification "low" "battery-full-charged" \
                        "Battery fully charged at $current_level% - Consider unplugging"
                    last_notified_full=$current_time
                fi
                
                # Reset low notifications when charging
                last_notified_20=0
                last_notified_10=0
                last_notified_5=0
            fi
            
            sleep "$CHECK_INTERVAL"
        done
    }

    # Start monitoring
    monitor_battery
  '';
in
{
  # Install the battery monitoring script
  home.packages = [ batteryScript ];

  # Create systemd user service for battery monitoring
  systemd.user.services.battery-monitor = {
    Unit = {
      Description = "Battery Level Monitor with Notifications";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${batteryScript}/bin/battery-monitor";
      Restart = "always";
      RestartSec = "10";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Ensure the service starts with the graphical session
  systemd.user.startServices = true;
}
