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
          #"custom/playerctl#backward"
          #"custom/playerctl#play"
          #"custom/playerctl#forward"
          "custom/playerlabel"
          "custom/weather"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "network"
          "pulseaudio"
          "backlight"
          "battery"
          "cpu"
          "memory"
          "temperature"
          "tray"
        ];

        "custom/launcher" = {
          format = "<span color='#${colors.base0D}'>󱄅</span>";
          tooltip = false;
          on-click = "${pkgs.fuzzel}/bin/fuzzel";
        };

        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "";
            inactive = "";
            urgent = "";
            visible = "";
          };
          all-outputs = true;
          disable-scroll = false;
          smooth-scrolling-threshold = 120;
        };

        "custom/playerctl#backward" = {
          format = "󰙣 ";
          on-click = "playerctl previous";
          on-scroll-up = "playerctl volume .05+";
          on-scroll-down = "playerctl volume .05-";
        };

        "custom/playerctl#play" = {
          format = "{icon}";
          return-type = "json";
          exec = "playerctl -a metadata --format '{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
          on-click = "playerctl play-pause";
          on-scroll-up = "playerctl volume .05+";
          on-scroll-down = "playerctl volume .05-";
          format-icons = {
            Playing = "<span>󰏥 </span>";
            Paused = "<span> </span>";
            Stopped = "<span> </span>";
          };
        };

        "custom/playerctl#forward" = {
          format = "󰙡 ";
          on-click = "playerctl next";
          on-scroll-up = "playerctl volume .05+";
          on-scroll-down = "playerctl volume .05-";
        };

        "custom/playerlabel" = {
          format = "<span>󰎈 {} 󰎈</span>";
          return-type = "json";
          max-length = 40;
          exec = "playerctl -a metadata --format '{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
          on-click = "playerctl play-pause";
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
          format-wifi = "󰤨 {essid} {bandwidthTotalBytes}";
          format-ethernet = "󰈀";
          format-disconnected = "󰤭";
          tooltip = true;
          on-click = "nm-connection-editor";
          interval = 1;
        };

        cpu = {
          format = "󰍛 {usage:02d}%";
          tooltip = true;
          interval = 1;
        };

        memory = {
          format = "󰘚 {used:0.1f}G/{total:0.1f}G";
          format-alt = "󰘚 {percentage}%";
          tooltip = true;
          tooltip-format = "Memory: {used:0.1f}G/{total:0.1f}G ({percentage}%)";
          interval = 1;
        };

        temperature = {
          thermal-zone = 1;
          critical-threshold = 80;
          format = "󰔏 {temperatureC}°C";
          format-critical = "󰔏 {temperatureC}°C";
          format-warn = "󰔏 {temperatureC}°C";
          tooltip = true;
          interval = 1;
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
        background-color: transparent;
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
      #mpd,
      #custom-playerctl.backward,
      #custom-playerctl.play,
      #custom-playerctl.forward,
      #custom-playerlabel {
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

      #cpu {
        background-color: #${colors.base02};
        border-radius: 4px;
        margin: 4px 0;
      }

      #memory {
        background-color: #${colors.base02};
        border-radius: 4px;
        margin: 4px 0;
      }

      #temperature {
        background-color: #${colors.base02};
        border-radius: 4px;
        margin: 4px 0;
      }

      #temperature.critical {
        background-color: #${colors.base08};
        color: #${colors.base00};
      }

      #temperature.warn {
        background-color: #${colors.base09};
        color: #${colors.base00};
      }

      #custom-launcher {
        background-color: transparent;
        color: #${colors.base0D};
        margin: 0 10px;
        font-size: 30px;
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

      #custom-playerctl.backward,
      #custom-playerctl.play,
      #custom-playerctl.forward {
        background-color: #${colors.base02};
        border-radius: 4px;
        margin: 4px 0;
      }

      #custom-playerctl.backward:hover,
      #custom-playerctl.play:hover,
      #custom-playerctl.forward:hover {
        background-color: #${colors.base01};
      }

      #custom-playerlabel {
        background-color: #${colors.base02};
        border-radius: 4px;
        margin: 4px 0;
      }

      #custom-weather {
        background-color: #${colors.base02};
        border-radius: 4px;
        margin: 4px 0;
      }
    '';
  };

  home.packages = with pkgs; [
    playerctl
    curl
  ];

  programs.waybar.settings.mainBar."custom/weather" = {
    format = "{}";
    return-type = "json";
    exec = "${config.home.homeDirectory}/nix-config/home-manager/configs/waybar/weather.sh";
    interval = 1800;  # 30 minutes
    tooltip = true;
  };
}
