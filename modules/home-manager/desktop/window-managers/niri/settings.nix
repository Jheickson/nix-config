{
  config,
  pkgs,
  lib,
  ...
}:
let
  pointer = config.home.pointerCursor;
  makeCommand = command: {
    command = [ command ];
  };
  selectedAnimation = config.programs.niri.animationPreset;
  animationPresetNames = import ./animations/preset-names.nix;
in
{
  options.programs.niri.animationPreset = lib.mkOption {
    type = lib.types.enum animationPresetNames;
    default = "glitch_00";
    description = "Select which generated Niri animation preset to use.";
  };

  config = {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
      settings = {
      environment = {
        CLUTTER_BACKEND = "wayland";
        DISPLAY = ":0";
        GDK_BACKEND = "wayland,x11";
        GTK_USE_PORTAL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        SDL_VIDEODRIVER = "wayland";
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_TYPE = "wayland";
      };
      spawn-at-startup = [
        (makeCommand "hyprlock")
        {
          command = [
            "${./swww-init.sh}"
          ];
        }
        (makeCommand "waybar")
        {
          command = [
            "wl-paste"
            "--watch"
            "cliphist"
            "store"
          ];
        }
        {
          command = [
            "wl-paste"
            "--type text"
            "--watch"
            "cliphist"
            "store"
          ];
        }
        { command = [ "ferdium" ]; }
        # { command = [ "electron-mail" ]; }
        { command = [ "kdeconnect-app" ]; }
        { command = [ "xwayland-satellite" ]; }
        {
          command = [
            "${pkgs.jellyfin}/bin/jellyfin"
            "--service"
          ];
        }

        {
          command = [
            "udiskie"
            "-a"
            "-s"
          ];
        }
      ];
      input = {

        keyboard.xkb = {
          layout = "us,us";
          variant = "colemak_dh_wide,";
          options = "grp:alt_shift_toggle,caps:backspace,backspace:caps";
        };

        touchpad = {
          click-method = "button-areas";
          dwt = true;
          dwtp = true;
          natural-scroll = true;
          scroll-method = "two-finger";
          tap = true;
          tap-button-map = "left-right-middle";
          middle-emulation = true;
          accel-profile = "flat";
          accel-speed = 0.75;
        };

        # mouse configuration will be handled via libinput

        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "1%";
        };

        warp-mouse-to-focus.enable = true;
        workspace-auto-back-and-forth = true;
      };
      screenshot-path = "~/Pictures/Screenshots/Screenshot-from-%Y-%m-%d-%H-%M-%S.png";
      outputs = {
        "eDP-1" = {
          scale = 1.0;
          position = {
            x = 1920;
            y = 900;
          };
        };
        "HDMI-A-1" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 144.00;
          };
          scale = 1.0;
          position = {
            x = 0;
            y = 0;
          };
        };
      };

      overview = {
        workspace-shadow.enable = false;
        backdrop-color = "transparent";
      };
      gestures = {
        hot-corners.enable = true;
      };
      cursor = {
        size = 12;
        theme = "${pointer.name}";
      };
      layout = {
        focus-ring = {
          enable = true;
          width = 2;
          active.color = "#${config.lib.stylix.colors.base0D}50";
          inactive.color = "#${config.lib.stylix.colors.base03}30";
          urgent.color = "#${config.lib.stylix.colors.base08}50";
        };
        border = {
          enable = false;
          width = 2;
          active.color = "#${config.lib.stylix.colors.base0D}50";
          inactive.color = "#${config.lib.stylix.colors.base03}30";
          urgent.color = "#${config.lib.stylix.colors.base08}50";
        };
        shadow = {
          enable = false;
        };
        preset-column-widths = [
          { proportion = 0.25; }
          { proportion = 0.5; }
          { proportion = 0.75; }
          { proportion = 1.0; }
        ];
        default-column-width = {
          proportion = 0.5;
        };

        gaps = 2;
        struts = {
          left = 2;
          right = 2;
          top = 2;
          bottom = 2;
        };

        tab-indicator = {
          hide-when-single-tab = true;
          place-within-column = true;
          position = "left";
          corner-radius = 20.0;
          gap = -12.0;
          gaps-between-tabs = 10.0;
          width = 4.0;
          length.total-proportion = 0.1;
          # color = "#${config.lib.stylix.colors.base0D}";
        };

        # "never": no special centering, focusing an off-screen column will scroll it to the left or right edge of the screen. This is the default.
        # "always", the focused column will always be centered.
        # "on-overflow", focusing a column will center it if it doesn't fit on screen together with the previously focused column.
        center-focused-column = "never";

        empty-workspace-above-first = true;
        always-center-single-column = true;
      };

      # Taken from "https://github.com/jgarza9788/niri-animation-collection"
      # Select a preset via `programs.niri.animationPreset`; the available
      # values are generated automatically and should appear in IDE completion.
      animations = import ./animations/presets/${selectedAnimation}.nix;

      prefer-no-csd = true;
      hotkey-overlay.skip-at-startup = true;
      };
    };
  };
}