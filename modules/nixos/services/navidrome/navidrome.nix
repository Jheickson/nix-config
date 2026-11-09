{ pkgs, lib, ... }:
{
  services.navidrome = {
    enable = true;
    openFirewall = true;
    user = "felipe";
    withPlugins = p: [ p.lyrics-plugin ];
    settings = {
      MusicFolder = "/home/felipe/Music";
      Port = 4533;
      Address = "0.0.0.0";
      LyricsPriority = "nd-lyrics,.ttml,.yaml,.yml,.elrc,.lrc,.srt,.txt,embedded";
      LastFM.Enabled = true;
    };
    environmentFile = "/etc/navidrome/secrets.env";
  };

  # ProtectHome=true masks /home after the module bind-mounts MusicFolder, so
  # Navidrome sees /home/felipe/Music as missing inside its RootDirectory.
  # The service still sees only the explicitly bound MusicFolder path.
  systemd.services.navidrome.serviceConfig.ProtectHome = lib.mkForce false;

  environment.systemPackages = [
    pkgs.navidrome
  ];

}
