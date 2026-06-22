{ pkgs, inputs, lib, ... }:

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

  home.file.".cache/noctalia/wallpapers.json" = {
    text = builtins.toJSON {
      defaultWallpaper = "/home/felipe/nix-config/assets/wallpapers/wallpaper.png";
      wallpapers = {
        # "DP-1" = "/path/to/wallpaper.png";
      };
    };
  };
}
