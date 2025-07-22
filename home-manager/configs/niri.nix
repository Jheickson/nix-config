{
  pkgs,
  lib,
  config,
  host,
  ...
}:
{
  programs.niri = {
    enable = true;
    package = pkgs.niri;

    input = {
      keyboard = {
        layout = "us";
        variant = "colemak_dh_wide";
        options = [
          "caps:backspace"
          "backspace:caps"
        ];
      };
      mouse = {
        accelerationProfile = "flat";
        naturalScrolling = true;
        transformationMatrix = "1 0 0 0 2 0 0 0 1"; # 2x vertical speed
      };
    };

    # settings = {
    #   # Keybindings adapted from i3 config
    #   keybindings = lib.mkOptionDefault {
    #     "XF86AudioMute" = "exec amixer set Master toggle";
    #     "XF86AudioLowerVolume" = "exec amixer set Master 5%-";
    #     "XF86AudioRaiseVolume" = "exec amixer set Master 5%+";
    #     "XF86AudioPlay" = "exec playerctl play-pause";
    #     "XF86AudioPause" = "exec playerctl play-pause";
    #     "XF86AudioNext" = "exec playerctl next";
    #     "XF86AudioPrev" = "exec playerctl previous";
    #     "XF86MonBrightnessUp" = "exec brightnessctl set 10%+";
    #     "XF86MonBrightnessDown" = "exec brightnessctl set 10%-";

    #     "Mod4+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
    #     "Mod4+Shift+d" = "exec ${pkgs.rofi}/bin/rofi -show window -show-icons";
    #     "Mod4+Shift+b" = "exec zen";
    #     "Mod4+Shift+c" = "exec code";
    #     "Mod4+Shift+t" = "exec yazi";

    #     "Mod4+a" = "focus left";
    #     "Mod4+s" = "focus right";
    #     "Mod4+w" = "focus up";
    #     "Mod4+r" = "focus down";

    #     "Mod4+Shift+a" = "move left";
    #     "Mod4+Shift+s" = "move right";
    #     "Mod4+Shift+w" = "move up";
    #     "Mod4+Shift+r" = "move down";

    #     "Mod4+Control+a" = "move-workspace left";
    #     "Mod4+Control+s" = "move-workspace right";

    #     "Mod4+x" = "toggle-fullscreen";
    #     "Mod4+Control+0" = "restart";
    #     "Mod4+Control+r" = "switch-preset-column-width";
    #   };

    # # Startup applications
    # startup = [
    #   # { command = "systemctl --user restart polybar.service"; }
    #   { command = "wasistlos"; }
    #   # { command = "kdeconnect-app"; }
    #   { command = "nm-applet"; }
    # ];
    # };
  };

  # Wayland environment setup
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

  # Disable X11 services
  # services.xserver.enable = false;

  # Wayland-compatible display manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd niri";
        user = "greeter";
      };
    };
  };

  # Wayland-compatible status bar
  programs.waybar.enable = true;
}
