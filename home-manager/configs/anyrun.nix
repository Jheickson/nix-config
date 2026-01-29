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
      @define-color bg-color #${colors.base00};
      @define-color fg-color #${colors.base05};
      @define-color accent #${colors.base0D};

      * {
        font-family: '${fonts.monospace.name}';
      }

      window {
        background: transparent;
      }

      box.main {
        background-color: @bg-color;
      }

      text {
        color: @fg-color;
      }

      label.match {
        color: @fg-color;
      }

      .match:selected {
        background-color: #${colors.base02};
      }
    '';
  };
}
