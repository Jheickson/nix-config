{
  pkgs,
  stylixConfig,
  inputs,
  ...
}:

let
  iris = import ./iris.nix { inherit pkgs stylixConfig inputs; };
  matugen = import ./matugen.nix { inherit pkgs stylixConfig; };
  hellwal = import ./hellwal.nix { inherit pkgs stylixConfig inputs; };
in
if stylixConfig.generator == "iris" then
  {
    scheme = iris.irisScheme;
  }
else if stylixConfig.generator == "hellwal" then
  {
    scheme = hellwal.hellwalScheme;
  }
else
  {
    scheme = matugen.matugenScheme;
  }
