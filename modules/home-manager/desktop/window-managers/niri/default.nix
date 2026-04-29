{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.niri.homeModules.niri
    ./settings.nix
    ./binds.nix
    ./rules.nix
    ./blur.nix
    #./swayidle.nix
  ];

  home = {
    packages = with pkgs; [
      seatd
      jaq
      brightnessctl
    ];
  };
}
