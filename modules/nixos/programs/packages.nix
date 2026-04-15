{ pkgs, config, ... }:
let
  # Set this to true for Wayland, false for X11
  useWayland = true;
in
{

  nixpkgs.config = {
    allowUnfreePredicate = pkg: true;
    permittedInsecurePackages = [
      "googleearth-pro-7.3.6.10201"
      "xpdf-4.05"
      "python-2.7.18.12"
    ];
  };

  programs.kdeconnect = {
    enable = true;
  };

  programs.i3lock = {
    enable = false;
  };

  environment.systemPackages =
    with pkgs;
    [
      # === NIX TOOLS ===
      nix-search-cli
      nixd
      nixfmt # Run `nixfmt file.nix`
      nixfmt-tree

      # === DEVELOPMENT ===
      bruno
      bun
      gh
      lazygit
      ngrok
      nodejs_22
      # nodePackages.eas-cli
      opencode
      claude-code
      openssl
      # pipx
      # postman
      # python2
      python313
      python313Packages.pip
      ruby
      # sqlite
      # sqlitebrowser
      # yarn
      # code-cursor
      # genymotion
      # mongodb
      # mongodb-compass
      # mongosh
      # mysql-workbench
      # qemu

      # === DESKTOP APPLICATIONS ===
      anki
      calibre
      chromium
      # discord
      # electron-mail
      ferdium
      libreoffice
      nautilus
      scanmem
      # slack
      # telegram-desktop
      # googleearth-pro
      # nemo
      # nemo-preview
      # nemo-with-extensions
      # thunar
      # whatsapp-for-linux
      # zapzap

      # === MEDIA & ENTERTAINMENT ===
      feishin
      tauon
      heroic
      mediaelch
      ncmpcpp
      obs-studio
      picard
      pear-desktop
      qbittorrent
      # qbittorrent-enhanced
      vlc
      # stremio # Use flatpak version

      # === AUDIO & VIDEO ===
      alsa-utils
      ffmpeg-full
      intel-media-driver # For Intel GPUs
      libva
      libva-utils
      libva-vdpau-driver # For Nvidia/AMD hybrid setups
      libvdpau-va-gl
      pavucontrol
      pipewire
      vdpauinfo

      # === NETWORKING ===
      networkmanager
      networkmanager_dmenu
      networkmanagerapplet
      # openvpn
      # openvpn3
      pritunl-client
      # networkmanager-openvpn

      # === SYSTEM UTILITIES ===
      android-tools
      baobab
      brightnessctl
      busybox
      gnome-disk-utility
      jq
      libmpdclient
      libnotify
      pamixer
      peazip
      playerctl
      rar
      scrcpy
      testdisk
      udiskie
      unrar
      unzip
      usbutils
      xeyes
      yq
      zenith
      zip

      # === CLI TOOLS ===
      cbonsai
      cowsay
      fastfetch
      fd
      hello
      tldr
      zsh

      # === DOCUMENT PROCESSING ===
      ghostscript
      gnumake
      texlive.combined.scheme-full

      # === THEMING & CUSTOMIZATION ===
      base16-schemes
      base16-shell-preview

      # === FONTS ===
      rounded-mgenplus
      siji
      termsyn
      # nerdfonts # Big package. Font is already being set on stylix.nix

    ]
    ++ (
      if useWayland then
        # === WAYLAND-SPECIFIC PACKAGES ===
        with pkgs;
        [
          # Display & Window System
          kanshi # Wayland display configuration (replaces arandr)
          wdisplays # Display configuration GUI
          xwayland
          xwayland-run
          xwayland-satellite

          # Screenshots
          grim # Screenshot tool for Wayland
          slurp # Region selector for Wayland
          sway-contrib.grimshot # Screenshot tool for Wayland
          swappy # Screenshot editor for Wayland

          # Additional utilities (commented out)
          # pcmanfm-qt # Qt-based file manager for Wayland
          # swaybg # Wallpaper setter for Wayland
          # swayidle # Idle management for Wayland
          # wl-clipboard # Wayland clipboard utilities
          # wlopm # Wayland output power manager
          # wofi # Application launcher for Wayland
        ]
      else
        # === X11-SPECIFIC PACKAGES ===
        with pkgs;
        [
          # Display configuration
          arandr # X11 RandR GUI tool
          autorandr

          # File manager
          thunar # XFCE file manager

          # Screenshots & wallpapers
          feh # X11 image viewer and wallpaper setter
          flameshot # Screenshot tool (X11-focused)
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
