{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.umbriel.nixosModules.default
  ];

  programs.umbriel.enable = true;

  # Enable greetd as the display manager.
  # Keep `command` as a single-line string: nixpkgs greetd module now
  # serialises multi-line Nix strings as TOML triple-quoted strings, which
  # greetd's parser rejects ("expected equals sign on line, but found none"),
  # leaving the system stuck after "Reached target Graphical Interface".
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${config.programs.umbriel.package}/bin/start-umbriel";
        user = "felipe";
      };
    };
  };

  # Xwayland binary on PATH for Umbriel's lazy Xwayland support.
  programs.xwayland.enable = true;

  # seatd for Wayland seat management.
  services.seatd.enable = true;
  services.udev.packages = [ pkgs.seatd ];

  # Ensure user is in the video group for graphics access
  users.users.felipe.extraGroups = [ "video" ];

  # Configure mouse sensitivity via libinput.
  services.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat";
      transformationMatrix = "1.0 0.0 0.0 0.0 2.0 0.0 0.0 0.0 1.0"; # 2x vertical sensitivity
    };
  };
}
