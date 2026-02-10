{ pkgs, ... }:

{
  # GTK configuration
  environment.systemPackages = with pkgs; [
    gtk-engine-murrine # Required for Numix theme
  ];

  # Set GTK theme for all users
  environment.variables = {
    GTK_THEME = "NumixSolarizedDarkBlue"; # Optional: Set GTK theme
    GTK_ICON_THEME = "Numix"; # Set icon theme
  };

  # Additional GTK configuration for compatibility
  environment.etc."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-icon-theme-name = Numix
    gtk-theme-name = NumixSolarizedDarkBlue
    gtk-font-name = HackNerdFontMono 11
    gtk-cursor-theme-name = XCursor-Pro-Light
    gtk-cursor-theme-size = 20
    gtk-toolbar-style = GTK_TOOLBAR_ICONS
    gtk-toolbar-icon-size = GTK_ICON_SIZE_LARGE_TOOLBAR
    gtk-button-images = 0
    gtk-menu-images = 0
    gtk-enable-animations = 1
    gtk-xft-antialias = 1
    gtk-xft-hinting = 1
    gtk-xft-hintstyle = hintslight
    gtk-xft-rgba = rgb
  '';

  # GTK 4 configuration
  environment.etc."gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-icon-theme-name = Numix
    gtk-theme-name = NumixSolarizedDarkBlue
    gtk-font-name = HackNerdFontMono 11
    gtk-cursor-theme-name = XCursor-Pro-Light
    gtk-cursor-theme-size = 20
    gtk-toolbar-style = GTK_TOOLBAR_ICONS
    gtk-toolbar-icon-size = GTK_ICON_SIZE_LARGE_TOOLBAR
    gtk-button-images = 0
    gtk-menu-images = 0
    gtk-enable-animations = 1
    gtk-xft-antialias = 1
    gtk-xft-hinting = 1
    gtk-xft-hintstyle = hintslight
    gtk-xft-rgba = rgb
  '';
}
