{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "felipe" ];
  networking.firewall.allowedTCPPorts = [ 5432 ];

  environment.systemPackages = with pkgs; [
    docker
    docker-client
    lazydocker
    docker-compose
    php
    php83Packages.composer
  ];

}
