{ pkgs, lib, ... }:

{
  # Use pkgs.noctalia-shell from nixpkgs (v4) instead of the upstream flake's
  # HM module — v5 is still rough and the build was slow. Config is the legacy
  # JSON format dropped at ~/.config/noctalia/settings.json.
  home.packages = [ pkgs.noctalia-shell ];

  xdg.configFile."noctalia/settings.json".source = ./settings.json;

  # Reload noctalia-shell on `hms`. Kill if running, then ask niri to spawn
  # a fresh instance via IPC so the process is parented by the niri session.
  # Skips silently when niri is not running (e.g. hms from tty/ssh).
  home.activation.reload-noctalia = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ${pkgs.procps}/bin/pgrep -x niri >/dev/null 2>&1; then
      ${pkgs.procps}/bin/pkill -x noctalia-shell || true
      sleep 0.3
      ${pkgs.niri}/bin/niri msg action spawn -- noctalia-shell || true
    fi
  '';

  # Configure wallpapers declaratively (optional)
  home.file.".cache/noctalia/wallpapers.json" = {
    text = builtins.toJSON {
      defaultWallpaper = "/home/felipe/nix-config/assets/wallpapers/wallpaper.png";
      wallpapers = {
        # Add per-monitor wallpapers here
        # "DP-1" = "/path/to/wallpaper.png";
      };
    };
  };
}
