{ config, pkgs, ... }:

{
  imports = [
    # Importing the home-manager module for Zsh configuration
    ./xdg.nix
  ];

  # Add wine to system packages
  environment.systemPackages = with pkgs; [
    wineWowPackages.full
    winetricks
    (bottles.override { removeWarningPopup = true; })
    lutris
  ];
}
