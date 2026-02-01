{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{

  imports = [
    ./alacritty.nix
    # ./anyrun.nix
    ./battery/battery-notify.nix
    # ./dunst/dunst.nix
    ./fuzzel.nix
    ./ghostty.nix
    ./gowall.nix
    # ./i3.nix
    ./niri
    ./noctalia
    ./nvim/nixcats.nix
    # ./picom.nix
    ./polybar/polybar.nix
    # ./quickshell.nix
    ./rofi.nix
    ./waybar/waybar.nix
    ./yazi.nix
    ./zsh.nix
    # ./zen-browser.nix
  ];

  home.packages = with pkgs; [
    # screenshot
    grim
    slurp

    # utils
    wl-clipboard

    # wallpaper daemon
    swww
  ];

  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

}
