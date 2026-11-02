{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.umbriel.homeModules.default
    ./settings.nix
    ./keybinds.nix
    ./rules.nix
    ./appearance.nix
  ];

  home = {
    packages = with pkgs; [
      seatd
      jaq
      brightnessctl
      cliphist
    ];
  };
}
