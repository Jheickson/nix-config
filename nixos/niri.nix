{ config, pkgs, ... }:

{
  # Enable greetd as the display manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.niri}/bin/niri-session
        '';
        user = "felipe";
      };
    };
  };

  # Ensure Niri is available system-wide
  environment.systemPackages = with pkgs; [
    niri
  ];

  # Install the desktop session file
  environment.etc = {
    "xsessions/niri.desktop".source = ./niri-session.desktop;
  };

  # Configure seatd for Wayland
  services.seatd.enable = true;
  services.udev.packages = [ pkgs.seatd ];

  # Ensure user is in the video group for graphics access
  users.users.felipe.extraGroups = [ "video" ];

  # Configure mouse sensitivity via libinput
  services.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat";
      transformationMatrix = "1.0 0.0 0.0 0.0 2.0 0.0 0.0 0.0 1.0"; # 2x vertical sensitivity
    };
  };
}
