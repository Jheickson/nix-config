{ pkgs, ... }:

{

  services.navidrome = {
    enable = true;
    openFirewall = true;
    user = "felipe";
    settings = {
      MusicFolder = "/var/music";
      Port = 4533;
      LastFM.Enabled = true;
    };
    environmentFile = "/etc/navidrome/secrets.env";
  };

  environment.systemPackages = [
    pkgs.navidrome
  ];

}
