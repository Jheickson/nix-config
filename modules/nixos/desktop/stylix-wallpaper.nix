{
  pkgs,
  lib,
  stylixConfig,
  inputs,
  ...
}:

let
  generator = import ../../shared/generators.nix { inherit pkgs stylixConfig inputs; };

  # Base16 yaml backing the active scheme: fixed themeFile or generator output.
  schemeYamlPath = if stylixConfig.useThemeFile then stylixConfig.themeFile else generator.scheme;

  # Parse the scheme YAML to get colors
  schemeYaml =
    if stylixConfig.recolorWallpaper then
      builtins.fromJSON (
        builtins.readFile (
          pkgs.runCommand "theme-as-json" { } ''
            ${pkgs.yq-go}/bin/yq -o=json '.' ${schemeYamlPath} > $out
          ''
        )
      )
    else
      null;

  # Generate gowall JSON theme file
  gowallThemeJson =
    if stylixConfig.recolorWallpaper then
      pkgs.writeText "gowall-theme.json" (
        builtins.toJSON {
          name = "stylix";
          colors = [
            schemeYaml.palette.base00
            schemeYaml.palette.base01
            schemeYaml.palette.base02
            schemeYaml.palette.base03
            schemeYaml.palette.base04
            schemeYaml.palette.base05
            schemeYaml.palette.base06
            schemeYaml.palette.base07
            schemeYaml.palette.base08
            schemeYaml.palette.base09
            schemeYaml.palette.base0A
            schemeYaml.palette.base0B
            schemeYaml.palette.base0C
            schemeYaml.palette.base0D
            schemeYaml.palette.base0E
            schemeYaml.palette.base0F
          ];
        }
      )
    else
      null;
in
{
  environment.systemPackages = (lib.optional stylixConfig.recolorWallpaper pkgs.gowall) ++ [
    pkgs.awww
  ];

  # Recolor the applied wallpaper on system activation (only when it differs
  # from the scheme source: fixed theme mode, or generator mode with a
  # dedicated scheme wallpaper)
  system.activationScripts.gowallWallpaper = lib.mkIf stylixConfig.recolorWallpaper ''
    HOME=/home/felipe ${pkgs.gowall}/bin/gowall convert ${stylixConfig.wallpaperSource} -t ${gowallThemeJson} --output ${stylixConfig.wallpaperOutputPath}
  '';

  # Expose the wallpaper path for shell scripts (awww, etc.)
  environment.sessionVariables.STYLIX_WALLPAPER =
    if stylixConfig.recolorWallpaper then
      stylixConfig.wallpaperOutputPath
    else
      toString stylixConfig.wallpaperSource;

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      ipafont
      (nerd-fonts.hack)
    ];
  };
}
