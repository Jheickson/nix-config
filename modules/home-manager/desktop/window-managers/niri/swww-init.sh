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

# Set wallpaper - use STYLIX_WALLPAPER environment variable if set, otherwise use default
WALLPAPER="${STYLIX_WALLPAPER:-~/nix-config/assets/wallpapers/wallpaper.png}"
swww img "$WALLPAPER" --resize stretch
