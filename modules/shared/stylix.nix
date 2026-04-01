{ pkgs, lib, ... }:

let
  useThemeFile = true;
  wallpaperSource = ../../assets/wallpapers/Minimalistic/wallhaven-9omylw.png;
  themeFile = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
in
{
  stylix = {
    enable = true;
    autoEnable = true;

    polarity = "dark";

    opacity = {
      terminal = 0.75;
    };

    fonts = with pkgs; rec {
      monospace = {
        package = nerd-fonts.hack;
        name = "HackNerdFontMono";
      };
      sansSerif = monospace;
      serif = monospace;
    };

    cursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
      size = 16;
    };

    image = if useThemeFile then
      ../../assets/wallpapers/wallpaper.png
    else
      wallpaperSource;
  } // lib.optionalAttrs useThemeFile {
    base16Scheme = themeFile;
  };
}