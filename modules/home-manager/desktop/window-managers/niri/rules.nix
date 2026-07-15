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
    # {
    #   matches = [ { is-floating = true; } ];
    #   shadow.enable = true;
    # }
    {
      clip-to-geometry = true;
      draw-border-with-background = false;
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
        { app-id = "zen-beta"; }
        { app-id = "firefox"; }
        { app-id = "chromium-browser"; }
        { app-id = "xdg-desktop-portal-gtk"; }
      ];
      scroll-factor = 1.0;
    }
    {
      matches = [
        { app-id = "zen-beta"; }
        { app-id = "firefox"; }
        { app-id = "chromium-browser"; }
        { app-id = "edge"; }
      ];
      open-on-workspace = "2-browsing";
      open-maximized = true;
    }

    # ── Picture-in-Picture ────────────────────────────────────────────────────
    {
      # Firefox and Zen share identical PiP settings
      matches = [
        { app-id = "firefox";  title = "Picture-in-Picture"; }
        { app-id = "zen-beta"; title = "Picture-in-Picture"; }
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

    # ── Coding workspace ──────────────────────────────────────────────────────
    # VSCode, Bruno, dedicated nvim terminal — tiled at 50% width on workspace 3.
    # Bruno reports app-id "electron" (generic), so match by title to scope.
    # nvim ghostty launched via Mod+Shift+N with `--class=ghostty-nvim`; generic
    # ghostty windows keep default placement.
    {
      matches = [
        { app-id = "code"; }
        { app-id = "ghostty-nvim"; }
        { app-id = "electron"; title = "^Bruno"; }
      ];
      open-on-workspace = "3-coding";
      default-column-width.proportion = 0.5;
    }

# ── Floating utilities ────────────────────────────────────────────────────
    # Ghostty (generic) — always floats, auto-sized. nvim ghostty (ghostty-nvim) stays tiled.
    {
      matches = [ { app-id = "com.mitchellh.ghostty"; } ];
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
        { app-id = "org.Nemo"; }
        { app-id = "nemo"; }
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

    # ── Social workspace ──────────────────────────────────────────────────────
    # Ferdium (chat) + music player at 50/50 on workspace 2, both blocked from screencast.
    {
      matches = [
        { app-id = "ferdium"; }
        { app-id = "feishin"; }
        { app-id = "com.github.th_ch.youtube_music"; }
      ];
      open-on-workspace = "1-social";
      default-column-width.proportion = 0.5;
      block-out-from = "screencast";
    }

    # ── Privacy apps (laptop screen, maximized, hidden from screencast) ───────
    {
      matches = [
        { app-id = "wasistlos"; }
        { app-id = "zapzap"; }
        { app-id = "electron-mail"; }
        { app-id = "slack"; }
        { app-id = "discord"; }
        { app-id = "telegram-desktop"; }
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
        # `niri msg layers` shows the background namespace as "awww-daemon".
        # Match that to place awww's surfaces within the backdrop.
        matches = [ { namespace = "awww-daemon"; }  { namespace = "^noctalia-wallpaper*"; } ];
        place-within-backdrop = true;
      }
    ];
    # Make the workspace background transparent so wallpapers placed within
    # the backdrop (e.g. awww) remain stationary and don't move with workspaces.
    layout = {
      background-color = "transparent";
    };
  };
}
