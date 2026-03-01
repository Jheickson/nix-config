{ config, ... }:
let
  colors = config.lib.stylix.colors;
  windowRules = [

    # ── Global ────────────────────────────────────────────────────────────────
    {
      geometry-corner-radius =
        let
          radius = 8.0;
        in
        {
          bottom-left = radius;
          bottom-right = radius;
          top-left = radius;
          top-right = radius;
        };
      clip-to-geometry = true;
      draw-border-with-background = false;
    }
    {
      matches = [ { is-floating = true; } ];
      shadow.enable = true;
    }

    # ── Screencast target indicator ───────────────────────────────────────────
    {
      matches = [ { is-window-cast-target = true; } ];
      focus-ring = {
        active.color = "#${colors.base08}";
        inactive.color = "#${colors.base09}";
      };
      border = {
        active.color = "#${colors.base08}";
        inactive.color = "#${colors.base09}";
      };
      shadow = {
        color = "#${colors.base08}70";
      };
      tab-indicator = {
        active.color = "#${colors.base08}";
        inactive.color = "#${colors.base09}";
      };
    }

    # ── Browsers ──────────────────────────────────────────────────────────────
    {
      matches = [
        { app-id = "zen"; }
        { app-id = "firefox"; }
        { app-id = "chromium-browser"; }
        { app-id = "xdg-desktop-portal-gtk"; }
      ];
      scroll-factor = 1.0;
    }
    {
      matches = [
        { app-id = "zen"; }
        { app-id = "firefox"; }
        { app-id = "chromium-browser"; }
        { app-id = "edge"; }
      ];
      open-maximized = true;
    }

    # ── Picture-in-Picture ────────────────────────────────────────────────────
    {
      # Firefox and Zen share identical PiP settings
      matches = [
        { app-id = "firefox"; title = "Picture-in-Picture"; }
        { app-id = "zen";     title = "Picture-in-Picture"; }
      ];
      open-floating = true;
      default-floating-position = {
        x = 32;
        y = 32;
        relative-to = "bottom-right";
      };
      default-column-width.fixed  = 480;
      default-window-height.fixed = 270;
    }
    {
      # Generic fallback (e.g. Chromium)
      matches = [ { title = "Picture in picture"; } ];
      open-floating = true;
      default-floating-position = {
        x = 32;
        y = 32;
        relative-to = "bottom-right";
      };
    }

    # ── Floating popouts (bottom-right) ───────────────────────────────────────
    {
      matches = [ { title = "Discord Popout"; } ];
      open-floating = true;
      default-floating-position = {
        x = 32;
        y = 32;
        relative-to = "bottom-right";
      };
    }

    # ── Floating utilities ────────────────────────────────────────────────────
    # Terminals
    {
      matches = [
        { app-id = "com.mitchellh.ghostty"; }
        { app-id = "ghostty"; }
      ];
      open-floating = true;
    }
    # Audio controls
    {
      matches = [
        { app-id = "pavucontrol"; }
        { app-id = "pavucontrol-qt"; }
        { app-id = "com.saivert.pwvucontrol"; }
      ];
      open-floating = true;
    }
    # File managers & archive tools
    {
      matches = [
        { app-id = "org.gnome.Nautilus"; }
        { app-id = "nautilus"; }
        { app-id = "file-roller"; }
        { app-id = "org.gnome.FileRoller"; }
      ];
      open-floating = true;
    }
    # System / auth dialogs
    {
      matches = [
        { app-id = "nm-connection-editor"; }
        { app-id = "blueman-manager"; }
        { app-id = "xdg-desktop-portal-gtk"; }
        { app-id = "org.kde.polkit-kde-authentication-agent-1"; }
        { app-id = "gcr-prompter"; }
        { app-id = "pinentry"; }
      ];
      open-floating = true;
    }
    # Misc utilities
    {
      matches = [
        { app-id = "io.github.fsobolev.Cavalier"; }
        { app-id = "dialog"; }
        { app-id = "popup"; }
        { app-id = "task_dialog"; }
      ];
      open-floating = true;
    }

    # ── Floating dialog titles ────────────────────────────────────────────────
    # File operation progress
    {
      matches = [
        { title = "Progress"; }
        { title = "File Operations"; }
        { title = "Copying"; }
        { title = "Moving"; }
        { title = "Properties"; }
        { title = "Downloads"; }
        { title = "file progress"; }
      ];
      open-floating = true;
    }
    # Confirmation / alert dialogs
    {
      matches = [
        { title = "Confirm"; }
        { title = "Authentication Required"; }
        { title = "Notice"; }
        { title = "Warning"; }
        { title = "Error"; }
      ];
      open-floating = true;
    }

    # ── Privacy apps (laptop screen, maximized, hidden from screencast) ───────
    {
      matches = [
        { app-id = "wasistlos"; }
        { app-id = "zapzap"; }
        { app-id = "electron-mail"; }
        { app-id = "slack"; }
      ];
      open-on-output = "eDP-1";
      open-maximized = true;
      block-out-from = "screencast";
    }
    # Messaging apps without output/maximize constraints
    {
      matches = [
        { app-id = "org.telegram.desktop"; }
        { app-id = "app.drey.PaperPlane"; }
      ];
      block-out-from = "screencast";
    }

  ];
in
{
  programs.niri.settings = {
    window-rules = windowRules;
    layer-rules = [
      {
        # `niri msg layers` shows the background namespace as "swww-daemon".
        # Match that to place swww's surfaces within the backdrop.
        matches = [ { namespace = "swww-daemon"; }  { namespace = "^noctalia-wallpaper*"; } ];
        place-within-backdrop = true;
      }
    ];
    # Make the workspace background transparent so wallpapers placed within
    # the backdrop (e.g. swww) remain stationary and don't move with workspaces.
    layout = {
      background-color = "transparent";
    };
  };
}
