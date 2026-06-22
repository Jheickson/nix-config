{ pkgs, stylixConfig, inputs, ... }:

let
  irisPkg = pkgs.python3Packages.buildPythonApplication {
    pname = "iris";
    version = inputs.iris.shortRev or "dev";
    src = inputs.iris;
    format = "pyproject";
    nativeBuildInputs = with pkgs.python3Packages; [ hatchling ];
    propagatedBuildInputs = with pkgs.python3Packages; [ pillow numpy ];
    doCheck = false;
    meta.mainProgram = "iris";
  };

  polarityFlag = if stylixConfig.polarity == "dark" then "1" else "0";

  outputs =
    pkgs.runCommand "iris-outputs"
      {
        nativeBuildInputs = [ irisPkg ];
      }
      ''
        export HOME=$PWD
        mkdir -p .config/iris/templates

        cp ${./iris-templates/base16.yaml} .config/iris/templates/base16.yaml
        cp ${./iris-templates/nvim.lua} .config/iris/templates/iris.lua

        iris ${stylixConfig.wallpaperSource} --dark ${polarityFlag}

        mkdir -p $out
        cp .cache/iris/base16.yaml $out/
        cp .cache/iris/iris.lua $out/
      '';
in
{
  irisOutputs = outputs;
  irisScheme = "${outputs}/base16.yaml";
  irisNvim = "${outputs}/iris.lua";
}
