{ pkgs, stylixConfig, ... }:

{
  matugenScheme =
    pkgs.runCommand "matugen-base16.yaml"
      {
        nativeBuildInputs = [ pkgs.matugen ];
      }
      ''
        export HOME=$PWD
        cat > config.toml <<EOF
        [config]
        [templates.base16]
        input_path  = '${./matugen-templates/base16.yaml}'
        output_path = './base16.yaml'
        EOF
        matugen image ${stylixConfig.wallpaperSource} \
          --mode ${stylixConfig.polarity} \
          --source-color-index 0 \
          --config ./config.toml
        cp base16.yaml $out
      '';
}
