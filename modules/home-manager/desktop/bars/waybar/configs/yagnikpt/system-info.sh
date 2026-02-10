#!/usr/bin/env bash
set -euo pipefail

# Calculate CPU usage over a short interval
read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
prev_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
prev_idle=$((idle + iowait))
sleep 0.1
read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
new_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
new_idle=$((idle + iowait))
total_diff=$((new_total - prev_total))
idle_diff=$((new_idle - prev_idle))
cpu_usage=0
if [[ $total_diff -gt 0 ]]; then
  cpu_usage=$(( (1000 * (total_diff - idle_diff) / total_diff + 5) / 10 ))
fi

# Memory info (MiB/GiB)
read -r _ mem_total_kb _ < <(grep -m1 '^MemTotal:' /proc/meminfo)
read -r _ mem_avail_kb _ < <(grep -m1 '^MemAvailable:' /proc/meminfo)
mem_used_kb=$((mem_total_kb - mem_avail_kb))
mem_total_gib=$(awk -v kb="$mem_total_kb" 'BEGIN {printf "%.1f", kb/1024/1024}')
mem_used_gib=$(awk -v kb="$mem_used_kb" 'BEGIN {printf "%.1f", kb/1024/1024}')
mem_pct=$(awk -v used="$mem_used_kb" -v total="$mem_total_kb" 'BEGIN {printf "%d", (used/total)*100}')

# Temperature (°C)
temp_c="N/A"
for path in /sys/class/thermal/thermal_zone*/temp; do
  if [[ -r "$path" ]]; then
    raw=$(cat "$path" 2>/dev/null || true)
    if [[ "$raw" =~ ^[0-9]+$ ]]; then
      temp_c=$(awk -v t="$raw" 'BEGIN {printf "%.0f", t/1000}')
      break
    fi
  fi
done

# Disk usage for root
read -r _ disk_total disk_used disk_avail disk_usepct _ < <(df -h / | awk 'NR==2 {print $1, $2, $3, $4, $5, $6}')

# Build tooltip with actual newlines
tooltip="CPU: ${cpu_usage}%
RAM: ${mem_used_gib} / ${mem_total_gib} GiB (${mem_pct}%)
Temp: ${temp_c}°C
Disk: ${disk_used} / ${disk_total} (${disk_avail} free, ${disk_usepct} used)"

# Escape for JSON: replace \ with \\, " with \", and newlines with \n
escaped_tooltip=$(printf '%s' "$tooltip" | sed 's/\\/\\\\/g; s/"/\\"/g' | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')

printf '{"text":"","tooltip":"%s"}\n' "$escaped_tooltip"
