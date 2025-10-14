{ config, pkgs, lib, ...}:


{

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user="felipe";
  };

  # Override the systemd service to add the --service flag
  systemd.services.jellyfin.serviceConfig.ExecStart = lib.mkForce
    "${config.services.jellyfin.package}/bin/jellyfin --service --datadir '/var/lib/jellyfin' --configdir '/var/lib/jellyfin/config' --cachedir '/var/cache/jellyfin' --logdir '/var/lib/jellyfin/log'";

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

}