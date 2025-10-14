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
    ./dunst/dunst.nix
    ./fuzzel.nix
    # ./ghostty.nix
    ./i3.nix
    ./niri
    ./nvim/nixcats.nix
    ./picom.nix
    ./polybar/polybar.nix
    ./rofi.nix
    ./waybar/waybar.nix
    ./yazi.nix
    ./zsh.nix
    # ./zen-browser.nix
  ];

  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";
    opacity = {
      terminal = 0.75;
    };
    fonts = with pkgs; rec {
      monospace = {
        package = nerd-fonts.hack;
        name = "HackNerdFontMono";
      };
      sansSerif = monospace;
      serif = monospace;
    };
    cursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
      size = 16;
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";
    image = ../../nixos/wallpapers/Minimalistic/gruvbox_grid.png;
  };

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
