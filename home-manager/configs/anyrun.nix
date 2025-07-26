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
  programs.anyrun = {
    enable = true;
    package = pkgs.anyrun;
  };

  # Create anyrun configuration directory and files
  xdg.configFile = {
    "anyrun/config.ron" = {
      text = ''
        Config(
          width: 800,
          height: 400,
          hide_plugin_info: true,
          hide_icons: false,
          ignore_exclusive_zones: true,
          close_on_click: true,
          close_on_focus: false,
          position: Center,
          layer: Overlay,
          anchor: (top: false, bottom: false, left: false, right: false),
          exclusive_zone: false,
          margin: (top: 0, bottom: 0, left: 0, right: 0),
          padding: (top: 0, bottom: 0, left: 0, right: 0),
          plugins: [
            "applications",
            "shell",
            "symbols",
            "translate",
            "websearch",
            "stdin",
          ],
        )
      '';
    };

    "anyrun/style.css" = {
      text = ''
        * {
          font-family: '${fonts.monospace.name}';
          font-size: 14px;
          color: #${colors.base05};
          background-color: transparent;
          border: none;
          padding: 0;
          margin: 0;
        }

        window {
          background-color: #${colors.base00};
          border-radius: 12px;
          border: 2px solid #${colors.base03};
          box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
        }

        #outer-box {
          margin: 20px;
        }

        #input {
          background-color: #${colors.base01};
          border: 1px solid #${colors.base03};
          border-radius: 8px;
          padding: 12px 16px;
          margin-bottom: 12px;
          color: #${colors.base05};
          font-size: 16px;
        }

        #input:focus {
          border-color: #${colors.base0D};
          box-shadow: 0 0 0 2px rgba(${colors.base0D}33);
        }

        #scroll {
          background-color: transparent;
        }

        #inner-box {
          background-color: transparent;
        }

        #entry {
          padding: 8px 12px;
          margin: 2px 0;
          border-radius: 6px;
          background-color: transparent;
        }

        #entry:selected {
          background-color: #${colors.base02};
          border: 1px solid #${colors.base0D};
        }

        #entry:hover {
          background-color: #${colors.base01};
        }

        #entry:selected:hover {
          background-color: #${colors.base02};
        }

        #text {
          color: #${colors.base05};
          font-weight: normal;
        }

        #entry:selected #text {
          color: #${colors.base05};
          font-weight: bold;
        }

        #plugin-info {
          color: #${colors.base03};
          font-size: 12px;
          margin-top: 8px;
          padding: 4px 8px;
          background-color: #${colors.base01};
          border-radius: 4px;
        }

        #img {
          margin-right: 12px;
          border-radius: 4px;
        }

        /* Scrollbar styling */
        scrollbar {
          background-color: transparent;
        }

        scrollbar slider {
          background-color: #${colors.base03};
          border-radius: 4px;
          min-height: 20px;
        }

        scrollbar slider:hover {
          background-color: #${colors.base04};
        }
      '';
    };
  };

  # Add anyrun plugins to home packages
  home.packages = with pkgs; [
    anyrun
    anyrun-with-plugins
  ];
}
