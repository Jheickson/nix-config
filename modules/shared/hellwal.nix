{ pkgs, stylixConfig, inputs, ... }:

# Hellwal flag reference (fast C palette generator, github:danihek/hellwal):
#
# Algorithm ("comfort" vs "classic"):
#   --comfort-mode          Perceptual OKLab extraction with explicit contrast
#                           targets against the background (comfort.h). Has own
#                           template renderer for the extra special variables
#                           (accent, selection_*, cursor_text).
#   (default)               Classic median-cut extraction + appearance tweaks.
#
# Appearance ("dark", "light", "color" — stacked in this order):
#   -d/--dark               Dark background, brightened foreground (default
#                           when no appearance flag is given).
#   -l/--light              Reversed palette: light background, dark text.
#   -c/--color              Swaps a few slots for punchy accents. Composes with
#                           --dark/--light (applied after both).
#
# Finish ("original", "neon", "invert", "mono"):
#   (default)               No finish flag.
#   -m/--neon-mode          HSL saturation/lightness boost, classic only.
#                           Comfort handles neon via its own chroma fit.
#   -v/--invert             Channel-inverts the whole palette afterward.
#   "mono"                  No flag: base16-mono.yaml renders the same slots
#                           through .grayscale() (--gray-scale washes toward
#                           white instead of true monochrome).
#
# Also passed always: --no-cache (sandbox HOME rescans each build; never
# reuse host-cached palettes), --skip-term-colors (never write escape codes
# to the build sandbox's /dev/pts), --skip-luminance-sort (stable role
# assignment: sorted luminance shuffles the raw palette, unmapping intended
# dark/light slots).

let
  hellwalPkg = pkgs.stdenv.mkDerivation {
    pname = "hellwal";
    version = "1.0.9";
    src = inputs.hellwal;
    nativeBuildInputs = [ pkgs.gcc ];
    buildPhase = ''
      runHook preBuild
      make hellwal
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      install -Dm755 hellwal $out/bin/hellwal
      runHook postInstall
    '';
  };

  comfortFlag = if stylixConfig.hellwalAlgorithm == "comfort" then "--comfort-mode" else "";

  appearanceFlags =
    if stylixConfig.hellwalAppearance == "light" then "--light"
    else if stylixConfig.hellwalAppearance == "color" then "--color"
    else "--dark";
  finishFlags =
    if stylixConfig.hellwalFinish == "neon" then "--neon-mode"
    else if stylixConfig.hellwalFinish == "invert" then "--invert"
    # --gray-scale washes channels toward white (1.0 = near-white); true
    # mono comes from the template's .grayscale() op instead (see template).
    else "";
  outputs =
    pkgs.runCommand "hellwal-outputs"
      {
        nativeBuildInputs = [ hellwalPkg ];
      }
      ''
        export HOME=$PWD
        mkdir -p templates $out
        # Mono renders through a grayscale variant of the template: hellwal's
        # --gray-scale flag washes toward white instead of true monochrome.
        ${if stylixConfig.hellwalFinish == "mono" then "cp ${./hellwal-templates/base16-mono.yaml} templates/base16.yaml" else "cp ${./hellwal-templates/base16.yaml} templates/base16.yaml"}

        hellwal -i ${stylixConfig.effectiveSchemeSource} \
          ${comfortFlag} \
          ${appearanceFlags} \
          ${finishFlags} \
          --skip-term-colors \
          --skip-luminance-sort \
          --no-cache \
          --template-folder ./templates \
          --output ./generated

        # A template folder with one file yields exactly one output file.
        cp ./generated/base16.yaml $out/base16.yaml

        # Strip the "#" hellwal templates emit; stylix + gowall consumers
        # expect bare hex per the base16 spec. sed keeps the derivation
        # free of a YAML parser dependency.
        sed -i 's/: "#/: "/; s/"#/"/' $out/base16.yaml
      '';
in
{
  hellwalOutputs = outputs;
  hellwalScheme = "${outputs}/base16.yaml";
}
