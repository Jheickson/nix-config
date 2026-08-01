{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    papirus-icon-theme
    colloid-gtk-theme
  ];

  environment.variables = {
    GTK_ICON_THEME = "Papirus-Dark";
    GTK_THEME = "Colloid-Dark";
  };
}
