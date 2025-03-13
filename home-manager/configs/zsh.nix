{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # enableAutosuggestions = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases =
      let
        flakeDir = "~/nix-config";
      in
      {
        rb = "sudo nixos-rebuild switch --flake ${flakeDir}";
        upd = "sudo nix flake update --flake ${flakeDir}";
        upg = "sudo nixos-rebuild switch --upgrade --flake ${flakeDir}";

        hms = "home-manager switch --flake ${flakeDir}";
        hmsb = "home-manager switch --flake ${flakeDir} -b backup";

        conf = "nvim ${flakeDir}/nixos/configuration.nix";
        pkgs = "nvim ${flakeDir}/nixos/packages.nix";

        ll = "ls -a";
        v = "nvim";
        se = "sudoedit";
        ff = "fastfetch";

        z = "__zoxide_z";
      };

    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "thefuck"
      ];
      theme = "lambda"; # blinks is also really nice
      # TODO Create own zsh theme
    };

  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    thefuck
    zsh-autocomplete
    zsh-autosuggestions
    zoxide
  ];

}
