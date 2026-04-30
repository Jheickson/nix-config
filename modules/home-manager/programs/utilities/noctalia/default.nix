{ pkgs, inputs, lib, ... }:

{
  # Import the home manager module
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Configure Noctalia shell
  programs.noctalia-shell = {
    enable = true;
    
    # Systemd startup is deprecated upstream; spawn via niri spawn-at-startup instead.
    systemd.enable = false;

    # Use your custom settings from the JSON file
    # To update: modify the bar through the GUI, then copy settings and update the JSON file
    # mkForce is needed to override the module's default settings
    settings = lib.mkForce (builtins.fromJSON (builtins.readFile ./settings.json));

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

  # Reload noctalia-shell on `hms`. Kill if running, then ask niri to spawn
  # a fresh instance via IPC so the process is parented by the niri session.
  # Skips silently when niri is not running (e.g. hms from tty/ssh).
  home.activation.reload-noctalia = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ${pkgs.procps}/bin/pgrep -x niri >/dev/null 2>&1; then
      ${pkgs.procps}/bin/pkill -x noctalia-shell || true
      sleep 0.3
      ${pkgs.niri}/bin/niri msg action spawn -- noctalia-shell || true
    fi
  '';

  # Configure wallpapers declaratively (optional)
  home.file.".cache/noctalia/wallpapers.json" = {
    text = builtins.toJSON {
      defaultWallpaper = "/home/felipe/nix-config/assets/wallpapers/wallpaper.png";
      wallpapers = {
        # Add per-monitor wallpapers here
        # "DP-1" = "/path/to/wallpaper.png";
      };
    };
  };
}
