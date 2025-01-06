{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = {
      font-family = "Hack";
      window-padding-x = 32;
      window-padding-y = 32;
    };
  };
}