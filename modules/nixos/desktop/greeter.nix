{ ... }:

{
  # Graphical login greeter with a session picker (Niri / Xfce / others).
  # regreet runs inside `cage` (a kiosk Wayland compositor) and is registered
  # as greetd's default session command. It discovers sessions from the
  # `wayland-sessions` / `xsessions` .desktop files found via XDG_DATA_DIRS.
  #
  # With standalone greetd (not an xserver-integrated display manager) NixOS
  # does not link those session dirs into the profile, so we opt in explicitly.
  programs.regreet.enable = true;
  # Wrap X11 sessions with startx so greetd actually starts an X server
  # (greetd does not start Xorg itself). /usr/bin/env exists on NixOS.
  programs.regreet.settings.commands.x11_prefix = [
    "startx"
    "/usr/bin/env"
  ];

  environment.pathsToLink = [
    "/share/xsessions"
    "/share/wayland-sessions"
  ];
}
