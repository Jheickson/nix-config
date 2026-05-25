{ inputs, pkgs, ... }:

{
  nixpkgs = {
    config = {
      allowUnfreePredicate = _: true;
      permittedInsecurePackages = [
        "googleearth-pro-7.3.6.10201"
        "xpdf-4.05"
        "python-2.7.18.12"
      ];
    };
    overlays = [
      (final: prev: {
        nvchad = inputs.nix4nvchad.packages.${pkgs.system}.nvchad;
      })
    ];
  };
}
