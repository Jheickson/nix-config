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

    # Configure settings - only override what you need
    # Most defaults work well out of the box
    settings = {
      bar = {
        widgets = {
          left = [
            {
              id = "Launcher";
            }
            {
              id = "Workspace";
            }
            {
              id = "ActiveWindow";
            }
          ];
          
          center = [
            {
              id = "Clock";
            }
          ];
          
          right = [
            {
              id = "SystemMonitor";
            }
            {
              id = "Network";
            }
            {
              id = "Bluetooth";
            }
            {
              id = "Battery";
            }
            {
              id = "ControlCenter";
            }
          ];
        };
      };
    };

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
