{ config, pkgs, lib, ... }:

let
  colors = config.lib.stylix.colors;
  fonts = config.stylix.fonts;
in
{
  programs.fuzzel = {
    enable = true;
    package = pkgs.fuzzel;
    settings = {
      main = lib.mkForce {
        font = "${fonts.monospace.name}:size=14";
        prompt = "❯ ";
        terminal = "alacritty";
        layers = "overlay";
        anchor = "center";
        width = 300;
        height = 200;
        columns = 2;
        dpi-aware = "yes";
        icon-theme = "Papirus";
        icon-size = 32;
        show-actions = true;
        action-key = "Ctrl+Return";
        password-character = "●";
        password-prompt = "Password: ";
        drun-launch = true;
        drun-print = false;
        term = "alacritty";
        keyboard-focus = "on-demand";
      };

      list = lib.mkForce {
        font = "${fonts.monospace.name}:size=14";
        single-exec = false;
        prompt = "❯ ";
        icon-theme = "Papirus";
        icon-size = 32;
        prompt-padding = 12;
        vertical-padding = 8;
        horizontal-padding = 16;
        border-width = 2;
        border-radius = 12;
        margin = 0;
        spacing = 4;
        max-items = 10;
        min-height = 0;
        max-height = 0;
        min-width = 0;
        max-width = 0;
        scrollbar = "always";
        scrollbar-width = 8;
        scrollbar-padding = 4;
        scrollbar-radius = 4;
      };

      colors = lib.mkForce {
        background = "${colors.base00}FF";
        text = "${colors.base05}FF";
        prompt = "${colors.base0D}FF";
        placeholder = "${colors.base03}FF";
        selection = "${colors.base02}FF";
        selection-text = "${colors.base05}FF";
        selection-border = "${colors.base0D}FF";
        border = "${colors.base03}FF";
        separator = "${colors.base01}FF";
        scrollbar = "${colors.base03}FF";
        scrollbar-thumb = "${colors.base04}FF";
        icon-placeholder = "${colors.base03}FF";
        action = "${colors.base0C}FF";
        action-text = "${colors.base05}FF";
        action-border = "${colors.base0C}FF";
        password-background = "${colors.base00}FF";
        password-text = "${colors.base05}FF";
        password-border = "${colors.base03}FF";
        password-placeholder = "${colors.base03}FF";
      };

      key-bindings = {
        "Ctrl+j" = "down";
        "Ctrl+k" = "up";
        "Ctrl+g" = "cancel";
        "Ctrl+h" = "backspace";
        "Ctrl+w" = "delete-word";
        "Ctrl+u" = "delete-bol";
        "Ctrl+a" = "cursor-home";
        "Ctrl+e" = "cursor-end";
        "Ctrl+d" = "delete-char";
        "Ctrl+f" = "cursor-right";
        "Ctrl+b" = "cursor-left";
        "Ctrl+p" = "up";
        "Ctrl+n" = "down";
        "Ctrl+[" = "cancel";
        "Ctrl+m" = "accept";
        "Ctrl+Return" = "accept-alt";
        "Ctrl+Shift+Return" = "accept-alt";
        "Shift+Return" = "accept-alt";
        "Alt+Return" = "accept-alt";
        "Alt+1" = "accept-custom-1";
        "Alt+2" = "accept-custom-2";
        "Alt+3" = "accept-custom-3";
        "Alt+4" = "accept-custom-4";
        "Alt+5" = "accept-custom-5";
        "Alt+6" = "accept-custom-6";
        "Alt+7" = "accept-custom-7";
        "Alt+8" = "accept-custom-8";
        "Alt+9" = "accept-custom-9";
        "Alt+0" = "accept-custom-10";
      };
    };
  };

  # Create custom scripts for additional functionality
  home.packages = with pkgs; [
    fuzzel
    fd
    ripgrep
    bc
    wl-clipboard
  ];

  # Create desktop entries for custom commands
  xdg.dataFile = {
    "applications/fuzzel-calc.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Calculator
        Comment=Quick calculator
        Exec=sh -c 'result=$(echo "%1" | bc -l 2>/dev/null || echo "Error"); echo "$result" | wl-copy; notify-send "Calculator" "$result"'
        Icon=accessories-calculator
        Categories=Utility;Calculator;
        NoDisplay=true
      '';
    };

    "applications/fuzzel-web-search.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Web Search
        Comment=Search the web
        Exec=sh -c 'xdg-open "https://duckduckgo.com/?q=%1"'
        Icon=web-browser
        Categories=Network;WebBrowser;
        NoDisplay=true
      '';
    };

    "applications/fuzzel-system-shutdown.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Shutdown
        Comment=Shutdown the system
        Exec=systemctl poweroff
        Icon=system-shutdown
        Categories=System;
        NoDisplay=true
      '';
    };

    "applications/fuzzel-system-reboot.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Reboot
        Comment=Reboot the system
        Exec=systemctl reboot
        Icon=system-reboot
        Categories=System;
        NoDisplay=true
      '';
    };

    "applications/fuzzel-system-suspend.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Suspend
        Comment=Suspend the system
        Exec=systemctl suspend
        Icon=system-suspend
        Categories=System;
        NoDisplay=true
      '';
    };

    "applications/fuzzel-emoji.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Emoji Picker
        Comment=Select emoji
        Exec=sh -c 'emoji=$(printf "😀 😃 😄 😁 😆 😅 😂 🤣 😊 😇 🙂 🙃 😉 😌 😍 🥰 😘 😗 😙 😚 😋 😛 😝 😜 🤪 🤨 🧐 🤓 😎 🤩 🥳 😏 😒 😞 😔 😟 😕 🙁 ☹️ 😣 😖 😫 😩 🥺 😢 😭 😤 😠 😡 🤬 🤯 😳 🥵 🥶 😱 😨 😰 😥 😓 🤗 🤔 🤭 🤫 🤥 😶 😐 😑 😬 🙄 😯 😦 😧 😮 😲 🥱 😴 🤤 😪 😵 🤐 🥴 🤢 🤮 🤧 😷 🤒 🤕 🤠 🤑 🤡 😈 👿 👹 👺 🤖 👽 👻 💀 ☠️ 👾" | tr " " "\n" | fuzzel --dmenu --prompt="Emoji: "); echo -n "$emoji" | wl-copy'
        Icon=face-smile
        Categories=Utility;
        NoDisplay=true
      '';
    };
  };

  # Create wrapper script for enhanced functionality
  home.file.".local/bin/fuzzel-launcher" = {
    executable = true;
    text = ''
      #!/bin/sh
      
      # Enhanced fuzzel launcher with additional features
      
      case "$1" in
        "calc:"*)
          expression=$(echo "$1" | sed 's/calc://')
          result=$(echo "$expression" | bc -l 2>/dev/null || echo "Error: Invalid expression")
          echo "$result" | wl-copy
          notify-send "Calculator" "$expression = $result"
          ;;
        "search:"*)
          query=$(echo "$1" | sed 's/search://')
          xdg-open "https://duckduckgo.com/?q=$query"
          ;;
        "wiki:"*)
          query=$(echo "$1" | sed 's/wiki://')
          xdg-open "https://en.wikipedia.org/wiki/Special:Search?search=$query"
          ;;
        "translate:"*)
          query=$(echo "$1" | sed 's/translate://')
          xdg-open "https://translate.google.com/?text=$query"
          ;;
        *)
          # Default behavior - launch applications
          exec fuzzel "$@"
          ;;
      esac
    '';
  };
}
