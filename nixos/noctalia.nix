{ pkgs, inputs, ... }:

{
  # Import the Noctalia NixOS module
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  # Enable Noctalia shell systemd service
  services.noctalia-shell = {
    enable = true;
    # For Niri, graphical-session.target works out of the box
    # Uncomment and customize if using a different compositor:
    # target = "my-hyprland-session.target";
  };

  # Enable required services for Noctalia features
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.power-profiles-daemon.enable = true;

  # UPower is already enabled in upower.nix, so we don't need to enable it here
  # services.upower.enable = true;

  # Optional: Enable calendar events support via evolution-data-server
  # Uncomment if you want to use calendar events in Noctalia
  services.gnome.evolution-data-server.enable = true;
}
