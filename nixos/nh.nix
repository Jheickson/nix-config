{ config, pkgs, ... }:

{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 10";
    flake = "~/nix-config"; # sets NH_OS_FLAKE variable for you
  };
}
