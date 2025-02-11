{
  config,
  pkgs,
  lib,
  ...
}:

{

  imports = [

    ./alacritty.nix
    ./dunst/dunst.nix
    # ./ghostty.nix
    ./i3.nix
    ./picom.nix
    ./polybar/polybar.nix
    ./rofi.nix
    ./vscode.nix
    ./yazi.nix
    ./zsh.nix

  ];

}
