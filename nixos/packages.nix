{ pkgs, ...}: {

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [];
  };


  environment.systemPackages = with pkgs; [

    # CLI
    hello
    cowsay
    tldr
    scrcpy
    neofetch
    zenith
    zsh

    # DESKTOP APPS
    brave
    chromium
    drawio
    libreoffice
    electron-mail
    telegram-desktop
    whatsapp-for-linux

    # UTILITIES
    # peazip
    xfce.thunar

    # NETWORK
    networkmanager
    networkmanagerapplet
    networkmanager_dmenu

    # MEDIA
    flameshot
    stremio
    obs-studio
    youtube-music
    vlc

    # DEV
    lazydocker
    lazygit

    # SYSTEM
    brightnessctl
    playerctl
    libnotify

    # FONTS
    nerdfonts
    siji
    rounded-mgenplus
    termsyn

  ];
}