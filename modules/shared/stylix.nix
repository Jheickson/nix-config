{
  pkgs,
  lib,
  stylixConfig,
  ...
}:

let
  matugen = import ./matugen.nix { inherit pkgs stylixConfig; };
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

    cursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
      size = 16;
    };

    image =
      if stylixConfig.useThemeFile then stylixConfig.wallpaperImage else stylixConfig.wallpaperSource;

    base16Scheme =
      if stylixConfig.useThemeFile then stylixConfig.themeFile else matugen.matugenScheme;
  };
}
