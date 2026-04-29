{
  config,
  lib,
  pkgs,
  ...
}:
let
  blurKdl = ''

    // niri v26.04 background-effect — regular (non-xray) blur
    // raw KDL because niri-flake schema lacks background-effect (PR sodiboo/niri-flake#1731)
    window-rule {
        match app-id="^com.mitchellh.ghostty$"
        match app-id="^ghostty$"

        background-effect {
            blur true
            xray false
        }
    }

    // Noctalia bar/dock/launcher: force regular blur instead of default xray.
    // Noctalia opts into blur via ext-background-effect; we just override xray.
    // https://docs.noctalia.dev/v4/getting-started/compositor-settings/niri/
    layer-rule {
        match namespace="^noctalia-(background|launcher-overlay|dock)-.*$"

        background-effect {
            xray false
        }
    }
  '';
in
{
  xdg.configFile.niri-config.source = lib.mkForce (
    let
      raw = pkgs.writeText "niri-config-with-blur.kdl" (
        config.programs.niri.finalConfig + blurKdl
      );
    in
    pkgs.runCommand "niri-config-validated" { } ''
      ${config.programs.niri.package}/bin/niri validate -c ${raw}
      cp ${raw} $out
    ''
  );
}
