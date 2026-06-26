{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ zed-editor ];

  stylix.targets.zed.enable = true;
}
