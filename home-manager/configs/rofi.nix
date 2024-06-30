{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    font = "Hack Nerd Font 12";
    # theme = "~/.cache/wal/colors-rofi-dark.rasi";
  };

  home.packages = with pkgs; [
    rofi-calc
    rofi-screenshot
    rofi-power-menu
  ];
  # TODO Create shortcuts to use these
}