#!/usr/bin/env bash
# AWWW_BIN, AWWW_DAEMON_BIN and STYLIX_WALLPAPER are injected at build time by
# settings.nix. No runtime PATH / environment discovery needed.
# Retry loops handle daemon readiness after cold boot.
# Diagnostics go to ~/.cache/awww-init.log for postmortem.

set -uo pipefail

LOG="$HOME/.cache/awww-init.log"
mkdir -p "$(dirname "$LOG")"
exec >>"$LOG" 2>&1
echo "==== $(date -u +'%Y-%m-%dT%H:%M:%SZ') ===="

# Wait up to 15s for the wayland socket to exist (cold boot can be slow).
for _ in $(seq 1 60); do
    if [ -n "${WAYLAND_DISPLAY:-}" ] && [ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/${WAYLAND_DISPLAY}" ]; then
        break
    fi
    sleep 0.25
done

# Drop any swaybg from a previous run.
pkill swaybg 2>/dev/null || true

# Start daemon if not already running.
if ! pgrep -x awww-daemon >/dev/null; then
    echo "Starting awww-daemon"
    "$AWWW_DAEMON_BIN" &
fi

# Poll daemon socket until it responds (up to ~8s).
DAEMON_READY=0
for _ in $(seq 1 80); do
    if "$AWWW_BIN" query >/dev/null 2>&1; then
        DAEMON_READY=1
        break
    fi
    sleep 0.1
done
if [ "$DAEMON_READY" -ne 1 ]; then
    echo "ERROR: awww-daemon did not become ready"
    exit 1
fi

WALLPAPER="${STYLIX_WALLPAPER:-$HOME/nix-config/assets/wallpapers/Landscape/wallhaven-rqp3r7.jpg}"
echo "Wallpaper: $WALLPAPER"

if [ ! -f "$WALLPAPER" ]; then
    echo "ERROR: wallpaper file missing: $WALLPAPER"
    exit 1
fi

# Retry the img call: daemon may accept query but not be fully ready to
# render on the very first attempt after cold boot.
for attempt in $(seq 1 10); do
    if "$AWWW_BIN" img "$WALLPAPER" --resize no; then
        echo "Wallpaper applied on attempt $attempt"
        exit 0
    fi
    echo "attempt $attempt failed, retrying"
    sleep 0.3
done

echo "ERROR: failed to apply wallpaper after 10 attempts"
exit 1
