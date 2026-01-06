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
          "custom/playerctl#backward"
          # "custom/playerctl#play"
          "custom/playerlabel"
          "custom/playerctl#forward"
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
          format = "<span color='#${colors.base05}'>󱄅</span>";
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
          max-length = 65;
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
          thermal-zone = 0;
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

      /* Common module styling */
      #clock,
      #battery,
      #cpu,
      #memory,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #tray,
      #custom-playerctl.backward,
      #custom-playerctl.play,
      #custom-playerctl.forward,
      #custom-playerlabel,
      #custom-weather {
        padding: 0 10px;
        color: #${colors.base05};
        background-color: transparent;
      }

      /* Workspace styling */
      #niri-workspaces,
      #window {
        margin: 0 4px;
      }

      #niri-workspaces button {
        padding: 0 8px;
        background-color: transparent;
        color: #${colors.base05};
        border-radius: 4px;
        margin: 0 2px;
      }

      #niri-workspaces button.active {
        color: #${colors.base00};
      }

      .modules-left > widget:first-child > #niri-workspaces {
        margin-left: 0;
      }

      .modules-right > widget:last-child > #niri-workspaces {
        margin-right: 0;
      }

      /* State-based styling */
      #battery.charging,
      #battery.plugged {
        color: #${colors.base0B};
      }

      #battery.critical:not(.charging) {
        color: #${colors.base00};
        animation: blink 0.5s linear infinite alternate;
      }

      #pulseaudio.muted,
      #temperature.critical,
      #temperature.warn {
        color: #${colors.base00};
      }

      #network.disconnected {
        color: #${colors.base08};
      }

      /* Custom modules */
      #custom-launcher {
        background-color: transparent;
        color: #${colors.base0D};
        margin: 0 10px;
        font-size: 30px;
      }

      #custom-playerctl.backward,
      #custom-playerctl.play,
      #custom-playerctl.forward {
        border-radius: 0px;
        margin: 0;
      }

      /* Tray */
      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
      }

      /* Animations */
      @keyframes blink {
        to {
          color: #${colors.base00};
        }
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
    interval = 60; # 1 minute
    tooltip = true;
  };
}
