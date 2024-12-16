{ config, pkgs, lib, ...}:

{

  imports = [

    ./alacritty.nix
    ./dunst/dunst.nix
    ./i3.nix
    ./picom.nix
    ./polybar/polybar.nix
    ./rofi.nix
    ./yazi.nix
    ./zsh.nix

  ];

}