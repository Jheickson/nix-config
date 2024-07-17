{pkgs, config, lib, ...}:

# https://github.com/vimjoyer/stylix-video

{

  stylix = {

    enable = true;
    autoEnable = true;

    polarity = "dark";

    targets = {

      # vscode.enable = true; # Doesn't exist

    };

    opacity = {
      terminal = 0.75;
    };

  fonts = with pkgs; rec {
    monospace = {
      package = nerdfonts.override {fonts = ["Hack"];};
      name = "HackNerdFontMono";
    };
    sansSerif = monospace;
    serif = monospace;
  };

    # cursor = {

    #   # package = pkgs.volantes-cursors;
    #   package = pkgs.qogir-icon-theme;
    #   name = "Qogir Cursors";
    #   size = 24;

    # };

    cursor = {
      # package = pkgs.bibata-cursors;
      # name = "Bibata-Modern-Ice";

      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";

      size = 8;
    };

    # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    # It can also be generated from an inmage
    image = ./wallpapers/Landscape/wallhaven-1poo61_2560x1440.png;

  };

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [ipafont (nerdfonts.override {fonts = ["Hack"];})];
  };

}