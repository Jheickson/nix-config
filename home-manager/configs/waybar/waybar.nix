{
  config,
  pkgs,
  lib,
  ...
}:

let
  colors = config.lib.stylix.colors;
  fonts = config.stylix.fonts;
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;

        modules-left = [
          "custom/launcher"
          "niri/workspaces"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "pulseaudio"
          "backlight"
          "battery"
          "network"
          "tray"
        ];

        "custom/launcher" = {
          format = "󰣇";
          tooltip = false;
          on-click = "wofi --show drun";
        };

        "niri/workspaces" = {
          format = "{name}";
          format-icons = {
            active = "";
            inactive = "";
            urgent = "";
            visible = "";
          };
          all-outputs = false;
          disable-scroll = false;
          smooth-scrolling-threshold = 120;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}% ";
          format-muted = "󰝟";
          format-icons = {
            headphone = "󰋋";
            headset = "󰋋";
            handsfree = "󰋋";
            phone = "󰋋";
            portable = "󰋋";
            car = "󰋋";
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
              "󰕾"
            ];
          };
          scroll-step = 5;
          on-click = "pavucontrol";
          on-right-click = "pamixer --toggle-mute";
          on-scroll-up = "pamixer --increase 5";
          on-scroll-down = "pamixer --decrease 5";
        };

        backlight = {
          format = "󰃞 {percent}%";
          tooltip = true;
          on-scroll-up = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
        };

        clock = {
          format = "󰥔 {:%H:%M}";
          tooltip-format = "<big>{:%Y %B %d (%A)}</big>\n<tt><small>{calendar}</small></tt>";
          interval = 60;
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          format-alt = "{time} {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };

        network = {
          format-wifi = "󰤨 {essid}";
          format-ethernet = "󰈀";
          format-disconnected = "󰤭";
          tooltip = true;
          on-click = "nm-connection-editor";
        };

        tray = {
          spacing = 10;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: '${fonts.monospace.name}';
        font-size: 13px;
      }

      window#waybar {
        background-color: #${colors.base00};
        color: #${colors.base05};
        transition-property: background-color;
        transition-duration: .5s;
      }

      window#waybar.hidden {
        opacity: 0.5;
      }

      button {
        box-shadow: inset 0 -3px transparent;
        border: none;
        border-radius: 0;
      }

      button:hover {
        background: inherit;
        box-shadow: inset 0 -3px #${colors.base0D};
      }

      #niri-workspaces {
        margin: 0 4px;
      }

      #niri-workspaces button {
        padding: 0 8px;
        background-color: transparent;
        color: #${colors.base05};
        border-radius: 4px;
        margin: 0 2px;
      }

      #niri-workspaces button:hover {
        background: #${colors.base01};
      }

      #niri-workspaces button.active {
        background-color: #${colors.base0D};
        color: #${colors.base00};
      }

      #niri-workspaces button.visible {
        background-color: #${colors.base02};
      }

      #niri-workspaces button.urgent {
        background-color: #${colors.base08};
      }

      #mode {
        background-color: #${colors.base0E};
        border-bottom: 3px solid #${colors.base05};
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #wireplumber,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #power-profiles-daemon,
      #mpd {
        padding: 0 10px;
        color: #${colors.base05};
      }

      #window,
      #niri-workspaces {
        margin: 0 4px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #niri-workspaces {
        margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #niri-workspaces {
        margin-right: 0;
      }

      #clock {
        background-color: #${colors.base02};
        border-radius: 4px;
        margin: 4px 0;
      }

      #battery {
        background-color: #${colors.base02};
        border-radius: 4px;
        margin: 4px 0;
      }

      #battery.charging, #battery.plugged {
        color: #${colors.base0B};
        background-color: #${colors.base02};
      }

      @keyframes blink {
        to {
          background-color: #${colors.base05};
          color: #${colors.base00};
        }
      }

      #battery.critical:not(.charging) {
        background-color: #${colors.base08};
        color: #${colors.base00};
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      #pulseaudio {
        background-color: #${colors.base02};
        border-radius: 4px;
        margin: 4px 0;
      }

      #pulseaudio.muted {
        background-color: #${colors.base08};
        color: #${colors.base00};
      }

      #backlight {
        background-color: #${colors.base02};
        border-radius: 4px;
        margin: 4px 0;
      }

      #network {
        background-color: #${colors.base02};
        border-radius: 4px;
        margin: 4px 0;
      }

      #network.disconnected {
        background-color: #${colors.base08};
      }

      #custom-launcher {
        background-color: #${colors.base0D};
        color: #${colors.base00};
        border-radius: 4px;
        margin: 4px 0;
        padding: 0 10px;
      }

      #tray {
        background-color: #${colors.base02};
        border-radius: 4px;
        margin: 4px 0;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #${colors.base08};
      }
    '';
  };
}
