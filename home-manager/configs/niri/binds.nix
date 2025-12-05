{
  config,
  pkgs,
  ...
}:
{
  programs.niri.settings.binds =
    with config.lib.niri.actions;
    let
      set-volume = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@";
      brightnessctl = spawn "${pkgs.brightnessctl}/bin/brightnessctl";
      playerctl = spawn "${pkgs.playerctl}/bin/playerctl";
    in
    {
      "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
      "XF86AudioMicMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";

      "XF86AudioPlay".action = playerctl "play-pause";
      "XF86AudioStop".action = playerctl "pause";
      "XF86AudioPrev".action = playerctl "previous";
      "XF86AudioNext".action = playerctl "next";

      "XF86AudioRaiseVolume".action = set-volume "5%+";
      "XF86AudioLowerVolume".action = set-volume "5%-";

      "XF86MonBrightnessUp".action = brightnessctl "set" "+5%";
      "XF86MonBrightnessDown".action = brightnessctl "set" "5%-";

      "Print".action.screenshot-screen = {
        write-to-disk = true;
      };
      # "Mod+Shift+Alt+S".action = screenshot-window;

      "Mod+D".action = spawn "${pkgs.fuzzel}/bin/fuzzel";
      "Mod+Return".action = spawn "${pkgs.alacritty}/bin/alacritty";
      "Ctrl+Alt+L".action = spawn "sh -c pgrep hyprlock || hyprlock";

      "Mod+U".action = spawn "env XDG_CURRENT_DESKTOP=gnome gnome-control-center";

      "Mod+Shift+Q".action = close-window;
      "Mod+F".action = maximize-column;

      "Mod+1".action = set-column-width "25%";
      "Mod+2".action = set-column-width "50%";
      "Mod+3".action = set-column-width "75%";
      "Mod+4".action = set-column-width "100%";
      "Mod+Shift+F".action = fullscreen-window;
      "Mod+Space".action = toggle-window-floating;

      "Mod+Comma".action = consume-window-into-column;
      "Mod+Period".action = expel-window-from-column;
      # "Mod+C".action = center-visible-columns;
      # "Mod+Tab".action = switch-focus-between-floating-and-tiling;

      "Mod+Shift+X".action = set-column-width "-10%";
      "Mod+Shift+D".action = set-column-width "+10%";
      "Mod+Shift+T".action = set-window-height "-10%";
      "Mod+Shift+V".action = set-window-height "+10%";

      # Colemak_dh_wide navigation: a,s,w,r for left,right,up,down (matching i3)
      "Mod+A".action = focus-column-left;
      "Mod+S".action = focus-column-right;
      "Mod+W".action = focus-workspace-up;
      "Mod+R".action = focus-workspace-down;
      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;
      "Mod+Down".action = focus-workspace-down;
      "Mod+Up".action = focus-workspace-up;
      "Mod+Tab".action = focus-monitor-next;
      # "Mod+Q".action = focus-monitor-previous;

      # Window movement with Colemak_dh_wide (matching i3)
      "Mod+Shift+A".action = move-column-left;
      "Mod+Shift+S".action = move-column-right;
      "Mod+Shift+W".action = move-column-to-workspace-up;
      "Mod+Shift+R".action = move-column-to-workspace-down;

      # Workspace/monitor movement with Colemak_dh_wide (matching i3)
      "Mod+Ctrl+Tab".action = move-workspace-to-monitor-next;
      # "Mod+Ctrl+F".action = move-workspace-to-monitor-right;
      "Mod+Shift+Tab".action = move-column-to-monitor-next;
      # "Mod+Shift+F".action = move-column-to-monitor-right;

      # Additional i3 keybindings
      "Mod+Shift+B".action = spawn "zen-beta";
      "Mod+Shift+C".action = spawn "code";
    };
}
