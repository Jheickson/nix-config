# Nemo — main graphical file manager (yazi stays for terminal work).
# Makes Nemo the default directory handler and points its "Open in
# Terminal" at ghostty (gnome-terminal isn't installed).
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "nemo.desktop";
    };
  };

  dconf.settings = {
    "org/cinnamon/desktop/default-applications/terminal" = {
      exec = "ghostty";
    };
  };
}
