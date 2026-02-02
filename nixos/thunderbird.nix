# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  programs.thunderbird = {
    enable = true;
  };

}
