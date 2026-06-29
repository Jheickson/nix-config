{
  pkgs,
  lib,
  stylixConfig,
  inputs,
  ...
}:

let
  generatorDrv =
    if stylixConfig.generator == "iris"
    then import ./iris.nix { inherit pkgs stylixConfig inputs; }
    else import ./matugen.nix { inherit pkgs stylixConfig; };
in
{
  stylix = {
    enable = stylixConfig.enable;
    autoEnable = stylixConfig.enable;

    # Stylix has no release-26.05 branch yet; we pin to release-25.11 (closest
    # available) while HM/nixpkgs are on the 26.05 cycle. Remove this once a
    # matching Stylix release branch exists.
    enableReleaseChecks = false;

    polarity = stylixConfig.polarity;

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

    image =
      if stylixConfig.useThemeFile then stylixConfig.wallpaperImage else stylixConfig.wallpaperSource;

    base16Scheme =
      if stylixConfig.useThemeFile then stylixConfig.themeFile else generatorDrv.${if stylixConfig.generator == "iris" then "irisScheme" else "matugenScheme"};
  };
}
