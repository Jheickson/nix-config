{
  inputs,
  config,
  pkgs,
  ...
}:

{

  imports = [
    # Desktop environment
    ../desktop/window-managers/niri

    # Notifications
    ../desktop/notifications/battery/battery-notify.nix

    # Programs
    ../programs/terminals/ghostty.nix
    ../programs/editors/nvim/vanilla/vanilla.nix
    ../programs/editors/vscode.nix
    ../programs/editors/zed.nix
    ../programs/shells/zsh.nix
    # ../programs/browsers/zen-browser.nix  # broken wrapProgram upstream; raw pkg in home.packages instead
    ../programs/browsers/qutebrowser.nix
    ../programs/utilities/yazi.nix
    ../programs/utilities/fastfetch.nix
    ../programs/utilities/gowall.nix
    ../programs/utilities/noctalia
  ];

  home.packages = with pkgs; [
    # screenshot
    grim
    slurp

    # utils
    wl-clipboard

    # icon theme
    papirus-icon-theme

    # wallpaper daemon
    awww
  ];

  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };
}
