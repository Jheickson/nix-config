{ pkgs, ... }:

let
  batteryScript = pkgs.writeShellScriptBin "battery-monitor" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Battery monitor: event-driven via upower, with threshold + charger session notifications.

    readonly NOTIFICATION_TIMEOUT=10000
    readonly POLL_INTERVAL=60            # fallback poll when upower unavailable
    readonly SAFETY_POLL_INTERVAL=120    # re-check even while upower is quiet
    readonly DEBOUNCE_THRESHOLD=5
    readonly THRESHOLD_COOLDOWN=300

    STATE_FILE="''${XDG_RUNTIME_DIR:-/tmp}/battery-monitor.state"

    # --- battery path discovery (globbed) ---
    get_battery_path() {
        local p
        for p in /sys/class/power_supply/BAT*; do
            [[ -d "$p" ]] || continue
            echo "$p"
            return 0
        done
        return 1
    }

    read_file() { cat "$1" 2>/dev/null | tr -d ' \n' || echo ""; }

    # --- duration formatter ---
    format_duration() {
        local seconds="$1"
        (( seconds < 0 )) && seconds=0
        if (( seconds < 60 )); then
            echo "''${seconds}s"
        elif (( seconds < 3600 )); then
            printf '%dm %ds' $((seconds / 60)) $((seconds % 60))
        else
            printf '%dh %dm' $((seconds / 3600)) $(((seconds % 3600) / 60))
        fi
    }

    # --- ETA from energy/power sysfs ---
    get_eta() {
        local path="$1" status="$2"
        local now_v full_v rate_v
        now_v=$(read_file "$path/energy_now")
        full_v=$(read_file "$path/energy_full")
        rate_v=$(read_file "$path/power_now")
        if [[ -z "$now_v" || -z "$rate_v" ]]; then
            now_v=$(read_file "$path/charge_now")
            full_v=$(read_file "$path/charge_full")
            rate_v=$(read_file "$path/current_now")
        fi
        [[ "$now_v" =~ ^[0-9]+$ && "$rate_v" =~ ^[0-9]+$ && "$full_v" =~ ^[0-9]+$ ]] || { echo ""; return; }
        (( rate_v > 0 )) || { echo ""; return; }
        local seconds
        case "$status" in
            Charging)     seconds=$(( (full_v - now_v) * 3600 / rate_v )) ;;
            Discharging)  seconds=$(( now_v * 3600 / rate_v )) ;;
            *) echo ""; return ;;
        esac
        (( seconds > 30 )) || { echo ""; return; }
        format_duration "$seconds"
    }

    # --- level-aware icon ---
    get_battery_icon() {
        local level="$1" status="$2"
        local bucket=$(( (level / 10) * 10 ))
        (( bucket > 100 )) && bucket=100
        if [[ "$status" == "Full" ]] || (( level >= 100 )); then
            echo "battery-level-100-charged-symbolic"
        elif [[ "$status" == "Charging" ]]; then
            echo "battery-level-''${bucket}-charging-symbolic"
        else
            echo "battery-level-''${bucket}-symbolic"
        fi
    }

    # --- notification sender ---
    # Args: category urgency icon level title message [timeout]
    # category groups notifications for replace-in-place via synchronous hint.
    send_notification() {
        local category="$1" urgency="$2" icon="$3" level="$4" title="$5" message="$6"
        local timeout="''${7:-$NOTIFICATION_TIMEOUT}"
        ${pkgs.libnotify}/bin/notify-send \
            -u "$urgency" \
            -i "$icon" \
            -h "string:x-canonical-private-synchronous:$category" \
            -h "int:value:$level" \
            -t "$timeout" \
            "$title" "$message"
    }

    # --- state persistence ---
    load_state() {
        DISCHARGE_START=0
        CHARGE_START=0
        TIME_TO_FULL=""
        LAST_CHARGER_STATE=""
        LAST_CHARGER_NOTIFICATION=0
        LAST_NOTIFIED_20=0
        LAST_NOTIFIED_10=0
        LAST_NOTIFIED_5=0
        HAS_NOTIFIED_FULL=false
        # shellcheck disable=SC1090
        [[ -f "$STATE_FILE" ]] && source "$STATE_FILE" || true
    }

    save_state() {
        local tmp="$STATE_FILE.tmp"
        {
            echo "DISCHARGE_START=$DISCHARGE_START"
            echo "CHARGE_START=$CHARGE_START"
            echo "TIME_TO_FULL=\"$TIME_TO_FULL\""
            echo "LAST_CHARGER_STATE=\"$LAST_CHARGER_STATE\""
            echo "LAST_CHARGER_NOTIFICATION=$LAST_CHARGER_NOTIFICATION"
            echo "LAST_NOTIFIED_20=$LAST_NOTIFIED_20"
            echo "LAST_NOTIFIED_10=$LAST_NOTIFIED_10"
            echo "LAST_NOTIFIED_5=$LAST_NOTIFIED_5"
            echo "HAS_NOTIFIED_FULL=$HAS_NOTIFIED_FULL"
        } > "$tmp"
        mv -f "$tmp" "$STATE_FILE"
    }

    # --- charger event notification ---
    send_charger_notification() {
        local event="$1" level="$2" extra="$3" eta="$4"
        local icon message urgency="low" timeout="$NOTIFICATION_TIMEOUT"
        icon=$(get_battery_icon "$level" "$event")
        case "$event" in
            Charging)
                message="Charger connected - Battery at ''${level}%"
                [[ -n "$extra" ]] && message+=$'\n'"Went $extra without a charge"
                [[ -n "$eta"   ]] && message+=$'\n'"~$eta until full"
                ;;
            Discharging)
                urgency="normal"
                message="Charger disconnected - Battery at ''${level}%"
                [[ -n "$extra" ]] && message+=$'\n'"Took $extra to reach 100%"
                [[ -n "$eta"   ]] && message+=$'\n'"~$eta remaining"
                ;;
            *) return 0 ;;
        esac
        send_notification "battery-charger" "$urgency" "$icon" "$level" "Battery" "$message" "$timeout"
    }

    # --- main check, idempotent; safe to call on every event ---
    check_battery() {
        local path level status now eta
        path=$(get_battery_path) || return 0
        level=$(read_file "$path/capacity")
        status=$(read_file "$path/status")
        now=$(date +%s)
        [[ "$level" =~ ^[0-9]+$ ]] || return 0

        # charger state transition
        if [[ -n "$status" && "$status" != "$LAST_CHARGER_STATE" ]]; then
            if (( now - LAST_CHARGER_NOTIFICATION > DEBOUNCE_THRESHOLD )); then
                local extra=""
                case "$status" in
                    Charging)
                        (( DISCHARGE_START > 0 )) && extra=$(format_duration $((now - DISCHARGE_START)))
                        CHARGE_START=$now
                        TIME_TO_FULL=""
                        ;;
                    Discharging)
                        extra="$TIME_TO_FULL"
                        DISCHARGE_START=$now
                        CHARGE_START=0
                        ;;
                esac
                eta=$(get_eta "$path" "$status")
                send_charger_notification "$status" "$level" "$extra" "$eta"
                LAST_CHARGER_NOTIFICATION=$now
                LAST_CHARGER_STATE="$status"
            fi
        fi

        # record time-to-full on first hit this charge cycle
        if [[ "$status" == "Charging" || "$status" == "Full" ]]; then
            if (( level >= 100 )) && [[ -z "$TIME_TO_FULL" ]] && (( CHARGE_START > 0 )); then
                TIME_TO_FULL=$(format_duration $((now - CHARGE_START)))
            fi
        fi

        # threshold notifications
        local icon
        if [[ "$status" == "Discharging" ]]; then
            icon=$(get_battery_icon "$level" "$status")

            if (( level <= 5 )) && (( now - LAST_NOTIFIED_5 > THRESHOLD_COOLDOWN )); then
                send_notification "battery-threshold" "critical" "$icon" "$level" \
                    "Battery Critical" "Battery at ''${level}% - Plug in now!" 0
                LAST_NOTIFIED_5=$now
            elif (( level <= 10 )) && (( level > 5 )) && (( now - LAST_NOTIFIED_10 > THRESHOLD_COOLDOWN )); then
                send_notification "battery-threshold" "critical" "$icon" "$level" \
                    "Battery Low" "Battery at ''${level}% - Plug in immediately" 0
                LAST_NOTIFIED_10=$now
            elif (( level <= 20 )) && (( level > 10 )) && (( now - LAST_NOTIFIED_20 > THRESHOLD_COOLDOWN )); then
                send_notification "battery-threshold" "normal" "$icon" "$level" \
                    "Battery Low" "Battery at ''${level}% - Consider plugging in"
                LAST_NOTIFIED_20=$now
            fi
            HAS_NOTIFIED_FULL=false

        elif [[ "$status" == "Charging" || "$status" == "Full" ]]; then
            if (( level >= 97 )) && [[ "$HAS_NOTIFIED_FULL" == "false" ]]; then
                icon=$(get_battery_icon "$level" "Full")
                send_notification "battery-threshold" "low" "$icon" "$level" \
                    "Battery Charged" "Battery at ''${level}% - Consider unplugging"
                HAS_NOTIFIED_FULL=true
            elif (( level < 95 )); then
                HAS_NOTIFIED_FULL=false
            fi
            LAST_NOTIFIED_20=0
            LAST_NOTIFIED_10=0
            LAST_NOTIFIED_5=0
        fi

        save_state
    }

    # --- main ---
    monitor_battery() {
        load_state

        # seed on first run
        if [[ -z "$LAST_CHARGER_STATE" ]]; then
            local p
            p=$(get_battery_path) || { echo "No battery found" >&2; return 1; }
            LAST_CHARGER_STATE=$(read_file "$p/status")
            local now; now=$(date +%s)
            case "$LAST_CHARGER_STATE" in
                Discharging)    DISCHARGE_START=$now ;;
                Charging|Full)  CHARGE_START=$now ;;
            esac
            save_state
        fi

        check_battery

        if command -v ${pkgs.upower}/bin/upower >/dev/null 2>&1; then
            # Event loop: upower emits a line on any power-state change.
            # Add a safety timeout so we re-poll even when events are quiet.
            while true; do
                if ! timeout "$SAFETY_POLL_INTERVAL" ${pkgs.upower}/bin/upower --monitor 2>/dev/null | while read -r _; do
                    check_battery
                done; then
                    : # timeout expired, re-enter loop
                fi
                check_battery
            done
        else
            while true; do
                sleep "$POLL_INTERVAL"
                check_battery
            done
        fi
    }

    monitor_battery
  '';
in
{
  home.packages = [ batteryScript pkgs.upower ];

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

  systemd.user.startServices = true;
}
