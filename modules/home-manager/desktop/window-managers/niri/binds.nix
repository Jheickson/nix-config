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

      # Helper for Noctalia IPC commands. v5 reworked the CLI: the v4 form
      # `noctalia-shell ipc --any-display call <ns> <action>` is now
      # `noctalia msg <command> [args]` (panels via `panel-toggle <id>`,
      # session actions via `session <action>`). msg talks to the running
      # instance over a socket, so the old --any-display flag is gone.
      noctalia = cmd: [ "noctalia" "msg" ] ++ (pkgs.lib.splitString " " cmd);
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
      # grim + slurp + swappy: region select → annotate in swappy → save/copy (ShareX-like).
      "Print".action = spawn "sh" "-c" ''${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f -'';
      "Mod+P".action = spawn "sh" "-c" ''${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f -'';
      # Niri native screenshot UI: region/window/monitor, Enter saves+copies, Space copies only.
      "Shift+Print".action.screenshot = {
        show-pointer = true;
      };
      "Mod+Shift+P".action.screenshot = {
        show-pointer = true;
      };
      # "Mod+Shift+Alt+S".action = screenshot-window;

      # ── Session ───────────────────────────────────────────────────────────
      "Mod+L".action.spawn = noctalia "session lock";
      "Mod+Shift+L".action.spawn = noctalia "panel-toggle session-panel";
      "Ctrl+Alt+L".action = spawn "sh -c pgrep hyprlock || hyprlock";

      # ── Noctalia UI ───────────────────────────────────────────────────────
      "Mod+D".action.spawn = noctalia "panel-toggle launcher";
      "Mod+N".action.spawn = noctalia "panel-toggle notification-history";
      "Mod+C".action.spawn = noctalia "panel-toggle control-center";

      # ── Application Launchers ─────────────────────────────────────────────
      "Mod+Return".action = spawn "${pkgs.ghostty}/bin/ghostty";
      "Mod+Shift+B".action = spawn "zen-beta";
      "Mod+Shift+C".action = spawn "code";
      "Mod+Shift+N".action = spawn "${pkgs.ghostty}/bin/ghostty" "--class=ghostty-nvim" "-e" "nvim";
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
      # Column width presets
      "Mod+1".action = set-column-width "25%";
      "Mod+2".action = set-column-width "50%";
      "Mod+3".action = set-column-width "75%";
      "Mod+4".action = set-column-width "100%";
      # Window height presets
      "Mod+Ctrl+1".action = set-window-height "25%";
      "Mod+Ctrl+2".action = set-window-height "50%";
      "Mod+Ctrl+3".action = set-window-height "75%";
      "Mod+Ctrl+4".action = set-window-height "100%";
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
      # Workspace movement
      "Mod+Shift+T".action = move-column-to-workspace-up;
      "Mod+Shift+V".action = move-column-to-workspace-down;
      "Mod+Shift+Up".action = move-column-to-workspace-up;
      "Mod+Shift+Down".action = move-column-to-workspace-down;
      # Tabbed display
      "Mod+Ctrl+W".action = toggle-column-tabbed-display;

      # ── Window Actions ────────────────────────────────────────────────────
      "Mod+Shift+Q".action = close-window;

      # ── Workspace / Monitor Movement ──────────────────────────────────────
      "Mod+Ctrl+Tab".action = move-workspace-to-monitor-next;
      "Mod+Shift+Tab".action = move-column-to-monitor-next;
    };
}
