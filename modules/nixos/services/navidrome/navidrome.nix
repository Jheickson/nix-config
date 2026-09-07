{ pkgs, lib, ... }:

let
  ndLyrics = pkgs.stdenvNoCC.mkDerivation {
    pname = "nd-lyrics";
    version = "8.0.0";
    src = ./plugins/nd-lyrics.ndp;
    dontUnpack = true;
    installPhase = ''
      install -Dm644 "$src" "$out/share/$pname.ndp"
    '';
    passthru.isNavidromePlugin = true;
    meta = {
      description = "Navidrome plugin for fetching lyrics from multiple sources";
      homepage = "https://github.com/J0R6IT0/navidrome-lyrics-plugin";
      license = lib.licenses.mit;
    };
  };
in
{
  services.navidrome = {
    enable = true;
    openFirewall = true;
    user = "felipe";
    plugins = [ ndLyrics ];
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
