# Umbriel appearance: borders, blur, colors, overview, animations.
# Replaces ../niri/blur.nix (raw KDL background-effect) and the tv_crt
# animation preset collection — neither ports to Umbriel's effect system.
# What changed:
#  - Focus ring gradient (base0D→base0E) → solid focused color (base0D).
#    No gradient knob exists.
#  - tv_crt open/close/resize shaders → spring curves on workspace
#    switching (damping 0.8 / stiffness 500, carried over from the Niri
#    workspace-switch override). Window open/close/move keep Umbriel
#    built-ins; custom GLSL would need a rewrite against umbriel_* uniforms.
#  - Niri blur { passes 2, offset 3, noise .03, saturation 1.0 } →
#    closest mapping below (offset has no equivalent).
{ config, ... }: let
  colors = config.lib.stylix.colors;
in {
  programs.umbriel.settings = {
    appearance = {
      prefer_no_csd = true;
      border_width = 2;
      outer_border_width = 0;
      # Niri geometry-corner-radius was 0 everywhere.
      corner_radius = 0;
      shadow.enabled = true;
      blur = {
        enabled = true;
        passes = 2;
        radius = 5;
        noise = 0.03;
        saturation = 1.0;
      };
    };

    colors = {
      background = "#${colors.base00}FF";
      text_primary = "#${colors.base05}FF";
      text_muted = "#${colors.base04}FF";
      accent_primary = "#${colors.base0D}FF";
      accent_secondary = "#${colors.base0E}FF";
      warning = "#${colors.base09}FF";
      error = "#${colors.base08}FF";
      border = {
        focused = "#${colors.base0D}FF";
        unfocused = "#${colors.base03}30";
        outer = "#${colors.base01}FF";
      };
    };
    # Niri hid its tab indicator for single-tab columns; match that.
    # title_bar.mode is already off by default — pin it so no name bar
    # can appear from either source.
    tab_bar.hide_when_single = true;
    title_bar.mode = "off";

    overview = {
      background_blur = true;
      workspace_wallpaper = true;
      shortcuts = true;
    };

    animation = {
      workspaces = {
        style = "slide";
        curve = "spring:0.8,500";
      };
      overview = {
        workspace_curve = "spring:0.8,500";
      };
    };

    hot_corners.top_left = {
      enabled = true;
      delay_ms = 500;
      action = "overview-open";
    };
  };
}
