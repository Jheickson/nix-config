{pkgs, ...}:

{

  stylix = {

    enable = true;
    autoEnable = true;

    polarity = "dark";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    # It can also be generated from an inmage
    image = ./wallpapers/Themed/catpuccin_tetris.png;

  };

}