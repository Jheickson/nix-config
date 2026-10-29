{
  pkgs,
  lib,
  stylixConfig,
  inputs,
  ...
}:

let
  generator = import ./generators.nix { inherit pkgs stylixConfig inputs; };
in
{
  stylix = {
    enable = stylixConfig.enable;
    autoEnable = stylixConfig.enable;

    # Stylix has no release-26.05 branch yet; we pin to release-25.11 (closest
    # available) while HM/nixpkgs are on the 26.05 cycle. Remove this once a
    # matching Stylix release branch exists.
    enableReleaseChecks = false;
    # Hellwal carries its own appearance switch, so it drives polarity when
    # it is the active generator; iris/matugen use the shared polarity field.
    polarity =
      if stylixConfig.generator == "hellwal" && stylixConfig.themeFile == null then
        stylixConfig.hellwalPolarityFor {
          inherit (stylixConfig) hellwalAlgorithm hellwalAppearance hellwalFinish;
        }
      else
        stylixConfig.polarity;

    opacity = {
      terminal = 0.75;
    };

    fonts = rec {
      monospace = stylixConfig.font;
      sansSerif = monospace;
      serif = monospace;
    };

    # cursor = {
    #   package = pkgs.phinger-cursors;
    #   name = "phinger-cursors-light";
    #   size = 16;
    # };

    cursor = {
      package = pkgs.rose-pine-cursor;
      name = "BreezeX-RosePine-Linux";
      size = 16;
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      light = "Papirus";
      dark = "Papirus-Dark";
    };

    # Stylix evaluates this image while building; processedWallpaper is
    # generated later during Home Manager activation, so use the source here.
    image = stylixConfig.wallpaperSource;

    base16Scheme = if stylixConfig.themeFile != null then stylixConfig.themeFile else generator.scheme;
  };
}
