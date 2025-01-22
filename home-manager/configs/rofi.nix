{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.rofi = {
    enable = true;
    # font = "Hack Nerd Font 12"; # Let Stylix manage this
    # theme = "~/.cache/wal/colors-rofi-dark.rasi";
  };

  home.packages = with pkgs; [
    rofi-calc
    rofi-screenshot
    rofi-power-menu
  ];

  xsession.windowManager.i3.config.keybindings =
    let
      modifier = config.xsession.windowManager.i3.config.modifier;
    in
    lib.mkOptionDefault {
      "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -modi drun -show drun -show-icons";

      # Rofi calc keybinding
      "${modifier}+c" = "exec ${pkgs.rofi}/bin/rofi -modi calc -show calc -no-show-match -no-sort";

      # Rofi screenshot keybinding
      "${modifier}+Alt+s" = "exec ${pkgs.rofi}/bin/rofi -modi screenshot -show screenshot";

      # Rofi power menu keybinding
      "${modifier}+p" = "exec ${pkgs.rofi}/bin/rofi -modi power-menu -show power-menu";
    };
}
