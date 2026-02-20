{
  pkgs,
  config,
  lib,
  ...
}:

# https://github.com/vimjoyer/stylix-video
# https://nix-community.github.io/stylix/tricks.html

let
  # ============================================================================
  # CONFIGURATION - Customize theme and wallpaper behavior
  # ============================================================================

  # Toggle between preset theme-based coloring or Stylix auto-generation
  # When true (default): Uses a Base16 theme file and gowall to colorize wallpaper
  # When false: Lets Stylix auto-generate palette from wallpaper directly
  useThemeFile = true;

  # ============================================================================
  # WALLPAPER CONFIGURATION - Change these values to update your wallpaper
  # ============================================================================

  # The source wallpaper image
  wallpaperSource = ../../../assets/wallpapers/Other/wallhaven-qrjq8l.png;

  # Theme file - determines the color palette (only used when useThemeFile = true)
  themeFile = "${pkgs.base16-schemes}/share/themes/atelier-sulphurpool.yaml";

  # ============================================================================
  # GOWALL THEME JSON - Generated at build time from the base16 theme
  # (Only generated when useThemeFile = true)
  # ============================================================================

  # Parse the YAML theme file to get colors
  themeYaml = if useThemeFile then
    builtins.fromJSON (
      builtins.readFile (
        pkgs.runCommand "theme-as-json" { } ''
          ${pkgs.yq-go}/bin/yq -o=json '.' ${themeFile} > $out
        ''
      )
    )
  else
    null;

  # Generate gowall JSON theme file
  gowallThemeJson = if useThemeFile then
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

  environment.systemPackages = (lib.optional useThemeFile pkgs.gowall) ++ [ pkgs.swww ];

  # Generate themed wallpaper on system activation (only when useThemeFile = true)
  system.activationScripts.gowallWallpaper = lib.mkIf useThemeFile ''
    HOME=/home/felipe ${pkgs.gowall}/bin/gowall convert ${wallpaperSource} -t ${gowallThemeJson} --output /home/felipe/nix-config/assets/wallpapers/wallpaper.png
  '';

  stylix = {

    enable = true;
    autoEnable = true;

    polarity = "dark";

    targets = {

      # vscode.enable = true; # Doesn't exist

    };

    opacity = {
      terminal = 0.75;
    };

    fonts = with pkgs; rec {
      monospace = {
        package = nerd-fonts.hack;
        name = "HackNerdFontMono";
      };
      sansSerif = monospace;
      serif = monospace;
    };

    cursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";

      # package = pkgs.xcursor-pro;
      # name = "XCursor-Pro-Light";

      # package = pkgs.bibata-cursors;
      # name = "Bibata-Modern-Ice";

    #   package = pkgs.qogir-icon-theme;
    #   name = "Qogir Cursors";

      size = 16;
    };

    image = if useThemeFile then
      ../../../assets/wallpapers/wallpaper.png
    else
      wallpaperSource;
  } // lib.optionalAttrs useThemeFile {
    base16Scheme = themeFile;
  };

  # Expose the wallpaper path for shell scripts (swww, etc.)
  environment.sessionVariables.STYLIX_WALLPAPER = if useThemeFile then
    "~/nix-config/assets/wallpapers/wallpaper.png"
  else
    toString wallpaperSource;

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      ipafont
      (nerd-fonts.hack)
    ];
  };

}

/*

nix build nixpkgs#base16-schemes && tree result/ -L 3
result/
└── share
    └── themes
        ├── 0x96f.yaml
        ├── 3024.yaml
        ├── apathy.yaml
        ├── apprentice.yaml
        ├── ascendancy.yaml
        ├── ashes.yaml
        ├── atelier-cave-light.yaml
        ├── atelier-cave.yaml
        ├── atelier-dune-light.yaml
        ├── atelier-dune.yaml
        ├── atelier-estuary-light.yaml
        ├── atelier-estuary.yaml
        ├── atelier-forest-light.yaml
        ├── atelier-forest.yaml
        ├── atelier-heath-light.yaml
        ├── atelier-heath.yaml
        ├── atelier-lakeside-light.yaml
        ├── atelier-lakeside.yaml
        ├── atelier-plateau-light.yaml
        ├── atelier-plateau.yaml
        ├── atelier-savanna-light.yaml
        ├── atelier-savanna.yaml
        ├── atelier-seaside-light.yaml
        ├── atelier-seaside.yaml
        ├── atelier-sulphurpool-light.yaml
        ├── atelier-sulphurpool.yaml
        ├── atlas.yaml
        ├── ayu-dark.yaml
        ├── ayu-light.yaml
        ├── ayu-mirage.yaml
        ├── aztec.yaml
        ├── bespin.yaml
        ├── black-metal-bathory.yaml
        ├── black-metal-burzum.yaml
        ├── black-metal-dark-funeral.yaml
        ├── black-metal-gorgoroth.yaml
        ├── black-metal-immortal.yaml
        ├── black-metal-khold.yaml
        ├── black-metal-marduk.yaml
        ├── black-metal-mayhem.yaml
        ├── black-metal-nile.yaml
        ├── black-metal-venom.yaml
        ├── black-metal.yaml
        ├── blueforest.yaml
        ├── blueish.yaml
        ├── brewer.yaml
        ├── bright.yaml
        ├── brogrammer.yaml
        ├── brushtrees-dark.yaml
        ├── brushtrees.yaml
        ├── caroline.yaml
        ├── catppuccin-frappe.yaml
        ├── catppuccin-latte.yaml
        ├── catppuccin-macchiato.yaml
        ├── catppuccin-mocha.yaml
        ├── chalk.yaml
        ├── charcoal-dark.yaml
        ├── charcoal-light.yaml
        ├── chicago-day.yaml
        ├── chicago-night.yaml
        ├── chinoiserie-midnight.yaml
        ├── chinoiserie-morandi.yaml
        ├── chinoiserie-night.yaml
        ├── chinoiserie.yaml
        ├── circus.yaml
        ├── classic-dark.yaml
        ├── classic-light.yaml
        ├── codeschool.yaml
        ├── colors.yaml
        ├── cupcake.yaml
        ├── cupertino.yaml
        ├── da-one-black.yaml
        ├── da-one-gray.yaml
        ├── da-one-ocean.yaml
        ├── da-one-paper.yaml
        ├── da-one-sea.yaml
        ├── da-one-white.yaml
        ├── danqing-light.yaml
        ├── danqing.yaml
        ├── darcula.yaml
        ├── darkmoss.yaml
        ├── darktooth.yaml
        ├── darkviolet.yaml
        ├── decaf.yaml
        ├── deep-oceanic-next.yaml
        ├── default-dark.yaml
        ├── default-light.yaml
        ├── digital-rain.yaml
        ├── dirtysea.yaml
        ├── dracula.yaml
        ├── edge-dark.yaml
        ├── edge-light.yaml
        ├── eighties.yaml
        ├── eldritch.yaml
        ├── embers-light.yaml
        ├── embers.yaml
        ├── emil.yaml
        ├── equilibrium-dark.yaml
        ├── equilibrium-gray-dark.yaml
        ├── equilibrium-gray-light.yaml
        ├── equilibrium-light.yaml
        ├── eris.yaml
        ├── espresso.yaml
        ├── eva-dim.yaml
        ├── eva.yaml
        ├── evenok-dark.yaml
        ├── everforest-dark-hard.yaml
        ├── everforest-dark-medium.yaml
        ├── everforest-dark-soft.yaml
        ├── everforest.yaml
        ├── flat.yaml
        ├── flexoki-dark.yaml
        ├── flexoki-light.yaml
        ├── framer.yaml
        ├── fruit-soda.yaml
        ├── gigavolt.yaml
        ├── github-dark.yaml
        ├── github.yaml
        ├── google-dark.yaml
        ├── google-light.yaml
        ├── gotham.yaml
        ├── grayscale-dark.yaml
        ├── grayscale-light.yaml
        ├── greenscreen.yaml
        ├── gruber.yaml
        ├── gruvbox-dark-hard.yaml
        ├── gruvbox-dark-medium.yaml
        ├── gruvbox-dark-pale.yaml
        ├── gruvbox-dark-soft.yaml
        ├── gruvbox-dark.yaml
        ├── gruvbox-light-hard.yaml
        ├── gruvbox-light-medium.yaml
        ├── gruvbox-light-soft.yaml
        ├── gruvbox-light.yaml
        ├── gruvbox-material-dark-hard.yaml
        ├── gruvbox-material-dark-medium.yaml
        ├── gruvbox-material-dark-soft.yaml
        ├── gruvbox-material-light-hard.yaml
        ├── gruvbox-material-light-medium.yaml
        ├── gruvbox-material-light-soft.yaml
        ├── hardcore.yaml
        ├── hardhacker.yaml
        ├── harmonic16-dark.yaml
        ├── harmonic16-light.yaml
        ├── heetch-light.yaml
        ├── heetch.yaml
        ├── helios.yaml
        ├── hopscotch.yaml
        ├── horizon-dark.yaml
        ├── horizon-light.yaml
        ├── horizon-terminal-dark.yaml
        ├── horizon-terminal-light.yaml
        ├── humanoid-dark.yaml
        ├── humanoid-light.yaml
        ├── ia-dark.yaml
        ├── ia-light.yaml
        ├── icy.yaml
        ├── irblack.yaml
        ├── isotope.yaml
        ├── jabuti.yaml
        ├── kanagawa-dragon.yaml
        ├── kanagawa.yaml
        ├── katy.yaml
        ├── kimber.yaml
        ├── lime.yaml
        ├── linux-vt.yaml
        ├── macintosh.yaml
        ├── marrakesh.yaml
        ├── materia.yaml
        ├── material-darker.yaml
        ├── material-lighter.yaml
        ├── material-palenight.yaml
        ├── material-vivid.yaml
        ├── material.yaml
        ├── measured-dark.yaml
        ├── measured-light.yaml
        ├── mellow-purple.yaml
        ├── mexico-light.yaml
        ├── mocha.yaml
        ├── monokai.yaml
        ├── moonlight.yaml
        ├── mountain.yaml
        ├── nebula.yaml
        ├── nord-light.yaml
        ├── nord.yaml
        ├── nova.yaml
        ├── ocean.yaml
        ├── oceanicnext.yaml
        ├── one-light.yaml
        ├── onedark-dark.yaml
        ├── onedark.yaml
        ├── outrun-dark.yaml
        ├── oxocarbon-dark.yaml
        ├── oxocarbon-light.yaml
        ├── pandora.yaml
        ├── papercolor-dark.yaml
        ├── papercolor-light.yaml
        ├── paraiso.yaml
        ├── pasque.yaml
        ├── penumbra-dark-contrast-plus-plus.yaml
        ├── penumbra-dark-contrast-plus.yaml
        ├── penumbra-dark.yaml
        ├── penumbra-light-contrast-plus-plus.yaml
        ├── penumbra-light-contrast-plus.yaml
        ├── penumbra-light.yaml
        ├── phd.yaml
        ├── pico.yaml
        ├── pinky.yaml
        ├── pop.yaml
        ├── porple.yaml
        ├── precious-dark-eleven.yaml
        ├── precious-dark-fifteen.yaml
        ├── precious-light-warm.yaml
        ├── precious-light-white.yaml
        ├── primer-dark-dimmed.yaml
        ├── primer-dark.yaml
        ├── primer-light.yaml
        ├── purpledream.yaml
        ├── qualia.yaml
        ├── railscasts.yaml
        ├── rebecca.yaml
        ├── rose-pine-dawn.yaml
        ├── rose-pine-moon.yaml
        ├── rose-pine.yaml
        ├── saga.yaml
        ├── sagelight.yaml
        ├── sakura.yaml
        ├── sandcastle.yaml
        ├── selenized-black.yaml
        ├── selenized-dark.yaml
        ├── selenized-light.yaml
        ├── selenized-white.yaml
        ├── seti.yaml
        ├── shades-of-purple.yaml
        ├── shadesmear-dark.yaml
        ├── shadesmear-light.yaml
        ├── shapeshifter.yaml
        ├── silk-dark.yaml
        ├── silk-light.yaml
        ├── snazzy.yaml
        ├── soft-server.yaml
        ├── solarflare-light.yaml
        ├── solarflare.yaml
        ├── solarized-dark.yaml
        ├── solarized-light.yaml
        ├── spaceduck.yaml
        ├── spacemacs.yaml
        ├── sparky.yaml
        ├── standardized-dark.yaml
        ├── standardized-light.yaml
        ├── stella.yaml
        ├── still-alive.yaml
        ├── summercamp.yaml
        ├── summerfruit-dark.yaml
        ├── summerfruit-light.yaml
        ├── synth-midnight-dark.yaml
        ├── synth-midnight-light.yaml
        ├── tango.yaml
        ├── tarot.yaml
        ├── tender.yaml
        ├── terracotta-dark.yaml
        ├── terracotta.yaml
        ├── tokyo-city-dark.yaml
        ├── tokyo-city-light.yaml
        ├── tokyo-city-terminal-dark.yaml
        ├── tokyo-city-terminal-light.yaml
        ├── tokyo-night-dark.yaml
        ├── tokyo-night-light.yaml
        ├── tokyo-night-moon.yaml
        ├── tokyo-night-storm.yaml
        ├── tokyo-night-terminal-dark.yaml
        ├── tokyo-night-terminal-light.yaml
        ├── tokyo-night-terminal-storm.yaml
        ├── tokyodark-terminal.yaml
        ├── tokyodark.yaml
        ├── tomorrow-night-eighties.yaml
        ├── tomorrow-night.yaml
        ├── tomorrow.yaml
        ├── tube.yaml
        ├── twilight.yaml
        ├── unikitty-dark.yaml
        ├── unikitty-light.yaml
        ├── unikitty-reversible.yaml
        ├── uwunicorn.yaml
        ├── valua.yaml
        ├── vesper.yaml
        ├── vice.yaml
        ├── vulcan.yaml
        ├── windows-10-light.yaml
        ├── windows-10.yaml
        ├── windows-95-light.yaml
        ├── windows-95.yaml
        ├── windows-highcontrast-light.yaml
        ├── windows-highcontrast.yaml
        ├── windows-nt-light.yaml
        ├── windows-nt.yaml
        ├── woodland.yaml
        ├── xcode-dusk.yaml
        ├── yesterday-bright.yaml
        ├── yesterday-night.yaml
        ├── yesterday.yaml
        ├── zenbones.yaml
        └── zenburn.yaml
-L [error opening dir]
3 [error opening dir]

2 directories, 303 files

*/