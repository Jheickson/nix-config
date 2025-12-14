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

# Set wallpaper - use argument if provided, otherwise fall back to STYLIX_WALLPAPER
WALLPAPER="${1:-$STYLIX_WALLPAPER}"
swww img "$WALLPAPER" --resize crop
