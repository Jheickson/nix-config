{ config, pkgs, lib, ... }:
{
  services.dunst = {
    enable = true;
    configFile = ./dunst.conf;
  };
}
