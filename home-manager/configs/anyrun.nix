{
  config,
  pkgs,
  lib,
  ...
}:

let
  colors = config.lib.stylix.colors;
  fonts = config.stylix.fonts;
in
{
  programs.anyrun = {
    enable = true;
    package = pkgs.anyrun;
    config = {
      # Use fractions for proper centering and to prevent overflow
      x = { fraction = 0.5; };
      y = { fraction = 0.3; };
      width = { fraction = 0.3; };
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = true;
      closeOnClick = true;
      showResultsImmediately = false;
      maxEntries = null;
      
      plugins = with pkgs.anyrun; [
        "${anyrun}/lib/libapplications.so"
        "${anyrun}/lib/libshell.so"
        "${anyrun}/lib/libsymbols.so"
        "${anyrun}/lib/libtranslate.so"
        "${anyrun}/lib/libwebsearch.so"
        "${anyrun}/lib/libstdin.so"
      ];
    };

    extraCss = /*css*/ ''
      * {
        font-family: '${fonts.monospace.name}';
        font-size: 14px;
      }

      window {
        background-color: #${colors.base00};
      }

      #entry {
        color: #${colors.base05};
        background-color: #${colors.base00};
      }

      #entry:selected {
        color: #${colors.base05};
        background-color: #${colors.base02};
      }

      #input {
        color: #${colors.base05};
        background-color: #${colors.base01};
      }
    '';
  };
}
