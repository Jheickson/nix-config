{ config, ... }:

let
  colors = config.lib.stylix.colors;
in
{
  xdg.configFile."gowall/config.yml".text = ''
    themes:
      - name: "stylix"
        colors:
          - "#${colors.base00}"
          - "#${colors.base01}"
          - "#${colors.base02}"
          - "#${colors.base03}"
          - "#${colors.base04}"
          - "#${colors.base05}"
          - "#${colors.base06}"
          - "#${colors.base07}"
          - "#${colors.base08}"
          - "#${colors.base09}"
          - "#${colors.base0A}"
          - "#${colors.base0B}"
          - "#${colors.base0C}"
          - "#${colors.base0D}"
          - "#${colors.base0E}"
          - "#${colors.base0F}"
  '';
}
