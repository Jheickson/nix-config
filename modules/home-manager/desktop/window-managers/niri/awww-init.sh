#!/usr/bin/env bash

# Wait for wayland to be ready
sleep 1

# Kill any existing swaybg processes to avoid conflicts
pkill swaybg || true

# Start awww daemon if not already running
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
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
    awww img "$WALLPAPER" --resize crop && echo "[AWWW-INIT] Wallpaper applied successfully" || echo "[AWWW-INIT] Failed to apply wallpaper"
else
    echo "[AWWW-INIT] ERROR: Wallpaper file not found: $WALLPAPER"
fi
