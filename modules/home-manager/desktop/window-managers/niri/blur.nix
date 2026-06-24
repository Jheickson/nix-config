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
    // https://docs.noctalia.dev/v5/compositor-settings/niri/?section=blur#blur
    window-rule {
        background-effect {
            blur true
            xray false
        }
    }

    // Noctalia v5 surfaces: disable xray for realistic blur.
    // blur regions are auto-published by Noctalia via ext-background-effects.
    layer-rule {
        match namespace="^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$"

        background-effect {
            xray false
        }
    }

    blur {
        passes 2
        offset 3.0
        noise 0.03
        saturation 1.0
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
