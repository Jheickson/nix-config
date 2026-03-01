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
      
      # Helper function for Noctalia IPC commands
      noctalia = cmd: [ "noctalia-shell" "ipc" "call" ] ++ (pkgs.lib.splitString " " cmd);
    in
    {
      # ── Media ─────────────────────────────────────────────────────────────
      # Volume
      "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
      "XF86AudioMicMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
      "XF86AudioRaiseVolume".action = set-volume "5%+";
      "XF86AudioLowerVolume".action = set-volume "5%-";
      # Playback
      "XF86AudioPlay".action = playerctl "play-pause";
      "XF86AudioStop".action = playerctl "pause";
      "XF86AudioPrev".action = playerctl "previous";
      "XF86AudioNext".action = playerctl "next";
      # Brightness
      "XF86MonBrightnessUp".action = brightnessctl "set" "+5%";
      "XF86MonBrightnessDown".action = brightnessctl "set" "5%-";

      # ── Screenshots ───────────────────────────────────────────────────────
      "Print".action.screenshot-screen = {
        write-to-disk = true;
      };
      # "Mod+Shift+Alt+S".action = screenshot-window;

      # ── Session ───────────────────────────────────────────────────────────
      "Mod+L".action.spawn = noctalia "lockScreen lock";
      "Mod+Shift+L".action.spawn = noctalia "sessionMenu toggle";
      "Ctrl+Alt+L".action = spawn "sh -c pgrep hyprlock || hyprlock";

      # ── Noctalia UI ───────────────────────────────────────────────────────
      "Mod+D".action.spawn = noctalia "launcher toggle";
      "Mod+N".action.spawn = noctalia "notificationCenter toggle";
      "Mod+C".action.spawn = noctalia "controlCenter toggle";

      # ── Application Launchers ─────────────────────────────────────────────
      "Mod+Return".action = spawn "${pkgs.ghostty}/bin/ghostty";
      "Mod+Shift+B".action = spawn "zen-beta";
      "Mod+Shift+C".action = spawn "code";
      "Mod+Shift+N".action = spawn "nautilus";
      "Mod+U".action = spawn "env XDG_CURRENT_DESKTOP=gnome gnome-control-center";

      # ── Focus / Navigation ────────────────────────────────────────────────
      # Column – left/right (Colemak_dh_wide: a/s)
      "Mod+A".action = focus-column-left;
      "Mod+S".action = focus-column-right;
      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;
      # Window – up/down (Colemak_dh_wide: w/r)
      "Mod+W".action = focus-window-up;
      "Mod+R".action = focus-window-down;
      # Workspace
      "Mod+T".action = focus-workspace-up;
      "Mod+V".action = focus-workspace-down;
      "Mod+Up".action = focus-workspace-up;
      "Mod+Down".action = focus-workspace-down;
      # Monitor
      "Mod+Tab".action = focus-monitor-next;

      # ── Window Movement ───────────────────────────────────────────────────
      # Sideways – consume into / expel from adjacent column
      "Mod+Shift+A".action = consume-or-expel-window-left;
      "Mod+Shift+S".action = consume-or-expel-window-right;
      # Up/down within a column
      "Mod+Shift+W".action = move-window-up;
      "Mod+Shift+R".action = move-window-down;

      # ── Column & Layout ───────────────────────────────────────────────────
      # Width presets
      "Mod+1".action = set-column-width "25%";
      "Mod+2".action = set-column-width "50%";
      "Mod+3".action = set-column-width "75%";
      "Mod+4".action = set-column-width "100%";
      # Fine-grained width / height adjustment
      "Mod+Ctrl+X".action = set-column-width "-10%";
      "Mod+Ctrl+D".action = set-column-width "+10%";
      "Mod+Ctrl+T".action = set-window-height "-10%";
      "Mod+Ctrl+V".action = set-window-height "+10%";
      # Maximize / fullscreen
      "Mod+Shift+F".action = maximize-column;
      "Mod+Ctrl+F".action = fullscreen-window;
      # Floating
      "Mod+Space".action = toggle-window-floating;
      # Consume / expel (column-level)
      "Mod+Comma".action = consume-window-into-column;
      "Mod+Period".action = expel-window-from-column;
      # Tabbed display
      "Mod+Ctrl+W".action = toggle-column-tabbed-display;

      # ── Window Actions ────────────────────────────────────────────────────
      "Mod+Shift+Q".action = close-window;

      # ── Workspace / Monitor Movement ──────────────────────────────────────
      "Mod+Ctrl+Tab".action = move-workspace-to-monitor-next;
      "Mod+Shift+Tab".action = move-column-to-monitor-next;
    };
}
