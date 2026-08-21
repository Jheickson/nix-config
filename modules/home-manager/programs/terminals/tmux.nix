{ ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    newSession = true;
    shortcut = "a";
    escapeTime = 10;

    extraConfig = ''
      set-option -g history-limit 100000
      set -g mouse on
    '';
  };
}
