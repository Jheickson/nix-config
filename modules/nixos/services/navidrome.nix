{ pkgs, ... }:

{

  services.navidrome = {
    enable = true;
    openFirewall = true;
    user = "felipe";
    settings = {
      MusicFolder = "/home/felipe/Music";
      Port = 4533;
    };
  };

  environment.systemPackages = [
    pkgs.navidrome
  ];

}
