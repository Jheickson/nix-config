{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    enableZshIntegration = true;
    installVimSyntax = true;

    settings = {
      # Match the Alacritty profile
      font-family = "Hack Nerd Font";
      font-size = 12;
      window-padding-x = 0;
      window-padding-y = 0;
      window-decoration = "auto";

      # Shell integration
      shell-integration = "zsh";
    };
  };
}
