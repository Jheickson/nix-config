{ config, pkgs, lib, ...}:

{

  imports = [

    ./alacritty.nix
    ./i3.nix
    ./zsh.nix

  ];

}