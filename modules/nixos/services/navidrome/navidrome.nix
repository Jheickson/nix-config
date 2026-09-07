{ pkgs, lib, ... }:

{

  services.navidrome = {
    enable = true;
    openFirewall = true;
    user = "felipe";
    settings = {
      MusicFolder = "/home/felipe/Music";
      Port = 4533;
      Address = "0.0.0.0";
      LastFM.Enabled = true;
    };
    environmentFile = "/etc/navidrome/secrets.env";
  };

  # The upstream module hardcodes ProtectHome = true, which hides /home inside
  # the service namespace. That makes MusicFolder = ~/Music unreachable ("lstat
  # /home: no such file or directory"). Make /home visible read-only so the
  # library is scannable; the folder stays read-only (module bind-mounts it).
  systemd.services.navidrome.serviceConfig.ProtectHome = lib.mkForce "read-only";

  environment.systemPackages = [
    pkgs.navidrome
  ];

}
