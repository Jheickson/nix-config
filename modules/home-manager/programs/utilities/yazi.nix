{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    # Shell wrapper (cd-on-exit): `y` opens Yazi and cds back on quit.
    shellWrapperName = "y";

    extraPackages = with pkgs; [
      bat
      fd
      ripgrep
      ueberzugpp
      ouch
      poppler-utils # PDF preview
      udisks # mount.yazi: udisksctl
      util-linux # mount.yazi: lsblk + eject
    ];

    settings = {
      mgr.show_hidden = true;

      # git.yazi: expose git status to the file list
      plugin.prepend_fetchers = [
        {
          url = "*";
          run = "git";
          group = "git";
        }
        {
          url = "*/";
          run = "git";
          group = "git";
        }
      ];
      # toggle-pane tip: raise caps so a maximized preview uses the space
      preview = {
        max_width = 1000;
        max_height = 1000;
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "l";
          run = "plugin smart-enter";
          desc = "Enter directory or open file";
        }
        {
          on = "M";
          run = "plugin mount";
          desc = "Manage disk mounts";
        }
        {
          on = "T";
          run = "plugin toggle-pane max-preview";
          desc = "Maximize or restore the preview pane";
        }
        {
          on = "F";
          run = "plugin smart-filter";
          desc = "Smart filter";
        }
        {
          on = [
            "c"
            "m"
          ];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
      ];
    };

    plugins = {
      git = {
        package = pkgs.yaziPlugins.git;
        setup = true;
        settings.order = 1500;
      };
      smart-enter = pkgs.yaziPlugins.smart-enter;
      mount = pkgs.yaziPlugins.mount;
      toggle-pane = pkgs.yaziPlugins.toggle-pane;
      smart-filter = pkgs.yaziPlugins.smart-filter;
      chmod = pkgs.yaziPlugins.chmod;
    };
  };
}
