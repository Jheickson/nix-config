{ pkgs, inputs, lib, ... }:

{
  # Noctalia v5: option renamed `programs.noctalia-shell` -> `programs.noctalia`,
  # config format switched JSON -> TOML, binary renamed `noctalia-shell` -> `noctalia`.
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;

    # v5 home-module no longer defaults the package.
    package = inputs.noctalia.packages.${pkgs.system}.default;

    # Systemd startup is deprecated upstream; spawn via niri spawn-at-startup instead.
    systemd.enable = false;

    # Settings will be authored manually at ~/.config/noctalia/config.toml.
    # When ready to track them declaratively again, set `settings = builtins.fromJSON ...`
    # or point to a .toml file.
  };

  # Reload noctalia on `hms`. Kill if running, then ask niri to spawn a fresh
  # instance via IPC so the process is parented by the niri session.
  # Skips silently when niri is not running (e.g. hms from tty/ssh).
  home.activation.reload-noctalia = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ${pkgs.procps}/bin/pgrep -x niri >/dev/null 2>&1; then
      ${pkgs.procps}/bin/pkill -x noctalia || true
      sleep 0.3
      ${pkgs.niri}/bin/niri msg action spawn -- noctalia || true
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
