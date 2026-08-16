{
  pkgs,
  stylixConfig,
  inputs,
  ...
}:

let
  iris = import ./iris.nix { inherit pkgs stylixConfig inputs; };
  matugen = import ./matugen.nix { inherit pkgs stylixConfig; };
in
if stylixConfig.generator == "iris" then
  {
    scheme = iris.irisScheme;
    nvim = iris.irisNvim;
  }
else
  {
    scheme = matugen.matugenScheme;
    nvim = matugen.matugenNvim;
  }
