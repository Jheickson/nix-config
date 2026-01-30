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
  programs.rofi = {
    enable = true;
  };

  xdg.configFile."rofi/config.rasi".text = ''
    configuration {
      modi: "drun,run,window";
      show-icons: true;
      display-drun: "Applications";
      display-run: "Run";
      display-window: "Windows";
    }

    * {
      bg: #${colors.base00};
      bg-alt: #${colors.base01};
      fg: #${colors.base05};
      selected: #${colors.base02};
      accent: #${colors.base0D};
      
      background-color: transparent;
      text-color: @fg;
      font: "${fonts.monospace.name} 12";
    }

    window {
      background-color: @bg;
      width: 30%;
    }

    mainbox {
      background-color: transparent;
      children: [inputbar, listview];
    }

    inputbar {
      background-color: @bg-alt;
      padding: 12px;
      children: [entry];
    }

    entry {
      background-color: transparent;
      placeholder: "Search...";
    }

    listview {
      background-color: transparent;
      padding: 8px;
      lines: 8;
    }

    element {
      background-color: transparent;
      padding: 8px;
    }

    element selected {
      background-color: @selected;
    }

    element-text {
      background-color: transparent;
      text-color: inherit;
    }

    element-icon {
      background-color: transparent;
      size: 24px;
    }
  '';

  home.packages = with pkgs; [
    rofi
  ];
}
