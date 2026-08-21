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
      "separator": " ",
        "color": "cyan"
      },
      "modules": [
        "break",
        {
          "type": "custom",
          "key": " ",
          "format": "\u001b[93m┌───────────────────────── System ─────────────────────────┐"
        },
        {
          "type": "os",
          "key": "│ ├",
          "keyColor": "yellow",
          "format": "{name}"
        },
        {
          "type": "host",
          "key": "│ ├",
          "keyColor": "yellow"
        },
        {
          "type": "uptime",
          "key": "│ └",
          "keyColor": "yellow"
        },
        {
          "type": "custom",
          "key": " ",
          "format": "\u001b[93m└──────────────────────────────────────────────────────────┘"
        },
        "break",
        {
          "type": "custom",
          "key": " ",
          "format": "\u001b[36m┌──────────────────────── Desktop ─────────────────────────┐"
        },
        {
          "type": "de",
          "key": "│ ├",
          "keyColor": "cyan"
        },
        {
          "type": "wm",
          "key": "│ └",
          "keyColor": "cyan"
        },
        {
          "type": "custom",
          "key": " ",
          "format": "\u001b[36m└──────────────────────────────────────────────────────────┘"
        },
        "break",
        {
          "type": "custom",
          "key": " ",
          "format": "\u001b[92m┌──────────────────────── Hardware ────────────────────────┐"
        },
        {
          "type": "cpu",
          "key": "│ ├",
          "keyColor": "green",
          "format": "{1}, {3} Cores"
        },
        {
          "type": "gpu",
          "key": "│ ├󰍛",
          "keyColor": "green",
          "format": "{2}, {3}"
        },
        {
          "type": "memory",
          "key": "│ ├󰍛",
          "keyColor": "green"
        },
        {
          "type": "disk",
          "key": "│ └󰋊",
          "keyColor": "green"
        },
        {
          "type": "custom",
          "key": " ",
          "format": "\u001b[92m└──────────────────────────────────────────────────────────┘"
        },
        "break",
        {
          "type": "custom",
          "key": " ",
          "format": "\u001b[95m┌─────────────────────── Appearance ───────────────────────┐"
        },
        {
          "type": "colors",
          "key": " "
        },
        {
          "type": "custom",
          "key": " ",
          "format": "\u001b[95m└──────────────────────────────────────────────────────────┘"
        }
      ]
    }
  '';

  xdg.configFile."fastfetch/logo.txt".text = ''
    ${builtins.readFile ./fastfetch-art.txt}
  '';
}
