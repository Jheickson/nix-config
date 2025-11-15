{ pkgs, config, ... }:
let
  # Set this to true for Wayland, false for X11
  useWayland = true;
in
{

  nixpkgs.config = {
    allowUnfreePredicate = pkg: true;
    permittedInsecurePackages = [ "googleearth-pro-7.3.6.10201" ];
  };

  programs.kdeconnect = {
    enable = true;
  };

  programs.i3lock = {
    enable = true;
  };

  environment.systemPackages =
    with pkgs;
    [
      # NIX
      nixfmt-rfc-style # Run `nixfmt file.nix`
      nixd
      nixfmt

      nixfmt-tree

      # CLI
      hello
      cowsay
      cbonsai
      fd
      tldr
      neofetch
      scrcpy
      superfile
      zenith
      zsh

      # Audio tools
      alsa-utils
      pavucontrol
      pipewire

      ncmpcpp
      strawberry
      feishin

      # DESKTOP APPS
      anki
      brave
      chromium
      calibre
      discord
      drawio
      libreoffice
      electron-mail
      telegram-desktop
      whatsapp-for-linux
      zapzap
      googleearth-pro
      nautilus
      nemo
      nemo-preview
      nemo-with-extensions
      xfce.thunar
      gimp2-with-plugins
      openvpn
      openvpn3
      # networkmanager-openvpn
      pritunl-client

      # UTILITIES
      /* zip
      unzip
      rar
      unrar */
      udiskie
      peazip
      # networkmanager
      networkmanagerapplet
      baobab
      testdisk

      usbutils
      xorg.xeyes

      # MEDIA
      # stremio # Use flatpak version
      obs-studio
      youtube-music
      vlc
      qbittorrent
      qbittorrent-enhanced
      python313Packages.deemix
      picard

      # GAMES
      heroic

      # Codecs / Video acceleration
      libva
      libva-utils

      # For Intel GPUs
      intel-media-driver
      vaapiVdpau # For Nvidia/AMD hybrid setups
      vdpauinfo
      libvdpau-va-gl
      ffmpeg-full

      # DEV
      lazygit
      gh
      yarn
      nodejs_22
      nodePackages.eas-cli
      genymotion
      qemu
      mysql-workbench
      postman
      mongosh
      mongodb
      mongodb-compass
      openssl
      sqlite
      sqlitebrowser
      code-cursor

      # SYSTEM
      libmpdclient
      brightnessctl
      playerctl
      libnotify
      pamixer

      # CUSTOMIZATION
      base16-schemes
      base16-shell-preview

      # FONTS
      # nerdfonts # Big package. Font is already being set on stylix.nix
      siji
      rounded-mgenplus
      termsyn

      # NETWORK
      networkmanager
      networkmanagerapplet
      networkmanager_dmenu

    ]
    ++ (
      if useWayland then
        # WAYLAND-SPECIFIC PACKAGES
        with pkgs;
        [
          # Display configuration
          # Wayland display configuration (replaces arandr)
          wdisplays
          kanshi

          xwayland
          xwayland-run
          xwayland-satellite

          # File manager

          pcmanfm-qt # Qt-based file manager for Wayland

          # Screenshot tools

          # Screenshot tool for Wayland
          grim
          slurp # Region selector for Wayland
          swappy # Screenshot editor for Wayland
          sway-contrib.grimshot # Screenshot tool for Wayland

          # Background/wallpaper

          swaybg # Wallpaper setter for Wayland

          # Additional Wayland utilities

          wl-clipboard # Wayland clipboard utilities
          wofi # Application launcher for Wayland
          swayidle # Idle management for Wayland
          wlopm # Wayland output power manager
        ]
      else
        # X11-SPECIFIC PACKAGES
        with pkgs;
        [
          # Display configuration
          # X11 RandR GUI tool
          arandr
          autorandr

          # File manager

          xfce.thunar # XFCE file manager

          # Screenshot tools

          flameshot # Screenshot tool (X11-focused)

          # Image viewer/background

          feh # X11 image viewer and wallpaper setter
        ]
    );

  # Examples

  # Example 1. Listing available Wi-Fi APs

  # $ nmcli device wifi list
  #   SSID               MODE    CHAN  RATE       SIGNAL  BARS  SECURITY
  #    netdatacomm_local  Infra   6     54 Mbit/s  37      ▂▄__  WEP
  #   F1                 Infra   11    54 Mbit/s  98      ▂▄▆█  WPA1
  #    LoremCorp          Infra   1     54 Mbit/s  62      ▂▄▆_  WPA2 802.1X
  #    Internet           Infra   6     54 Mbit/s  29      ▂___  WPA1
  #    HPB110a.F2672A     Ad-Hoc  6     54 Mbit/s  22      ▂___  --
  #    Jozinet            Infra   1     54 Mbit/s  19      ▂___  WEP
  #    VOIP               Infra   1     54 Mbit/s  20      ▂___  WEP
  #    MARTINA            Infra   4     54 Mbit/s  32      ▂▄__  WPA2
  #    N24PU1             Infra   7     11 Mbit/s  22      ▂___  --
  #    alfa               Infra   1     54 Mbit/s  67      ▂▄▆_  WPA2
  #    bertnet            Infra   5     54 Mbit/s  20      ▂___  WPA1 WPA2

  # This command shows how to list available Wi-Fi networks (APs). You can also use --fields option for displaying different columns. nmcli -f all dev wifi list will show all of them.

  # Example 2. Connect to a password-protected wifi network

  # $ nmcli device wifi connect "$SSID" password "$PASSWORD"

  # $ nmcli --ask device wifi connect "$SSID"

  # In case you get "Secrets were not provided"
  # Try "nmcli con delete <SSID>"

  #   Creating Hotspot
  # With nmcli, we can use a one-liner to create a WiFi hotspot:

  # $ sudo nmcli device wifi hotspot con-name t-450 ssid t-450 band bg password qw3rtyu1
  #
  # Let's see what's happening here:

  # device wifi specifies that we're operating on a WiFi device
  # hotspot signifies that we're creating a hotspot access point
  # con-name t-450 sets the connection name to be t-450
  # ssid t-450 sets the SSID (Service Set Identifier) for the hotspot
  # band bg specifies the radio band, where bg typically refers to the 2.4 GHz band
  # password sets the password for the hotspot access point

  #   Deleting Hotspot
  # When we no longer need the hotspot, we can remove it:

  # $ sudo nmcli connection delete t-450
  # Copy
  # Let's break this down:

  # connection signifies that we're managing a network connection
  # delete specifies that we're deleting a connection, which is t-450 in this case

}
