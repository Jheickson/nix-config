{ pkgs, config, ... }: 
{
  services.picom = {
    enable = true;

    fade = true;
    fadeDelta = 10;  # Smoother fading animations

    shadow = true;
    shadowOpacity = 0.6;
    shadowOffsets = [ (-10) (-10) ];
    shadowExclude = [
      # Exclude tooltips, context menus, docks, and panels from shadows
      "_GTK_FRAME_EXTENTS@:c"
      "class_g = 'Dunst'"
      "class_g = 'Polybar'"
      "class_g = 'Notification'"
      "name *= 'Context Menu'"
    ];

    activeOpacity = 1.0;
    inactiveOpacity = 0.85;
    menuOpacity = 0.85;

    backend = "glx";
    vSync = true;

    settings = {
      frame-opacity = 0.7;
      blur-method = "dual_kawase";
      blur-strength = 7;  # Enhanced blur
      detect-client-opacity = true;
      detect-rounded-corners = true;
      paint-on-overlay = true;
      detect-transient = true;
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;

      # Fix for unwanted blur effects
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "_GTK_FRAME_EXTENTS@:c"
        "class_g = 'Dunst'"
        "class_g = 'Polybar'"
        "class_g = 'Notification'"
        "class_g = 'firefox' && argb"
        "name *= 'Context Menu'"
      ];

      # Animation effects
      fading = true;
      fade-in-step = 0.03;
      fade-out-step = 0.03;

      # Other effects
      shadow-exclude-focused = true;
      use-ewmh-active-win = true;

      # Add the animation settings
      animations = [
        {
          triggers = ["close"];
          opacity = {
            curve = "cubic-bezier(.75,0,.75,.9)";
            duration = 0.15;
            start = "window-raw-opacity-before";
            end = 0;
          };
          blur-opacity = "opacity";
          shadow-opacity = "opacity";
          offset-x = "(1 - scale-x) / 2 * window-width";
          offset-y = "(1 - scale-y) / 2 * window-height";
          scale-x = {
            curve = "cubic-bezier(.75,0,.75,.9)";
            duration = 0.15;
            start = 1;
            end = 0.7;
          };
          scale-y = "scale-x";
          shadow-scale-x = "scale-x";
          shadow-scale-y = "scale-y";
          shadow-offset-x = "offset-x";
          shadow-offset-y = "offset-y";
        }
        {
          triggers = ["open"];
          opacity = {
            curve = "cubic-bezier(.25,.1,.25,1)";
            duration = 0.15;
            start = 0;
            end = "window-raw-opacity";
          };
          blur-opacity = "opacity";
          shadow-opacity = "opacity";
          offset-x = "(1 - scale-x) / 2 * window-width";
          offset-y = "(1 - scale-y) / 2 * window-height";
          scale-x = {
            curve = "cubic-bezier(.25,.1,.25,1)";
            duration = 0.15;
            start = 0.7;
            end = 1;
          };
          scale-y = "scale-x";
          shadow-scale-x = "scale-x";
          shadow-scale-y = "scale-y";
          shadow-offset-x = "offset-x";
          shadow-offset-y = "offset-y";
        }
        {
          triggers = ["geometry"];
          scale-x = {
            curve = "cubic-bezier(.25,.1,.25,1)";
            duration = 0.13;
            start = "window-width-before / window-width";
            end = 1;
          };
          scale-y = {
            curve = "cubic-bezier(.25,.1,.25,1)";
            duration = 0.13;
            start = "window-height-before / window-height";
            end = 1;
          };
          offset-x = {
            curve = "cubic-bezier(.25,.1,.25,1)";
            duration = 0.13;
            start = "window-x-before - window-x";
            end = 0;
          };
          offset-y = {
            curve = "cubic-bezier(.25,.1,.25,1)";
            duration = 0.13;
            start = "window-y-before - window-y";
            end = 0;
          };

          shadow-scale-x = "scale-x";
          shadow-scale-y = "scale-y";
          shadow-offset-x = "offset-x";
          shadow-offset-y = "offset-y";
        }
      ];
    };
  };
}
