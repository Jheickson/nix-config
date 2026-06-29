{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    papirus-icon-theme
    orchis-theme
  ];

  environment.variables = {
    GTK_ICON_THEME = "Papirus-Dark";
    GTK_THEME = "Orchis-Dark";
  };
}
