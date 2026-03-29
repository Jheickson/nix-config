{
  config,
  pkgs,
  ...
}:
let
  pointer = config.home.pointerCursor;
  makeCommand = command: {
    command = [ command ];
  };
in
{
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
      animations = {
        workspace-switch = {
          spring = {
            damping-ratio = 0.80;
            stiffness = 523;
            epsilon = 0.0001;
          };
        };

        window-open = {
          # duration-ms = 400;
          # curve = "ease-out-expo";
          custom-shader = ''
            vec4 door_rise(vec3 coords_geo, vec3 size_geo) {
                float progress = niri_clamped_progress;

                // Tilt from 90 degrees (flat) to 0 degrees (upright)
                float tilt = (1.0 - progress) * 1.57079632;

                // Pivot point at bottom edge
                vec2 coords = coords_geo.xy * size_geo.xy;
                coords.y = size_geo.y - coords.y;

                // Distance from pivot (bottom edge)
                float dist_from_pivot = coords.y;

                // Calculate 3D position
                // Negative z_offset so it goes away from viewer (backward)
                float z_offset = -dist_from_pivot * sin(tilt);
                float y_compressed = dist_from_pivot * cos(tilt);

                // Apply perspective based on depth
                float perspective = 600.0;
                float perspective_scale = perspective / (perspective + z_offset);

                // Scale everything by perspective
                coords.x = (coords.x - size_geo.x * 0.5) * perspective_scale + size_geo.x * 0.5;
                coords.y = y_compressed * perspective_scale;

                // Flip Y back to normal coordinates
                coords.y = size_geo.y - coords.y;

                coords_geo = vec3(coords / size_geo.xy, 1.0);

                vec3 coords_tex = niri_geo_to_tex * coords_geo;
                vec4 color = texture2D(niri_tex, coords_tex.st);

                // Brighten as it rises
                float brightness = 0.4 + 0.6 * progress;
                color.rgb *= brightness;

                return color * progress;
            }

            vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                return door_rise(coords_geo, size_geo);
            }
          '';
        };

        window-close = {
          # duration-ms = 400;
          # curve = "ease-out-expo";
          custom-shader = ''
            vec4 bob_and_slide(vec3 coords_geo, vec3 size_geo) {
                float progress = niri_clamped_progress;

                float y_offset = 0.0;

                // Bob phase (0.0 to 0.25) - goes up then back to 0
                if (progress < 0.25) {
                    float t = progress / 0.25;
                    // Parabola: goes up to peak at t=0.5, back down to 0 at t=1.0
                    y_offset = -40.0 * (1.0 - 4.0 * (t - 0.5) * (t - 0.5));
                }
                // Slide phase (0.25 to 1.0) - slides down
                else {
                    float slide_progress = (progress - 0.25) / 0.75;
                    y_offset = -slide_progress * (size_geo.y + 100.0);
                }

                // Apply transformation
                vec2 coords = coords_geo.xy * size_geo.xy;
                coords.y = coords.y + y_offset;

                coords_geo = vec3(coords / size_geo.xy, 1.0);

                vec3 coords_tex = niri_geo_to_tex * coords_geo;
                vec4 color = texture2D(niri_tex, coords_tex.st);

                return color;
            }

            vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                return bob_and_slide(coords_geo, size_geo);
            }
          '';
        };

        horizontal-view-movement = {
          spring = {
            damping-ratio = 0.65;
            stiffness = 423;
            epsilon = 0.0001;
          };
        };

        window-movement = {
          spring = {
            damping-ratio = 0.65;
            stiffness = 300;
            epsilon = 0.0001;
          };
        };

        window-resize = {
          custom-shader = ''
            vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
                vec3 coords_next_geo = niri_geo_to_tex_next * coords_curr_geo;
                vec4 color = texture2D(niri_tex_next, coords_next_geo.st);
                return color;
            }
          '';
        };

        config-notification-open-close = {
          spring = {
            damping-ratio = 0.65;
            stiffness = 923;
            epsilon = 0.001;
          };
        };

        # screenshot-ui-open = {
        #   duration-ms = 200;
        #   curve = "ease-out-quad";
        # };

        overview-open-close = {
          spring = {
            damping-ratio = 0.85;
            stiffness = 800;
            epsilon = 0.0001;
          };
        };
      };

      prefer-no-csd = true;
      hotkey-overlay.skip-at-startup = true;

    };
  };
}