{ pkgs, ... }:

{

  services.navidrome = {
    enable = true;
    openFirewall = true;
    user = "felipe";
    settings = {
      MusicFolder = "/var/music";
      Port = 4533;
      Address = "0.0.0.0";
      LastFM.Enabled = true;
    };
    environmentFile = "/etc/navidrome/secrets.env";
  };

  environment.systemPackages = [
    pkgs.navidrome
  ];

}
