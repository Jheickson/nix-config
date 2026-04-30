{ pkgs, inputs, ... }:

{
  # Import the Noctalia NixOS module
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  # Noctalia systemd startup is deprecated upstream (delayed shell + flaky IPC).
  # Spawn happens via niri `spawn-at-startup` in home-manager instead.
  services.noctalia-shell.enable = false;

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
