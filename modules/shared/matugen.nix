{ pkgs, stylixConfig, ... }:

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
