{ config, lib, pkgs, ... }:

{
  programs.qutebrowser.enable = true;

  stylix.targets.qutebrowser.enable = true;
}
