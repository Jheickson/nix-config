{ pkgs, inputs, lib, config, ... }:

let
  inherit (config.lib.stylix) colors;

  paletteFor = {
    mPrimary = "#${colors.base0D}";
    mOnPrimary = "#${colors.base07}";
    mSecondary = "#${colors.base0E}";
    mOnSecondary = "#${colors.base07}";
    mTertiary = "#${colors.base09}";
    mOnTertiary = "#${colors.base07}";
    mError = "#${colors.base08}";
    mOnError = "#${colors.base07}";
    mSurface = "#${colors.base00}";
    mOnSurface = "#${colors.base05}";
    mSurfaceVariant = "#${colors.base01}";
    mOnSurfaceVariant = "#${colors.base04}";
    mOutline = "#${colors.base03}";
    mShadow = "#${colors.base00}";
    mHover = "#${colors.base01}";
    mOnHover = "#${colors.base05}";
    terminal = {
      background = "#${colors.base00}";
      foreground = "#${colors.base05}";
      cursor = "#${colors.base0D}";
      cursorText = "#${colors.base00}";
      selectionBg = "#${colors.base02}";
      selectionFg = "#${colors.base05}";
      normal = {
        black = "#${colors.base00}";
        red = "#${colors.base08}";
        green = "#${colors.base0B}";
        yellow = "#${colors.base0A}";
        blue = "#${colors.base0D}";
        magenta = "#${colors.base0E}";
        cyan = "#${colors.base0C}";
        white = "#${colors.base05}";
      };
      bright = {
        black = "#${colors.base03}";
        red = "#${colors.base08}";
        green = "#${colors.base0B}";
        yellow = "#${colors.base0A}";
        blue = "#${colors.base0D}";
        magenta = "#${colors.base0E}";
        cyan = "#${colors.base0C}";
        white = "#${colors.base07}";
      };
    };
  };
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;

    package = inputs.noctalia.packages.${pkgs.system}.default;

    # systemd user service: auto-starts on login, restarted by HM activation on
    # rebuild so noctalia picks up config changes without a fragile IPC dance.
    systemd.enable = true;

    settings = ./noctalia-config.toml;
  };

  home.file = {
    ".cache/noctalia/wallpapers.json" = {
      text = builtins.toJSON {
        defaultWallpaper = "/home/felipe/nix-config/assets/wallpapers/wallpaper.png";
        wallpapers = { };
      };
    };

    # Stylix-derived palette for Noctalia. Replaced on every rebuild so the
    # shell picks up the current wallpaper-based colors via source=custom.
    ".config/noctalia/palettes/stylix.json" = {
      text = builtins.toJSON {
        dark = paletteFor;
        light = paletteFor;
      };
    };
  };
}
