{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nix4nvchad.homeManagerModule
  ];
  programs.nvchad = {
    enable = true;
    extraPackages = with pkgs; [
      nodePackages.bash-language-server
      docker-compose-language-service
      dockerfile-language-server-nodejs
      emmet-language-server
      nixd
    ];
    hm-activation = true;
    backup = true;
  };
}
