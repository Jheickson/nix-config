{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.umbriel.homeModules.default
    ./settings.nix
    ./keybinds.nix
    ./rules.nix
    ./appearance.nix
  ];

  home = {
    packages = with pkgs; [
      seatd
      jaq
      brightnessctl
      cliphist
    ];
  };

  # Fast-iteration override: plain repo file, symlinked out-of-store so
  # edits land on save with no rebuild (see settings.nix include hook).
  xdg.configFile."umbriel/local.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/modules/home-manager/desktop/window-managers/umbriel/local.toml";
}
