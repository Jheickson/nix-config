{ pkgs, ...}: {

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [];
  };


  environment.systemPackages = with pkgs; [

    hello
    cowsay
    neofetch
    zsh

  ];
}