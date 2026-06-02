{ pkgs, stylixConfig, ... }:

# Matugen flag reference (Material You palette generator):
#
# --type <SCHEME>          How the source color seeds the rest of the palette.
#   scheme-tonal-spot      [DEFAULT] Stock Material 3. Balanced, vibrant accents.
#   scheme-content         Preserves source hue + chroma. Wallpaper-faithful.
#   scheme-fidelity        Like content, stronger fidelity. [current pick]
#   scheme-expressive      Rotates hue for punchy accents far from source.
#   scheme-vibrant         High chroma everywhere.
#   scheme-neutral         Low chroma, muted/washed.
#   scheme-monochrome      Greyscale only. No accents.
#   scheme-fruit-salad     Multi-hue, accents from far rotations. Playful.
#   scheme-rainbow         Accents spread across hue wheel.
#
# --source-color-index <N> Pick the Nth dominant color (0-3) from k-means
#                          quantization of the image as the seed for the
#                          palette. Without this flag matugen prompts
#                          interactively (which breaks in a nix sandbox).
#                          Try 0 first; bump to 1 if dominant gives a muddy
#                          palette (often the case for landscape photos where
#                          0 is sky/ground). Alternative: --source-color "#hex"
#                          to bypass extraction and set the seed manually.
#
# --mode {dark|light}      Polarity of the generated palette. Threaded from
#                          stylixConfig.polarity so stylix + matugen agree.

let
  outputs =
    pkgs.runCommand "matugen-outputs"
      {
        nativeBuildInputs = [ pkgs.matugen ];
      }
      ''
        export HOME=$PWD
        mkdir -p $out
        cat > config.toml <<EOF
        [config]
        [templates.base16]
        input_path  = '${./matugen-templates/base16.yaml}'
        output_path = './base16.yaml'
        [templates.nvim]
        input_path  = '${./matugen-templates/nvim.lua}'
        output_path = './matugen.lua'
        EOF
        matugen image ${stylixConfig.wallpaperSource} \
          --type scheme-fidelity \
          --source-color-index 1 \
          --mode ${stylixConfig.polarity} \
          --config ./config.toml
        cp base16.yaml $out/
        cp matugen.lua $out/
      '';
in
{
  matugenOutputs = outputs;
  matugenScheme = "${outputs}/base16.yaml";
  matugenNvim = "${outputs}/matugen.lua";
}
