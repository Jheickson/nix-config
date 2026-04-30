{ ... }:

{
  # Noctalia is managed entirely in home-manager (programs.noctalia-shell)
  # so `hms` reloads it. Only system-level deps live here.

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
