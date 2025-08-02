{ config, pkgs, ... }:

{
  # Enable Wine
  programs.wine.enable = true;
  
  # Add wine to system packages
  environment.systemPackages = with pkgs; [
    wineWowPackages.full
    winetricks
    bottles
  ];
}
