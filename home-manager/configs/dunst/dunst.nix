{ config, pkgs, ... }:

{
  services.dunst = {
    enable = true;
    configFile = ./dunst.conf;
  };
}