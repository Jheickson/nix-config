{pkgs, config, lib, ...}:

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
      package = nerdfonts.override {fonts = ["FiraCode"];};
      name = "FiraCodeNerdFontMono";
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
      package = pkgs.catppuccin-cursors.frappeMauve;
      name = "Catppuccin-Frappe-Mauve-Cursors";
      size = 8;
    };


    # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    # It can also be generated from an inmage
    image = ./wallpapers/Aesthetic/1328558.png;

  };

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [ipafont (nerdfonts.override {fonts = ["FiraCode"];})];
  };

}