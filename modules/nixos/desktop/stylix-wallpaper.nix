{
  pkgs,
  lib,
  stylixConfig,
  ...
}:

let
  # Parse the YAML theme file to get colors
  themeYaml = if stylixConfig.useThemeFile then
    builtins.fromJSON (
      builtins.readFile (
        pkgs.runCommand "theme-as-json" { } ''
          ${pkgs.yq-go}/bin/yq -o=json '.' ${stylixConfig.themeFile} > $out
        ''
      )
    )
  else
    null;

  # Generate gowall JSON theme file
  gowallThemeJson = if stylixConfig.useThemeFile then
    pkgs.writeText "gowall-theme.json" (builtins.toJSON {
      name = "stylix";
      colors = [
        themeYaml.palette.base00
        themeYaml.palette.base01
        themeYaml.palette.base02
        themeYaml.palette.base03
        themeYaml.palette.base04
        themeYaml.palette.base05
        themeYaml.palette.base06
        themeYaml.palette.base07
        themeYaml.palette.base08
        themeYaml.palette.base09
        themeYaml.palette.base0A
        themeYaml.palette.base0B
        themeYaml.palette.base0C
        themeYaml.palette.base0D
        themeYaml.palette.base0E
        themeYaml.palette.base0F
      ];
    })
  else
    null;
in
{
  environment.systemPackages = (lib.optional stylixConfig.useThemeFile pkgs.gowall) ++ [ pkgs.swww ];

  # Generate themed wallpaper on system activation (only when stylixConfig.useThemeFile = true)
  system.activationScripts.gowallWallpaper = lib.mkIf stylixConfig.useThemeFile ''
    HOME=/home/felipe ${pkgs.gowall}/bin/gowall convert ${stylixConfig.wallpaperSource} -t ${gowallThemeJson} --output ${stylixConfig.wallpaperOutputPath}
  '';

  # Expose the wallpaper path for shell scripts (swww, etc.)
  environment.sessionVariables.STYLIX_WALLPAPER = if stylixConfig.useThemeFile then
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