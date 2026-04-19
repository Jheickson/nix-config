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
    credentialFiles = {
      "LastFM.ApiKey" = ./lastfm-api-key;
      "LastFM.Secret" = ./lastfm-secret;
    };
  };

  environment.systemPackages = [
    pkgs.navidrome
  ];

}
