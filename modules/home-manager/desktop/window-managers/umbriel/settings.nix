# Umbriel core settings: session, environment, input, outputs,
# workspaces, layout, scratchpads.
# Ported from ../niri/settings.nix. Dropped with no Umbriel equivalent:
#  - tv_crt animation shaders (see appearance.nix for the spring replacement)
#  - per-window scroll-factor, draw-border-with-background, clip-to-geometry
#  - warp-mouse-to-focus (see input.cursor follows_focus), hotkey-overlay
#  - waybar / xwayland-satellite autostart (Noctalia bar covers the former,
#    Umbriel has built-in lazy Xwayland)
# Hyprlock intentionally skipped (not used).
{
  config,
  pkgs,
  stylixConfig,
  ...
}: let
  pointer = config.home.pointerCursor;

  # Use the generated output only when wallpaper processing is enabled;
  # otherwise wallpaperSource is the applied wallpaper directly.
  wallpaperPath =
    if stylixConfig.processedWallpaper
    then stylixConfig.wallpaperOutputPath
    else
      toString (
        builtins.path {
          path = stylixConfig.wallpaperSource;
          name = "wallpaper";
        }
      );

  # Self-contained awww-init script with build-time injected store paths,
  # eliminating runtime PATH / environment dependencies that fail on cold boot.
  # Runs under Umbriel's general.autostart. Reuses the script from the
  # (unimported) Niri tree so there is exactly one copy.
  awwwInit =
    pkgs.runCommandLocal "awww-init"
    {
      inherit wallpaperPath;
      awwwResize = stylixConfig.wallpaperResize;
      awwwInitSh = builtins.path {
        path = ../niri/awww-init.sh;
        name = "awww-init.sh";
      };
      preferLocalBuild = true;
    }
    ''
      cp "$awwwInitSh" "$out"
      chmod +x "$out"
      substituteInPlace "$out" \
        --replace-fail "@awwwBin@" "${pkgs.awww}/bin/awww" \
        --replace-fail "@awwwDaemonBin@" "${pkgs.awww}/bin/awww-daemon" \
        --replace-fail "@wallpaper@" "$wallpaperPath" \
        --replace-fail "@resize@" "$awwwResize"
    '';
in {
  programs.umbriel = {
    enable = true;
    settings = {
      # Hybrid override: local.toml is a plain file in this repo,
      # symlinked out-of-store so edits apply on save with no rebuild
      # (Umbriel watches and reloads includes). Tables merge by key;
      # plain arrays/scalars in local.toml replace the base value;
      # [[window_rule]]/[[workspace]] lists append — set one to [] to
      # discard base entries. Documented in ./local.toml.
      include.optional.files = ["~/.config/umbriel/local.toml"];

      general = {
        mod_key = "Super";
        # Noctalia runs via its systemd user service, not here.
        autostart = [
          "${awwwInit}"
          "wl-paste --watch cliphist store"
          "wl-paste --type text --watch cliphist store"
          "ferdium"
          "${pkgs.jellyfin}/bin/jellyfin --service"
          "udiskie -a -s"
        ];
        # Niri skipped its hotkey overlay at startup; same here.
        show_cheatsheet = false;
      };

      # NOTE: Umbriel forbids overriding WAYLAND_DISPLAY, WAYLAND_SOCKET,
      # DISPLAY, UMBRIEL_SOCKET, LIBEI_SOCKET, XDG_CURRENT_DESKTOP,
      # XDG_SESSION_DESKTOP and XDG_SESSION_TYPE here — all dropped.
      environment = {
        CLUTTER_BACKEND = "wayland";
        GDK_BACKEND = "wayland,x11";
        GTK_USE_PORTAL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        SDL_VIDEODRIVER = "wayland";
        STYLIX_WALLPAPER = wallpaperPath;
      };

      input = {
        keyboard = {
          numlock_toggle = true;
          track_layout = "global";
          layout = "us,us";
          variant = "colemak_dh_wide,";
          options = "grp:alt_shift_toggle,caps:backspace,backspace:caps";
        };

        touchpad = {
          tap = true;
          natural_scroll = true;
          # Niri `button-areas` / `left-right-middle` with dashes.
          click_method = "button_areas";
          tap_button_map = "left_right_middle";
          disable_while_typing = true;
          disable_on_external_mouse = false;
          scroll_method = "two_finger";
          sensitivity = 0.75;
          # Niri middle-emulation / dwtp split have no equivalent.
        };

        # Niri focus-follows-mouse (1% max scroll) + warp-to-focus.
        # follows_focus covers warp; pointer-driven focus never warps.
        focus = {
          follows_mouse = true;
          follows_mouse_max_scroll = 0.01;
          hover_raises = true;
        };

        cursor = {
          size = 12;
          theme = "${pointer.name}";
          hide_when_typing = true;
        };
      };

      output = {
        "eDP-1" = {
          scale = 1.0;
          position = [1920 900];
        };
        "HDMI-A-1" = {
          mode = "1920x1080@144";
          scale = 1.0;
          position = [0 0];
        };
      };

      # Niri workspace-auto-back-and-forth + empty-above-first.
      workspaces = {
        back_and_forth = true;
        empty_above = true;
      };

      # Persistent names on the dynamic inventory. Unlike Niri's single
      # global strip, workspaces are per-output: an entry without `output`
      # exists independently on every output. Browsing stays pinned to
      # the external monitor like the Niri open-on-output rule.
      workspace = [
        {name = "1-social";}
        {
          name = "2-browsing";
          output = "HDMI-A-1";
        }
        {name = "3-coding";}
      ];

      layout = {
        mode = "scrolling";
        gap = 30;
        # Niri preset-column-widths 25/50/75/100%.
        extent_presets = [0.25 0.333 0.5 0.667];
        struts = {
          left = 2;
          right = 2;
          top = 2;
          bottom = 2;
        };
        scrolling = {
          default_extent_fraction = 0.5;
          center_underfull_strip = true;
          # Niri center-focused-column = on-overflow.
          center_focused = "on_overflow";
        };
        tabs = {
          # Niri default-column-display = tabbed.
          default_display = "tabbed";
        };
      };

      # The reason for the switch. terminal: dropdown anywhere, spawns
      # ghostty on first toggle. music: keeps players off 1-social.
      scratchpad = [
        {
          name = "terminal";
          spawn_when_empty = "ghostty --class=scratchpad-terminal";
          proportional_size = true;
        }
        {
          name = "music";
          proportional_size = true;
        }
      ];
    };
  };
}
