{ config, pkgs, ... }:

let
  colors = config.lib.stylix.colors;
in
{
  home.packages = with pkgs; [ fastfetch ];

  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": {
        "source": "${config.home.homeDirectory}/.config/fastfetch/logo.txt",
        "padding": { "top": 2, "left": 2 }
      },
      "display": {
        "separator": "  ",
        "color": "cyan"
      },
      "modules": [
        "title",
        "separator",
        "os",
        "host",
        "kernel",
        "uptime",
        "packages",
        "shell",
        "de",
        "wm",
        "theme",
        "icons",
        "font",
        "cpu",
        "gpu",
        "memory",
        "disk",
        "separator",
        "colors"
      ]
    }
  '';

  xdg.configFile."fastfetch/logo.txt".text = ''
    ${builtins.readFile ./fastfetch-art.txt}
  '';
}
