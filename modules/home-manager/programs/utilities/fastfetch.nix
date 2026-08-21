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
        "break",
        {
          "type": "custom",
          "key": " ",
          "format": "\u001b[1;36mSystem\u001b[0m"
        },
        {
          "type": "custom",
          "key": " ",
          "format": "────────────────────────────────",
          "outputColor": "cyan"
        },
        "os",
        "host",
        "uptime",
        "break",
        {
          "type": "custom",
          "key": " ",
          "format": "\u001b[1;36mDesktop\u001b[0m"
        },
        {
          "type": "custom",
          "key": " ",
          "format": "────────────────────────────────",
          "outputColor": "cyan"
        },
        "de",
        "wm",
        "break",
        {
          "type": "custom",
          "key": " ",
          "format": "\u001b[1;36mHardware\u001b[0m"
        },
        {
          "type": "custom",
          "key": " ",
          "format": "────────────────────────────────",
          "outputColor": "cyan"
        },
        "cpu",
        "gpu",
        "memory",
        "disk",
        "break",
        {
          "type": "custom",
          "key": " ",
          "format": "\u001b[1;36mAppearance\u001b[0m"
        },
        {
          "type": "custom",
          "key": " ",
          "format": "────────────────────────────────",
          "outputColor": "cyan"
        },
        "colors"
      ]
    }
  '';

  xdg.configFile."fastfetch/logo.txt".text = ''
    ${builtins.readFile ./fastfetch-art.txt}
  '';
}
