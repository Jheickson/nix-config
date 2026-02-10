{ config, pkgs, lib }:

let
  colors = config.lib.stylix.colors;

  # Generate colors.css dynamically from Stylix colors
  colorsFile = ''
    /* Auto-generated from Stylix colors */

    @define-color background #${colors.base00};
    @define-color surface #${colors.base01};
    @define-color surface_bright #${colors.base02};
    @define-color surface_container #${colors.base03};
    @define-color overlay #${colors.base04};
    @define-color text #${colors.base05};
    @define-color subtext #${colors.base06};

    /* Status colors - mapped from base16 palette */
    @define-color on_surface #${colors.base05};
    @define-color on_primary_container #${colors.base00};
    @define-color primary_container #${colors.base0D};
    @define-color error_container #${colors.base08};

    /* Additional semantic colors */
    @define-color success #${colors.base0B};
    @define-color warning #${colors.base0A};
    @define-color error #${colors.base08};
    @define-color info #${colors.base0D};
  '';
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings = lib.mkForce {}; # allow external config file without collisions
    style = lib.mkForce null; # allow external style file without collisions
  };

  # Create the colors.css file in the waybar config directory
  xdg.configFile."waybar/colors.css".text = colorsFile;

  # Symlink config for live editing without rebuilds
  xdg.configFile."waybar/config".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home-manager/configs/waybar/configs/yagnikpt/config.json";

  # Symlink style.css for live editing without rebuilds
  xdg.configFile."waybar/style.css".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home-manager/configs/waybar/configs/yagnikpt/style.css";

  home.packages = with pkgs; [
    playerctl
    curl
  ];
}
