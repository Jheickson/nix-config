{ pkgs, inputs, lib, ... }:

{
  # Import the home manager module
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Configure Noctalia shell
  programs.noctalia-shell = {
    enable = true;
    
    # Enable systemd service (starts automatically with your session)
    systemd.enable = true;

    # Use your custom settings from the JSON file
    # To update: modify the bar through the GUI, then copy settings and update the JSON file
    settings = ../../../noctalia/settings.json;

    # Optional: Configure plugins
    # plugins = {
    #   sources = [
    #     {
    #       enabled = true;
    #       name = "Official Noctalia Plugins";
    #       url = "https://github.com/noctalia-dev/noctalia-plugins";
    #     }
    #   ];
    #   states = {
    #     # Add plugin states here
    #   };
    #   version = 1;
    # };
  };

  # Configure wallpapers declaratively (optional)
  # Using the wallpaper directory from your settings.json
  home.file.".cache/noctalia/wallpapers.json" = {
    text = builtins.toJSON {
      defaultWallpaper = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}";
      wallpapers = {
        # Add per-monitor wallpapers here
        # "DP-1" = "/path/to/wallpaper.png";
      };
    };
  };
}
