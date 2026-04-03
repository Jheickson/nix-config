{
  # NOTE FOR FUTURE EDITORS:
  # Generated automatically from the vendored niri-animation-collection repo.
  # This file is only a loader for the per-preset files in ./presets/.
  # The generated presets themselves are written one file per animation so
  # `programs.niri.animationPreset` can use an enum and the IDE can suggest
  # the available values.
  # If you add new presets with custom shaders, keep unsupported timing
  # fields out of `window-open`, `window-close`, `window-resize`, and
  # `screenshot-ui-open` blocks or rerun this script after syncing upstream
  # changes.
  bloom = import ./presets/bloom.nix;
  blur = import ./presets/blur.nix;
  chromatic_edge = import ./presets/chromatic_edge.nix;
  dither-glitch = import ./presets/dither-glitch.nix;
  energize_b_niri = import ./presets/energize_b_niri.nix;
  fold-window = import ./presets/fold-window.nix;
  glide = import ./presets/glide.nix;
  glitch_00 = import ./presets/glitch_00.nix;
  glitch_01 = import ./presets/glitch_01.nix;
  incinerate = import ./presets/incinerate.nix;
  mushroom = import ./presets/mushroom.nix;
  pixel-sort = import ./presets/pixel-sort.nix;
  pixelate = import ./presets/pixelate.nix;
  pop-drop = import ./presets/pop-drop.nix;
  prism_fold = import ./presets/prism_fold.nix;
  ribbons = import ./presets/ribbons.nix;
  roll-drop = import ./presets/roll-drop.nix;
  smoke = import ./presets/smoke.nix;
  tv_crt = import ./presets/tv_crt.nix;
}
