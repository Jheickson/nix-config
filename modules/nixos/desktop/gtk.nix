{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gtk-engine-murrine
    papirus-icon-theme
  ];

  environment.variables = {
    GTK_ICON_THEME = "Papirus-Dark";
  };
}
