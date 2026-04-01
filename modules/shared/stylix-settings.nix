{ pkgs, ... }:

{
  enable = true;
  useThemeFile = true;

  wallpaperSource = ../../assets/wallpapers/Minimalistic/wallhaven-9omylw.png;
  wallpaperImage = ../../assets/wallpapers/wallpaper.png;
  wallpaperOutputPath = "/home/felipe/nix-config/assets/wallpapers/wallpaper.png";

  themeFile = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
}