{ config, pkgs, ... }:

{
  # Xfce desktop environment, selectable from the greeter.
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # regreet launches X11 sessions via its `startx /usr/bin/env` prefix, which
  # NixOS does not install from services.xserver.enable alone.
  #
  # The generated Xfce session .desktop lives in
  # services.displayManager.sessionPackages; under standalone greetd it is not
  # automatically added to systemPackages, so we pull it in explicitly.
  environment.systemPackages = [
    pkgs.xorg.xinit
  ] ++ config.services.displayManager.sessionPackages;
}
