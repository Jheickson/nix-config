{ config, pkgs, lib, ... }:

{
  services.dunst = {
    enable = true;
    configFile = ./dunst.conf;
    
    # Use the configuration file instead of settings to avoid conflicts
    # All styling is handled in the dunst.conf file
  };
}
