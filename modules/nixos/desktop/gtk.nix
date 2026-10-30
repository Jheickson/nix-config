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
  # Nemo needs gvfs for trash/network mounts and dconf for its preferences
  # (incl. the "Open in Terminal" override in programs/utilities/nemo.nix).
  services.gvfs.enable = true;
  programs.dconf.enable = true;
}
