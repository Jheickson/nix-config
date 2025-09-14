{ config, pkgs, ...}:


{

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user="felipe";
  };

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

}