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
      # External GUI handlers. prepend_rules keeps yazi's built-in rules
      # (text → $EDITOR, media, archives, …) intact; new `opener` keys are
      # merged with the defaults, so `open`/`edit`/`reveal` still work.
      opener = {
        # Word-processor formats (docx via AbiWord's OOXML importer)
        abiword = [
          {
            run = "abiword %s";
            orphan = true; # GUI app: detach, don't block the yazi TUI
            desc = "AbiWord";
          }
        ];
        # Raster images, for annotation
        swappy = [
          {
            run = "swappy -f %s1";
            orphan = true;
            desc = "Swappy";
          }
        ];
        # PDFs, instead of the browser xdg-mime currently picks
        evince = [
          {
            run = "evince %s";
            orphan = true;
            desc = "Evince";
          }
        ];
        # HTML, which yazi's text/* rule would otherwise open in $EDITOR
        zen = [
          {
            run = "zen-beta %s";
            orphan = true;
            desc = "Zen";
          }
        ];
      };
      open.prepend_rules = [
        {
          url = "*.{docx,doc,dot,odt,ott,rtf,abw,zabw}";
          use = "abiword";
        }
        {
          # No SVG: gdk-pixbuf in this closure has no SVG loader, so SVG keeps
          # falling back to xdg-open (Chromium)
          url = "*.{png,jpg,jpeg,gif,bmp,webp,tiff,tif,avif}";
          use = "swappy";
        }
        {
          mime = "application/pdf";
          use = "evince";
        }
        {
          mime = "text/html";
          use = "zen";
        }
        {
          url = "*.{html,htm,xhtml}";
          use = "zen";
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
