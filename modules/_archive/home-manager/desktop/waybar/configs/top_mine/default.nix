{ config, pkgs, lib }:

let
  colors = config.lib.stylix.colors;
  fonts = config.stylix.fonts;

  # Read the config.json and substitute placeholders
  configFile = builtins.fromJSON (builtins.readFile ./config.json);

  # Process the config to substitute color and font placeholders
  processedConfig = lib.attrsets.mapAttrsRecursive (path: value:
    if builtins.isString value then
      builtins.replaceStrings
        ["{base00}" "{base01}" "{base02}" "{base03}" "{base04}" "{base05}" "{base06}" "{base07}"
         "{base08}" "{base09}" "{base0A}" "{base0B}" "{base0C}" "{base0D}" "{base0E}" "{base0F}"
         "{monospace}" "fuzzel" "$HOME"]
        ["#${colors.base00}" "#${colors.base01}" "#${colors.base02}" "#${colors.base03}"
         "#${colors.base04}" "#${colors.base05}" "#${colors.base06}" "#${colors.base07}"
         "#${colors.base08}" "#${colors.base09}" "#${colors.base0A}" "#${colors.base0B}"
         "#${colors.base0C}" "#${colors.base0D}" "#${colors.base0E}" "#${colors.base0F}"
         fonts.monospace.name "${pkgs.fuzzel}/bin/fuzzel" config.home.homeDirectory]
        value
    else
      value
  ) configFile;

  # Read the style.css and substitute placeholders
  styleFile = builtins.readFile ./style.css;
  
  # Helper to convert hex color to rgb values
  hexToRgb = hex: let
    r = lib.strings.substring 1 2 hex;
    g = lib.strings.substring 3 2 hex;
    b = lib.strings.substring 5 2 hex;
  in "${builtins.toString (builtins.fromJSON "0x${r}")}, ${builtins.toString (builtins.fromJSON "0x${g}")}, ${builtins.toString (builtins.fromJSON "0x${b}")}";

  processedStyle = builtins.replaceStrings
    (["rgba(base00)" "rgba(base01)" "rgba(base02)" "rgba(base03)" "rgba(base04)" "rgba(base05)" "rgba(base06)" "rgba(base07)"
      "rgba(base08)" "rgba(base09)" "rgba(base0A)" "rgba(base0B)" "rgba(base0C)" "rgba(base0D)" "rgba(base0E)" "rgba(base0F)"]
      ++ ["#{base00}" "#{base01}" "#{base02}" "#{base03}" "#{base04}" "#{base05}" "#{base06}" "#{base07}"
          "#{base08}" "#{base09}" "#{base0A}" "#{base0B}" "#{base0C}" "#{base0D}" "#{base0E}" "#{base0F}"
          "'{monospace}'"])
    (["rgba(${hexToRgb colors.base00}, 0.8)" "rgba(${hexToRgb colors.base01}, 0.8)" "rgba(${hexToRgb colors.base02}, 0.8)" "rgba(${hexToRgb colors.base03}, 0.8)"
      "rgba(${hexToRgb colors.base04}, 0.8)" "rgba(${hexToRgb colors.base05}, 0.8)" "rgba(${hexToRgb colors.base06}, 0.8)" "rgba(${hexToRgb colors.base07}, 0.8)"
      "rgba(${hexToRgb colors.base08}, 0.8)" "rgba(${hexToRgb colors.base09}, 0.8)" "rgba(${hexToRgb colors.base0A}, 0.8)" "rgba(${hexToRgb colors.base0B}, 0.8)"
      "rgba(${hexToRgb colors.base0C}, 0.8)" "rgba(${hexToRgb colors.base0D}, 0.8)" "rgba(${hexToRgb colors.base0E}, 0.8)" "rgba(${hexToRgb colors.base0F}, 0.8)"]
      ++ ["#${colors.base00}" "#${colors.base01}" "#${colors.base02}" "#${colors.base03}"
          "#${colors.base04}" "#${colors.base05}" "#${colors.base06}" "#${colors.base07}"
          "#${colors.base08}" "#${colors.base09}" "#${colors.base0A}" "#${colors.base0B}"
          "#${colors.base0C}" "#${colors.base0D}" "#${colors.base0E}" "#${colors.base0F}"
          "'${fonts.monospace.name}'"])
    styleFile;
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings = {
      mainBar = processedConfig;
    };

    style = processedStyle;
  };

  home.packages = with pkgs; [
    playerctl
    curl
  ];
}
