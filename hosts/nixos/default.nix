# NixOS System Configuration
# Composition only — system-wide config split across focused modules
# under modules/nixos/. Host-unique settings (hostName, stateVersion)
# stay inline below.

{
  inputs,
  stylixConfig,
  ...
}:

{
  imports = [
    # Hardware (host-local, not committed-clean — adapt before reusing)
    ./hardware-configuration.nix

    # Shared
    ../../modules/shared/stylix.nix
    ../../modules/shared/nixpkgs-config.nix

    # Home Manager
    inputs.home-manager.nixosModules.home-manager

    # Core
    ../../modules/nixos/core/boot.nix
    ../../modules/nixos/core/networking.nix
    ../../modules/nixos/core/locale.nix
    ../../modules/nixos/core/audio.nix
    ../../modules/nixos/core/users.nix
    ../../modules/nixos/core/nix.nix
    ../../modules/nixos/core/nh.nix
    ../../modules/nixos/core/substituters.nix
    ../../modules/nixos/core/documentation.nix
    # ../../modules/nixos/core/networkmanager.nix

    # Desktop
    # ../../modules/nixos/desktop/gtk.nix
    ../../modules/nixos/desktop/stylix-wallpaper.nix
    ../../modules/nixos/desktop/niri.nix
    # ../../modules/nixos/desktop/xautolock.nix
    ../../modules/nixos/desktop/xdg.nix

    # Hardware
    ../../modules/nixos/hardware/upower.nix
    ../../modules/nixos/hardware/vial.nix

    # Services
    ../../modules/nixos/services/docker.nix
    ../../modules/nixos/services/jellyfin.nix
    ../../modules/nixos/services/navidrome/navidrome.nix
    ../../modules/nixos/services/printing.nix
    ../../modules/nixos/services/flatpak.nix
    ../../modules/nixos/services/udisks2.nix
    ../../modules/nixos/services/mpd.nix

    # Programs
    ../../modules/nixos/programs/nix-ld.nix
    ../../modules/nixos/programs/packages.nix
    ../../modules/nixos/programs/noctalia.nix
    ../../modules/nixos/programs/nicotine-plus.nix
    ../../modules/nixos/programs/base.nix
    ../../modules/nixos/programs/direnv.nix
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs stylixConfig; };
    backupFileExtension = "hm-backup"; # Prevents Stylix conflicts
    users.felipe = import ../../home-manager/home.nix;
  };

  # Host-unique
  networking.hostName = "nixos";
  system.stateVersion = "24.05";
}
