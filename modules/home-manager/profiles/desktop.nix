{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{

  imports = [
    # Desktop environment
    # ../desktop/window-managers/i3.nix
    ../desktop/window-managers/niri
    
    # Window manager additions
    ../desktop/bars/polybar/polybar.nix
    # ../desktop/bars/waybar/waybar.nix
    
    # Launchers
    # ../desktop/launchers/anyrun.nix
    # ../desktop/launchers/fuzzel.nix
    # ../desktop/launchers/rofi.nix
    
    # Notifications
    ../desktop/notifications/battery/battery-notify.nix
    # ../desktop/notifications/dunst/dunst.nix
    
    # Compositors
    # ../desktop/compositors/picom.nix
    # ../desktop/compositors/quickshell.nix
    
    # Programs
    ../programs/terminals/ghostty.nix
    # ../programs/terminals/alacritty.nix
    ../programs/editors/nvim/nixcats.nix
    ../programs/shells/zsh.nix
    # ../programs/browsers/zen-browser.nix
    ../programs/utilities/yazi.nix
    ../programs/utilities/gowall.nix
    ../programs/utilities/noctalia
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
