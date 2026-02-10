{ config, pkgs, ... }:

{
  imports = [
    # Importing the xdg portal configuration
    ../desktop/xdg.nix
  ];

  # Add wine to system packages
  environment.systemPackages = with pkgs; [
    wineWowPackages.full
    winetricks
    (bottles.override { removeWarningPopup = true; })
    lutris
  ];
}
