{ config, pkgs, ... }:

{ 
  # Add wine to system packages
  environment.systemPackages = with pkgs; [
    wineWowPackages.full
    winetricks
    bottles
  ];
}
