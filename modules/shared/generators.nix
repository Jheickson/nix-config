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
  }
else
  {
    scheme = matugen.matugenScheme;
  }
