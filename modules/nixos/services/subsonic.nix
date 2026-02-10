# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  services.subsonic = {
    enable = true;
    maxMemory = 1024; # In megabytes
    # defaultMusicFolder = "/home/felipe/Music"; # Change this to your music directory
  };

  networking.firewall.allowedTCPPorts = [ 4040 ]; # Default Subsonic port

}