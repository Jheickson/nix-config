{ pkgs, lib, stylixConfig, ... }:

{
  stylix = {
    enable = stylixConfig.enable;
    autoEnable = stylixConfig.enable;

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

    image = if stylixConfig.useThemeFile then
      stylixConfig.wallpaperImage
    else
      stylixConfig.wallpaperSource;
  } // lib.optionalAttrs stylixConfig.useThemeFile {
    base16Scheme = stylixConfig.themeFile;
  };
}