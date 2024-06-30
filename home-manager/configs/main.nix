{ config, pkgs, lib, ...}:

{

  imports = [

    ./alacritty.nix
    ./i3.nix
    ./polybar/polybar.nix
    ./rofi.nix
    ./zsh.nix

  ];

}