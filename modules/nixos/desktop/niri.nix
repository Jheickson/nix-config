{ config, pkgs, ... }:

{
  # greetd is the display manager. The graphical, session-picking greeter
  # (regreet) and its launch command live in desktop/greeter.nix.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "felipe";
      };
    };
  };

  programs.xwayland.enable = true;

  # Ensure Niri is available system-wide
  environment.systemPackages = with pkgs; [
    niri
  ];

  # Niri's session file is provided by the `niri` package
  # (share/wayland-sessions/niri.desktop) and is auto-discovered by the
  # greeter, so no manual session file is needed here.

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
