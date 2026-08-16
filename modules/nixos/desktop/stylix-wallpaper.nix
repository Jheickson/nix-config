{
  pkgs,
  ...
}:
# System fonts. (The gowall wallpaper recolor used to live here; it moved to
# modules/home-manager/desktop/stylix-wallpaper.nix so it runs on
# `home-manager switch` too, not only on NixOS activation.)
{
  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      ipafont
      (nerd-fonts.hack)
    ];
  };
}