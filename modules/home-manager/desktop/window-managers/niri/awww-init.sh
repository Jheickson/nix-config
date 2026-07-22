#!/usr/bin/env bash
# Store paths injected at build time by settings.nix via substituteInPlace
# (@awwwBin@, @awwwDaemonBin@, @wallpaper@, @resize@).
# No runtime PATH / environment discovery needed.
# Retry loops handle daemon readiness after cold boot.
# Diagnostics go to ~/.cache/awww-init.log for postmortem.

set -uo pipefail

AWWW_BIN="@awwwBin@"
AWWW_DAEMON_BIN="@awwwDaemonBin@"
STYLIX_WALLPAPER="@wallpaper@"
AWWW_RESIZE="@resize@"

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

echo "Wallpaper: $STYLIX_WALLPAPER"

if [ ! -f "$STYLIX_WALLPAPER" ]; then
    echo "ERROR: wallpaper file missing: $STYLIX_WALLPAPER"
    exit 1
fi

# Retry the img call: daemon may accept query but not be fully ready to
# render on the very first attempt after cold boot.
for attempt in $(seq 1 10); do
    if "$AWWW_BIN" img "$STYLIX_WALLPAPER" --resize "$AWWW_RESIZE"; then
        echo "Wallpaper applied on attempt $attempt"
        exit 0
    fi
    echo "attempt $attempt failed, retrying"
    sleep 0.3
done

echo "ERROR: failed to apply wallpaper after 10 attempts"
exit 1
