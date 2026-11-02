# Umbriel keybinds. Defining [keybinds] replaces the built-in set, so
# everything reachable must be listed here.
# Colemak_dh_wide navigation preserved: A/S columns, W/R rows, T/V workspaces.
# Deliberate moves vs Niri:
#  - Mod+Space → scratchpad-toggle terminal (was floating toggle)
#  - Mod+Y → window-toggle-floating (float was Mod+Space on Niri)
#  - Mod+W → window-focus-up (same as Niri); tab toggle on Mod+Ctrl+W
#  - Mod+T/V → workspace prev/next (same as Niri); no direct
#    workspace-number jumps — use cycling, back_and_forth, or the overview
#  - Mod+1..4 → extent presets (Niri widths)
#  - Mod+Shift+Tab → window-move-to-output-next
#    (was move-column-to-monitor-next on Niri)
#  - Media/brightness routed through Noctalia (OSD + lock-safe) instead of
#    raw wpctl/playerctl/brightnessctl, per Umbriel docs
#  - Screenshots via Noctalia (Umbriel has no screenshot action)
{ pkgs, ... }: {
  programs.umbriel.settings.keybinds = {
    # ── Media (Noctalia-routed: OSD shows, works while locked) ──────
    "XF86AudioRaiseVolume" = {
      action = "spawn noctalia msg volume-up";
      allow_when_locked = true;
    };
    "XF86AudioLowerVolume" = {
      action = "spawn noctalia msg volume-down";
      allow_when_locked = true;
    };
    "XF86AudioMute" = {
      action = "spawn noctalia msg volume-mute";
      allow_when_locked = true;
      repeat = false;
    };
    "XF86AudioMicMute" = "spawn wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    "XF86AudioPlay" = {
      action = "spawn noctalia msg media toggle";
      allow_when_locked = true;
      repeat = false;
    };
    "XF86AudioStop" = {
      action = "spawn noctalia msg media pause";
      allow_when_locked = true;
      repeat = false;
    };
    "XF86AudioPrev" = {
      action = "spawn noctalia msg media previous";
      allow_when_locked = true;
    };
    "XF86AudioNext" = {
      action = "spawn noctalia msg media next";
      allow_when_locked = true;
    };
    "XF86MonBrightnessUp" = {
      action = "spawn noctalia msg brightness-up";
      allow_when_locked = true;
    };
    "XF86MonBrightnessDown" = {
      action = "spawn noctalia msg brightness-down";
      allow_when_locked = true;
    };

    # ── Screenshots (Noctalia region flow) ──────────────────────────
    "Print" = "spawn noctalia msg screenshot-region";
    "Mod+P" = "spawn noctalia msg screenshot-region";

    # ── Session ─────────────────────────────────────────────────────
    "Mod+Escape" = "session-quit";
    "Mod+Shift+Escape" = {
      action = "shortcuts-inhibit-toggle";
      allow_when_inhibited = true;
      repeat = false;
    };
    "Mod+L" = "spawn noctalia msg session lock";
    "Mod+Shift+L" = "spawn noctalia msg panel-toggle session-panel";

    # ── Noctalia UI ─────────────────────────────────────────────────
    "Mod+D" = "spawn noctalia msg panel-toggle launcher";
    "Mod+N" = "spawn noctalia msg panel-toggle notification-history";
    "Mod+C" = "spawn noctalia msg panel-toggle control-center";

    # ── Application launchers ───────────────────────────────────────
    "Mod+Return" = {
      action = "spawn ${pkgs.ghostty}/bin/ghostty";
      repeat = false;
    };
    "Mod+Shift+B" = "spawn zen-beta";
    "Mod+Shift+C" = "spawn code";
    "Mod+Shift+N" = "spawn ${pkgs.ghostty}/bin/ghostty --class=ghostty-nvim -e nvim";
    "Mod+E" = "spawn nemo";
    "Mod+U" = "spawn env XDG_CURRENT_DESKTOP=gnome gnome-control-center";

    # ── Focus / Navigation ──────────────────────────────────────────
    "Mod+A" = "window-focus-left";
    "Mod+S" = "window-focus-right";
    "Mod+Left" = "window-focus-left";
    "Mod+Right" = "window-focus-right";
    "Mod+W" = "window-focus-up";
    "Mod+R" = "window-focus-down";
    "Mod+T" = "workspace-previous";
    "Mod+V" = "workspace-next";
    "Mod+Up" = "workspace-previous";
    "Mod+Down" = "workspace-next";
    "Mod+Ctrl+O" = "output-focus-next";

    # ── Window movement ─────────────────────────────────────────────
    "Mod+Shift+A" = "window-consume-or-expel-left";
    "Mod+Shift+S" = "window-consume-or-expel-right";
    "Mod+Shift+W" = "window-move-up";
    "Mod+Shift+R" = "window-move-down";
    "Mod+1" = "window-set-primary-extent 0.25";
    "Mod+2" = "window-set-primary-extent 0.5";
    "Mod+3" = "window-set-primary-extent 0.75";
    "Mod+4" = "window-set-primary-extent 1.0";
    "Mod+Ctrl+1" = "window-set-secondary-extent 0.25";
    "Mod+Ctrl+2" = "window-set-secondary-extent 0.5";
    "Mod+Ctrl+3" = "window-set-secondary-extent 0.75";
    "Mod+Ctrl+4" = "window-set-secondary-extent 1.0";
    "Mod+Ctrl+X" = "window-modify-primary-extent -0.1";
    "Mod+Ctrl+D" = "window-modify-primary-extent 0.1";
    "Mod+Ctrl+T" = "window-modify-secondary-extent -0.1";
    "Mod+Ctrl+V" = "window-modify-secondary-extent 0.1";

    # ── Layout ──────────────────────────────────────────────────────
    "Mod+Shift+O" = "workspace-set-layout toggle scrolling dwindle master stacking";

    # ── Maximize / fullscreen / floating ────────────────────────────
    "Mod+Shift+F" = "window-toggle-maximize";
    "Mod+Ctrl+F" = "window-toggle-fullscreen";
    "Mod+Y" = "window-toggle-floating";
    "Mod+Comma" = "window-consume-left";
    "Mod+Period" = "window-consume-right";
    "Mod+Shift+T" = "column-move-to-workspace-previous";
    "Mod+Shift+V" = "column-move-to-workspace-next";
    "Mod+Shift+Up" = "column-move-to-workspace-previous";
    "Mod+Shift+Down" = "column-move-to-workspace-next";
    # ── Window actions ──────────────────────────────────────────────
    "Mod+Shift+Q" = {
      action = "window-close";
      repeat = false;
    };


    # ── Window / workspace across monitors ──────────────────────────
    "Mod+Ctrl+Tab" = "workspace-move-to-output-next";
    "Mod+Shift+Tab" = "window-move-to-output-next";

    # ── Overview ────────────────────────────────────────────────────
    "Mod+O" = {
      action = "overview-toggle";
      repeat = false;
    };

    # ── Scratchpads ─────────────────────────────────────────────────
    # NOTE: bare actions target the implicit `default` pad, which stops
    # existing once named pads are defined — so every action below names
    # its pad. One-at-a-time cycling is wired to `terminal` (the dropdown);
    # `music` is shown/hidden whole via Mod+M.
    "Mod+Space" = "scratchpad-toggle terminal";
    "Mod+Shift+Space" = "window-toggle-scratchpad terminal";
    "Mod+M" = "scratchpad-toggle music";
    "Mod+Shift+M" = "window-toggle-scratchpad music";
    "Mod+Tab" = "scratchpad-focus-next terminal";
    "Mod+Ctrl+Space" = {
      action = "window-restore-from-scratchpad terminal";
      repeat = false;
    };
    "Mod+Alt+Space" = "scratchpad-window-show-next terminal";
    "Mod+Alt+Shift+Space" = "scratchpad-window-show-previous terminal";
  };
}
