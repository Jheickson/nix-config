{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  home.packages = with pkgs; [
    docker
    docker-client
    lazydocker
    docker-compose
    php
    php83Packages.composer
  ];

}