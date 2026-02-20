#!/usr/bin/env bash

# Wait for wayland to be ready
sleep 1

# Kill any existing swaybg processes to avoid conflicts
pkill swaybg || true

# Start swww daemon if not already running
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1
fi

# Load environment variables to get STYLIX_WALLPAPER
if [ -f /etc/set-environment ]; then
    source /etc/set-environment
fi

# Set wallpaper - use STYLIX_WALLPAPER environment variable if set, otherwise use default
WALLPAPER="${STYLIX_WALLPAPER:-$HOME/nix-config/assets/wallpapers/wallpaper.png}"

echo "[SWWW-INIT] Using wallpaper: $WALLPAPER"

if [ -f "$WALLPAPER" ]; then
    swww img "$WALLPAPER" --resize crop && echo "[SWWW-INIT] Wallpaper applied successfully" || echo "[SWWW-INIT] Failed to apply wallpaper"
else
    echo "[SWWW-INIT] ERROR: Wallpaper file not found: $WALLPAPER"
fi
