{ pkgs, lib, ... }:

# let
#   wallpaper = "~/.config/home-manager/wallpapers/Themed/catpuccin_tetris.png";
# in

{

  xsession.scriptPath = ".hm-xsession";

  xsession.windowManager.i3 = {
    enable = true;

    package = pkgs.i3;

    # extraConfig = ''
    #   # Keybind to toggle i3 to tabbed layout
    #   bindsym Mod4+Control+W workspace_layout tabbed
    # '';

    config = rec {
      modifier = "Mod4";
      bars = [ ];

      window = {
        border = 2;
        titlebar = false;
        hideEdgeBorders = "smart";
      };

      workspaceAutoBackAndForth = true;

      # font = "pango:FiraCode 20";

      gaps = {
        inner = 10;
        outer = 15;
      };

      keybindings = lib.mkOptionDefault {
        "XF86AudioMute" = "exec --no-startup-id amixer set Master toggle";
        "XF86AudioLowerVolume" = "exec --no-startup-id amixer set Master 5%-";
        "XF86AudioRaiseVolume" = "exec --no-startup-id amixer set Master 5%+";

        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioPause" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";

        "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl set 10%+";
        "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl set 10%-";

        "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        # "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -modi drun -show drun -show-icons";
        "${modifier}+Shift+d" = "exec ${pkgs.rofi}/bin/rofi -show window -show-icons";
        "${modifier}+Shift+b" = "exec zen";
        "${modifier}+Shift+c" = "exec code";
        "${modifier}+Shift+t" = "exec yazi";

        # "${modifier}+Shift+x" = "exec systemctl suspend";

        "${modifier}+a" = "focus left";
        "${modifier}+s" = "focus right";
        "${modifier}+w" = "focus up";
        "${modifier}+r" = "focus down";

        "${modifier}+Shift+a" = "move left";
        "${modifier}+Shift+s" = "move right";
        "${modifier}+Shift+w" = "move up";
        "${modifier}+Shift+r" = "move down";

        "${modifier}+Control+a" = "move workspace to output left";
        "${modifier}+Control+s" = "move workspace to output right";

        "${modifier}+x" = "fullscreen toggle";
        "${modifier}+Control+0" = "restart";
        "${modifier}+Control+r" = "mode resize";

        # "${modifier}+Control+W" = "workspace_layout tabbed"; 
        # TODO Implement keybind to toggle tabbed layout on i3 (https://i3wm.org/docs/userguide.html#_layout_mode_for_new_containers)

        # "${modifier}+Alt_L+a" = "resize shrink width 5 px or 5 ppt";
        # "${modifier}+Alt_L+r" = "resize grow height 5 px or 5 ppt";
        # "${modifier}+Alt_L+w" = "resize shrink height 5 px or 5 ppt";
        # "${modifier}+Alt_L+s" = "resize grow width 5 px or 5 ppt";

      };

      startup = [
        {
          command = "exec i3-msg workspace 1";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart polybar.service";
          # command = "polybar -q -r momiji";
          always = true;
          notification = false;
        }
        # {
        #   command = "${pkgs.feh}/bin/feh --bg-fill ${wallpaper}";
        #   always = true;
        #   notification = false;
        # }
        {
          command = "picom -f";
          always = true;
          notification = false;
        }
        # {
        #   command = "wal -i ${wallpaper}";
        #   always = true;
        #   notification = false;
        # }
        {
          command = "whatsapp-for-linux";
          always = true;
          notification = true;
        }
      ];
    };
  };
}