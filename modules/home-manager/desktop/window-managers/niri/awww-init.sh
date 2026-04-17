#!/usr/bin/env bash

# Wait for wayland to be ready
sleep 1

AWWW_BIN="${AWWW_BIN:-$(command -v awww || true)}"
AWWW_DAEMON_BIN="${AWWW_DAEMON_BIN:-$(command -v awww-daemon || true)}"

if [ -z "$AWWW_BIN" ] || [ -z "$AWWW_DAEMON_BIN" ]; then
    echo "[AWWW-INIT] ERROR: awww or awww-daemon binary not found in PATH"
    exit 1
fi

# Kill any existing swaybg processes to avoid conflicts
pkill swaybg || true

# Start awww daemon if not already running
if ! pgrep -x "awww-daemon" > /dev/null; then
    "$AWWW_DAEMON_BIN" &
    sleep 1
fi

# Load environment variables to get STYLIX_WALLPAPER
if [ -f /etc/set-environment ]; then
    source /etc/set-environment
fi

# Set wallpaper - use STYLIX_WALLPAPER environment variable if set, otherwise use default
WALLPAPER="${STYLIX_WALLPAPER:-$HOME/nix-config/assets/wallpapers/wallpaper.png}"

echo "[AWWW-INIT] Using wallpaper: $WALLPAPER"

if [ -f "$WALLPAPER" ]; then
    "$AWWW_BIN" img "$WALLPAPER" --resize crop && echo "[AWWW-INIT] Wallpaper applied successfully" || echo "[AWWW-INIT] Failed to apply wallpaper"
else
    echo "[AWWW-INIT] ERROR: Wallpaper file not found: $WALLPAPER"
fi
