{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    docker
    docker-client
    lazydocker
    docker-compose
    php
    php83Packages.composer
  ];

}