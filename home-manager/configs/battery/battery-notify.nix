{ config, pkgs, ... }:

let
  batteryScript = pkgs.writeShellScriptBin "battery-monitor" ''
    #!/usr/bin/env bash

    # Battery monitoring script with priority notifications and charger event detection
    # Monitors battery level and sends notifications at specific thresholds
    # Also detects charger connection/disconnection events

    # Get battery info
    get_battery_info() {
        local battery_path="/sys/class/power_supply/BAT0"
        if [ ! -d "$battery_path" ]; then
            battery_path="/sys/class/power_supply/BAT1"
        fi
        
        if [ ! -d "$battery_path" ]; then
            echo "No battery found" >&2
            exit 1
        fi
        
        echo "$battery_path"
    }

    # Get current battery percentage
    get_battery_percentage() {
        local battery_path="$1"
        cat "$battery_path/capacity" 2>/dev/null || echo "0"
    }

    # Get charging status
    get_charging_status() {
        local battery_path="$1"
        cat "$battery_path/status" 2>/dev/null || echo "Unknown"
    }

    # Send notification with appropriate urgency
    send_notification() {
        local level="$1"
        local status="$2"
        local urgency="$3"
        local icon="$4"
        local message="$5"
        
        # Use notify-send with urgency
        ${pkgs.libnotify}/bin/notify-send \
            -u "$urgency" \
            -i "$icon" \
            "Battery Alert" \
            "$message" \
            -t 10000
    }

    # Send charger-specific notification
    send_charger_notification() {
        local event="$1"
        local battery_level="$2"
        local urgency="low"
        
        local icon=""
        local message=""
        
        if [[ "$event" == "Charging" ]]; then
            icon="battery-full-charged"
            message="Charger connected - Battery charging at $battery_level%"
        elif [[ "$event" == "Discharging" ]]; then
            icon="battery-low"
            message="Charger disconnected - Battery discharging at $battery_level%"
        fi
        
        if [[ -n "$icon" && -n "$message" ]]; then
            send_notification "$battery_level" "ChargerEvent" "$urgency" "$icon" "$message"
        fi
    }

    # Main monitoring function
    monitor_battery() {
        local battery_path
        battery_path=$(get_battery_info)
        
        local last_level=0
        local last_notified_20=0
        local last_notified_10=0
        local last_notified_5=0
        local last_notified_full=0
        local last_charger_state=""
        local last_charger_notification=0
        
        while true; do
            local current_level
            current_level=$(get_battery_percentage "$battery_path")
            
            local charging_status
            charging_status=$(get_charging_status "$battery_path")
            
            # Check if we have valid data
            if [[ "$current_level" =~ ^[0-9]+$ ]]; then
                local current_time=$(date +%s)
                
                # Monitor charger state changes
                if [[ "$charging_status" != "$last_charger_state" ]]; then
                    # Check if we haven't sent a charger notification recently (debounce)
                    if [[ $((current_time - last_charger_notification)) -gt 30 ]]; then
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
                        send_notification "$current_level" "$charging_status" \
                            "normal" "battery-low" \
                            "Battery at 20% - Consider plugging in charger"
                        last_notified_20=$current_time
                    fi
                    
                    # 10% warning
                    if [[ $current_level -le 10 && $current_level -gt 5 ]] && \
                       [[ $((current_time - last_notified_10)) -gt 300 ]]; then
                        send_notification "$current_level" "$charging_status" \
                            "critical" "battery-caution" \
                            "Battery at 10% - Plug in charger immediately!"
                        last_notified_10=$current_time
                    fi
                    
                    # 5% critical
                    if [[ $current_level -le 5 ]] && \
                       [[ $((current_time - last_notified_5)) -gt 300 ]]; then
                        send_notification "$current_level" "$charging_status" \
                            "critical" "battery-empty" \
                            "Battery at 5% - Critical! Plug in now!"
                        last_notified_5=$current_time
                    fi
                    
                    # Reset full notification when discharging
                    last_notified_full=0
                    
                # Full battery notification (only when charging and above 97%)
                elif [[ "$charging_status" == "Charging" ]] || [[ "$charging_status" == "Full" ]]; then
                    if [[ $current_level -ge 97 ]] && \
                       [[ $((current_time - last_notified_full)) -gt 300 ]]; then
                        send_notification "$current_level" "$charging_status" \
                            "low" "battery-full-charged" \
                            "Battery fully charged at $current_level% - Consider unplugging"
                        last_notified_full=$current_time
                    fi
                    
                    # Reset low notifications when charging
                    last_notified_20=0
                    last_notified_10=0
                    last_notified_5=0
                fi
                
                last_level=$current_level
            fi
            
            # Check every 30 seconds
            sleep 30
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
