{ config, lib, pkgs, ... }:

# Generates ~/.config/Code/User/colors.json for the Dynamic Base16 VSCode
# extension (GnRlLeclerc.dynamic-base16-vscode).
#
# Extension settings to configure manually once in VSCode:
#   "dynamic-base16-vscode.mode": "colors"
# Then activate the theme: Command Palette → "Preferences: Color Theme" → "Dynamic Base16"
#
# The colors.json keys must match the Mustache variables in the extension's
# bundled theme.mustache ({{base00-hex}}, {{scheme-variant}}, etc.).

let
  inherit (config.lib.stylix) colors;
in
{
  home.file.".config/Code/User/colors.json" = {
    text = builtins.toJSON {
      "base00-hex" = colors.base00;
      "base01-hex" = colors.base01;
      "base02-hex" = colors.base02;
      "base03-hex" = colors.base03;
      "base04-hex" = colors.base04;
      "base05-hex" = colors.base05;
      "base06-hex" = colors.base06;
      "base07-hex" = colors.base07;
      "base08-hex" = colors.base08;
      "base09-hex" = colors.base09;
      "base0A-hex" = colors.base0A;
      "base0B-hex" = colors.base0B;
      "base0C-hex" = colors.base0C;
      "base0D-hex" = colors.base0D;
      "base0E-hex" = colors.base0E;
      "base0F-hex" = colors.base0F;
      "scheme-variant" = "dark";
    };
  };
}
