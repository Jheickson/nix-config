{ config, pkgs, lib }:

let
  # Read the config.json (which is an array) and wrap it properly
  configArray = builtins.fromJSON (builtins.readFile ./config.json);
  configFile = { mainBar = builtins.elemAt configArray 0; };
  styleFile = builtins.readFile ./style.css;
  colorsFile = builtins.readFile ./colors.css;
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings = configFile;

    style = styleFile;
  };

  # Create the colors.css file in the waybar config directory
  xdg.configFile."waybar/colors.css".text = colorsFile;

  home.packages = with pkgs; [
    playerctl
    curl
  ];
}
