{ config, pkgs, lib, ... }:

let
  # Get stylix colors from the system configuration
  colors = config.lib.stylix.colors;
  
  # Generate dunst configuration with dynamic stylix colors
  dunstConfig = pkgs.writeText "dunst.conf" ''
[global]
    font = ${config.stylix.fonts.sansSerif.name} 10
    
    # Allow HTML markup for rich formatting
    allow_markup = yes
    
    # Sophisticated format with proper typography hierarchy
    format = "<span font_weight='bold' size='large'>%s</span>\n<span size='small' color='${colors.base03}'><b>%a</b> • %b</span>"
    
    # Icon positioning
    icon_position = left
    icon_folders = /usr/share/icons/Papirus-Dark/16x16/panel/;/usr/share/icons/Papirus-Dark/22x22/panel/;/usr/share/icons/Papirus-Dark/24x24/panel/
    
    # Rounded corners
    corner_radius = 12
    
    # Sort by urgency
    sort = yes
    
    # Show hidden count
    indicate_hidden = yes
    
    # Text alignment
    alignment = left
    
    # Word wrap for long messages
    word_wrap = yes
    
    # Show age for old messages
    show_age_threshold = 10
    
    # Geometry - positioned top-right with good spacing
    geometry = "450x5-40+60"
    
    # Transparency matching your current setup
    transparency = 25
    
    # Follow keyboard focus
    follow = keyboard
    
    # Padding and spacing
    padding = 16
    horizontal_padding = 20
    separator_height = 1
    separator_color = "${colors.base01}"
    
    # Frame styling
    frame_width = 2
    
    # Idle threshold
    idle_threshold = 120
    
    # Monitor settings
    monitor = 0
    
    # Startup notification
    startup_notification = true
    
    # Browser for links
    browser = /usr/bin/firefox -new-tab

[frame]
    width = 2

[shortcuts]
    # Close notification
    close = mod4+m
    
    # Close all notifications
    close_all = mod4+shift+m
    
    # History
    history = mod4+n
    
    # Context menu
    context = mod4+shift+i

# Urgency levels with dynamic stylix colors
[urgency_low]
    # Low urgency uses base0D (blue accent) for border
    frame_color = "${colors.base0D}"
    background = "${colors.base00}"
    foreground = "${colors.base05}"
    timeout = 8

[urgency_normal]
    # Normal urgency uses base03 (gray) for border
    frame_color = "${colors.base03}"
    background = "${colors.base00}"
    foreground = "${colors.base05}"
    timeout = 12

[urgency_critical]
    # Critical urgency uses base08 (red accent) for border
    frame_color = "${colors.base08}"
    background = "${colors.base00}"
    foreground = "${colors.base05}"
    timeout = 0

# Special formatting rules for common applications
[Spotify]
    appname = Spotify
    format = "<span font_weight='bold' size='large'>🎵 %s</span>\n<span size='small' color='${colors.base03}'>%b</span>"
    urgency = low

[Discord]
    appname = Discord
    format = "<span font_weight='bold' size='large'>💬 %s</span>\n<span size='small' color='${colors.base03}'><b>%a</b> • %b</span>"
    urgency = normal

[Firefox]
    appname = Firefox
    format = "<span font_weight='bold' size='large'>🦊 %s</span>\n<span size='small' color='${colors.base03}'>%b</span>"
    urgency = normal

[Terminal]
    appname = *Terminal*
    format = "<span font_weight='bold' size='large'>🖥️ %s</span>\n<span size='small' color='${colors.base03}'>%b</span>"
    urgency = low

[System]
    appname = *System*
    format = "<span font_weight='bold' size='large'>⚙️ %s</span>\n<span size='small' color='${colors.base03}'>%b</span>"
    urgency = normal

# Critical system notifications
[System Critical]
    appname = *System*
    summary = *critical*|*error*|*failed*
    urgency = critical
    format = "<span font_weight='bold' size='large' color='${colors.base08}'>🚨 %s</span>\n<span size='small' color='${colors.base03}'>%b</span>"
  '';
in
{
  services.dunst = {
    enable = true;
    configFile = dunstConfig;
  };
}
