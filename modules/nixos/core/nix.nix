{ inputs, ... }:

{
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    settings.auto-optimise-store = true;
    nixPath = [ "nixpkgs = ${inputs.nixpkgs}" ];

    # Automatic garbage collection (disabled — nh wrapper handles it on demand)
    /*
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    */
  };
}
