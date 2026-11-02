# Umbriel window + layer rules. Later entries win on conflicts.
# Ported from ../niri/rules.nix. Dropped with no Umbriel equivalent:
#  - geometry-corner-radius / clip-to-geometry / draw-border-with-background
#    (global corner_radius = 0 in appearance.nix covers the radius part)
#  - per-window scroll-factor (browsers)
#  - shadow color override on the screencast-target rule (shadow stays global)
#  - tab-indicator colors on the screencast-target rule (different tab model)
{ config, ... }: let
  colors = config.lib.stylix.colors;
in {
  programs.umbriel.settings = {
    window_rule = [
      # Blur every window over the cached wallpaper blur (official default).
      {blur = true;}

      # Noctalia shell surfaces that are plain windows.
      {
        match.app_id = "^dev.noctalia.Noctalia$";
        default_floating = true;
        default_floating_size_px = {
          width = 1020;
          height = 900;
        };
      }
      {
        match.app_id = "^dev.noctalia.UmbrielSharePicker$";
        default_floating = true;
        default_floating_size_px = {
          width = 800;
          height = 600;
        };
      }
      {
        match.title = "^notificationtoasts_.+_desktop";
        default_position = {
          x = 0;
          y = 0;
          anchor = "bottom_right";
        };
        default_focused = false;
        default_pinned = true;
      }

      # Browsers → 2-browsing, maximized (was open-on-workspace + maximize).
      {
        match.app_id = ["^zen-beta$" "^firefox$" "^chromium-browser$" "^edge$"];
        default_workspace = "2-browsing";
        default_maximize = true;
      }

      # Picture-in-Picture, bottom-right (after browsers: wins over maximize).
      {
        match.app_id = ["^firefox$" "^zen-beta$"];
        match.title = "^Picture-in-Picture$";
        default_floating = true;
        default_position = {
          x = 32;
          y = 32;
          anchor = "bottom_right";
        };
        default_floating_size_px = {
          width = 480;
          height = 270;
        };
      }
      {
        match.title = "^Picture in picture$";
        default_floating = true;
        default_position = {
          x = 32;
          y = 32;
          anchor = "bottom_right";
        };
      }

      # Floating popouts (bottom-right).
      {
        match.title = "^Discord Popout$";
        default_floating = true;
        default_position = {
          x = 32;
          y = 32;
          anchor = "bottom_right";
        };
      }

      # Coding workspace: VSCode, dedicated nvim terminal, Bruno.
      # One rule per app: match keys AND across keys, OR only within one
      # key's array. Bruno reports app-id "electron" (generic), so scope
      # it by title like the old Niri rule did.
      {
        match.app_id = "^code$";
        default_workspace = "3-coding";
        default_scrolling_extent = 0.5;
      }
      {
        match.app_id = "^ghostty-nvim$";
        default_workspace = "3-coding";
        default_scrolling_extent = 0.5;
      }
      {
        match.app_id = "^electron$";
        match.title = "^Bruno";
        default_workspace = "3-coding";
        default_scrolling_extent = 0.5;
      }

      # Floating utilities.
      {
        match.app_id = ["^pavucontrol$" "^pavucontrol-qt$" "^com.saivert.pwvucontrol$"];
        default_floating = true;
      }
      {
        match.app_id = ["^file-roller$" "^org.gnome.FileRoller$" "^org.Nemo$" "^nemo$"];
        default_floating = true;
      }
      # Save/Open chooser (xdg-desktop-portal-gtk): same 800x550 footprint.
      {
        match.app_id = "^xdg-desktop-portal-gtk$";
        default_floating = true;
        default_floating_size_px = {
          width = 800;
          height = 550;
        };
      }
      {
        match.app_id = ["^nm-connection-editor$" "^org.kde.polkit-kde-authentication-agent-1$" "^gcr-prompter$" "^pinentry$"];
        default_floating = true;
      }
      {
        match.app_id = ["^io.github.fsobolev.Cavalier$" "^dialog$" "^popup$" "^task_dialog$"];
        default_floating = true;
      }

      # Floating dialog titles.
      {
        match.title = ["^Progress$" "^File Operations$" "^Copying$" "^Moving$" "^Properties$" "^Downloads$" "^file progress$"];
        default_floating = true;
      }
      {
        match.title = ["^Confirm$" "^Authentication Required$" "^Notice$" "^Warning$" "^Error$"];
        default_floating = true;
      }

      # Social workspace at 50% width, hidden from screencast.
      {
        match.app_id = ["^ferdium$" "^feishin$" "^com.github.th_ch.youtube_music$"];
        default_workspace = "1-social";
        default_scrolling_extent = 0.5;
        block_capture = true;
      }

      # Privacy apps: laptop screen, maximized, hidden from screencast.
      {
        match.app_id = ["^wasistlos$" "^zapzap$" "^electron-mail$" "^slack$" "^discord$" "^telegram-desktop$"];
        default_output = "eDP-1";
        default_maximize = true;
        block_capture = true;
      }
      # Messaging apps without output/maximize constraints.
      {
        match.app_id = ["^org.telegram.desktop$" "^app.drey.PaperPlane$"];
        block_capture = true;
      }

      # Scratchpad dropdown terminal (spawned by spawn_when_empty).
      {
        match.app_id = "^scratchpad-terminal$";
        default_scratchpad = "terminal";
      }

      # Own border colors for scratchpad windows.
      {
        match.is_scratchpad = true;
        border_color_focused = "#E5C07BFF";
        border_color_unfocused = "#5C4A2AFF";
      }

      # Screencast target indicator (frame only; viewers never see it).
      {
        match.is_cast_target = true;
        border_color_focused = "#${colors.base08}FF";
        border_color_unfocused = "#${colors.base09}FF";
      }
    ];

    # From the official example: bar/launchers blur live content behind
    # them; the bar itself + desktop widgets sit on the wallpaper and keep
    # the cheaper cached wallpaper blur.
    layer_rule = [
      {
        match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
        blur = true;
        blur_ignore_alpha = 0.5;
        blur_popups = true;
      }
      {
        match.namespace = "^noctalia-(notification|dock|panel|attached-panel|osd)$";
        blur_optimized = false;
      }
    ];
  };
}
