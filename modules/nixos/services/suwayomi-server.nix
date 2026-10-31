{ pkgs, ... }:
{
  services.suwayomi-server = {
    enable = true;
    openFirewall = true;
    user = "felipe";
    settings.server.port = 4567;
  };

  environment.systemPackages = [
    pkgs.suwayomi-server
  ];
}
