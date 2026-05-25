#!/bin/sh

# Kill any existing waybar instances
pkill waybar

# Wait a moment for the session to fully initialize
sleep 1

# Start waybar with the configuration
waybar &
