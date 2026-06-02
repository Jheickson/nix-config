# Matugen-generated base16 scheme for Stylix

Date: 2026-06-02
Status: Approved
Scope: single feature

## Goal

When `stylix-settings.nix` has `useThemeFile = false`, replace Stylix's built-in
mean-color palette extraction with a Material You palette derived from the
wallpaper by **Matugen**. Stylix continues to distribute colors to every themed
app; only the *source* of the base16 palette changes.

`useThemeFile = true` path (fixed base16 yaml + Gowall wallpaper recolor) is
untouched.

## Non-goals

- No per-app Matugen templates (niri, waybar, etc.) that bypass Stylix.
- No wallpaper recoloring with the derived palette.
- No new flake input. `pkgs.matugen` from nixpkgs is enough.
- No light/dark auto-switching beyond a manual `polarity` toggle.
- No activation hook. Generation is pure and happens at evaluation/build time.

## Architecture

### Files

```
modules/shared/
├── stylix-settings.nix              # +polarity field
├── stylix.nix                       # base16Scheme switches between themeFile and matugenScheme
├── matugen.nix                      # NEW — exports matugenScheme derivation
└── matugen-templates/
    └── base16.yaml                  # NEW — Tera template, Material You -> base16
```

### Responsibility per file

- **`stylix-settings.nix`** — single config truth. New field:
  `polarity = "dark";` (consumed by both Stylix and Matugen).
- **`matugen.nix`** — `{ pkgs, stylixConfig, ... }`-shaped module that exposes
  `matugenScheme`: a `pkgs.runCommand` derivation that runs Matugen with the
  template against `stylixConfig.wallpaperSource` and writes a base16 yaml to
  `$out`.
- **`matugen-templates/base16.yaml`** — Tera template emitting a complete
  base16 yaml (system, name, slug, variant, full `palette` block).
- **`stylix.nix`** — imports `matugen.nix`, picks `base16Scheme` based on
  `useThemeFile`, threads `polarity` from `stylixConfig`.

## Data flow

```
stylix-settings.nix (plain attrs, eval-time)
  ├─ useThemeFile : bool
  ├─ polarity     : "dark" | "light"
  └─ wallpaperSource : path
                  │
                  ▼  (only when !useThemeFile)
matugen.nix
  matugenScheme = pkgs.runCommand "matugen-base16.yaml" {
    nativeBuildInputs = [ pkgs.matugen ];
  } ''
    export HOME=$PWD
    matugen image ${stylixConfig.wallpaperSource} \
      --mode ${stylixConfig.polarity} \
      --config ${configToml}
    cp base16.yaml $out
  '';
                  │
                  ▼  (store path to yaml)
stylix.nix
  stylix.base16Scheme = if useThemeFile then themeFile else matugenScheme;
  stylix.image        = if useThemeFile then wallpaperImage else wallpaperSource;
  stylix.polarity     = stylixConfig.polarity;
                  │
                  ▼
Stylix distributes base16 colors to all themed apps (unchanged).
```

## Implementation sketch

### `matugen.nix`

```nix
{ pkgs, stylixConfig, ... }:
let
  configToml = pkgs.writeText "matugen-config.toml" ''
    [config]
    [templates.base16]
    input_path  = '${./matugen-templates/base16.yaml}'
    output_path = './base16.yaml'
  '';
in {
  matugenScheme = pkgs.runCommand "matugen-base16.yaml" {
    nativeBuildInputs = [ pkgs.matugen ];
  } ''
    export HOME=$PWD
    matugen image ${stylixConfig.wallpaperSource} \
      --mode ${stylixConfig.polarity} \
      --config ${configToml}
    cp base16.yaml $out
  '';
}
```

### `matugen-templates/base16.yaml`

```yaml
system: "base16"
name: "Matugen Material You"
slug: "matugen"
variant: "{{ mode }}"
palette:
  base00: "{{ colors.surface.default.hex_stripped }}"
  base01: "{{ colors.surface_container.default.hex_stripped }}"
  base02: "{{ colors.surface_container_high.default.hex_stripped }}"
  base03: "{{ colors.surface_container_highest.default.hex_stripped }}"
  base04: "{{ colors.on_surface_variant.default.hex_stripped }}"
  base05: "{{ colors.on_surface.default.hex_stripped }}"
  base06: "{{ colors.on_primary_container.default.hex_stripped }}"
  base07: "{{ colors.on_primary.default.hex_stripped }}"
  base08: "{{ colors.error.default.hex_stripped }}"             # red
  base09: "{{ colors.tertiary.default.hex_stripped }}"          # orange
  base0A: "{{ colors.secondary.default.hex_stripped }}"         # yellow
  base0B: "{{ colors.primary.default.hex_stripped }}"           # green-ish accent
  base0C: "{{ colors.primary_container.default.hex_stripped }}" # cyan
  base0D: "{{ colors.primary_fixed.default.hex_stripped }}"     # blue
  base0E: "{{ colors.tertiary_container.default.hex_stripped }}" # magenta
  base0F: "{{ colors.error_container.default.hex_stripped }}"   # brown
```

The mapping is opinionated. Greyscale ramp (base00-05) uses Material You's
surface roles, where Material You is strongest. Accents (base08-0F) pull from
primary/secondary/tertiary/error roles. Tweak in-file as needed per wallpaper.

> **Implementation note:** `colors.primary_fixed` and the `*_container_high(est)`
> roles exist in Matugen 4.x. Verify the installed `pkgs.matugen` version
> exposes the roles referenced above; the build will fail loudly if a token is
> missing. If nixpkgs ships an older version, swap for the equivalent role
> (e.g. `primary` for `primary_fixed`, `surface_variant` for
> `surface_container_high`).

### `stylix-settings.nix` change

Add:

```nix
polarity = "dark";
```

### `stylix.nix` change

Replace the existing `lib.optionalAttrs stylixConfig.useThemeFile { base16Scheme = ...; }`
trailer with a plain `if-then-else` inside the `stylix` attrset, since both
branches now set `base16Scheme`:

```nix
let
  matugen = import ./matugen.nix { inherit pkgs stylixConfig; };
in {
  stylix = {
    enable = stylixConfig.enable;
    autoEnable = stylixConfig.enable;
    enableReleaseChecks = false;
    polarity = stylixConfig.polarity;
    # ... opacity, fonts, cursor unchanged ...
    image = if stylixConfig.useThemeFile
            then stylixConfig.wallpaperImage
            else stylixConfig.wallpaperSource;
    base16Scheme = if stylixConfig.useThemeFile
                   then stylixConfig.themeFile
                   else matugen.matugenScheme;
  };
}
```

## Edge cases

- **Matugen build fails** (bad template, unsupported image format): nix eval
  fails during `nixos-rebuild build`. No half-applied state.
- **Wallpaper missing**: caught at eval (path coercion error on
  `wallpaperSource`).
- **Polarity flip**: requires rebuild (declarative — correct).
- **Matugen pkg version bump via nixpkgs update**: palette can shift for the
  same wallpaper. Expected and accepted.
- **Stylix release-26.05 mismatch**: existing `enableReleaseChecks = false`
  covers it. No new risk introduced.

## Purity / sandbox

All inputs (wallpaper, template, `pkgs.matugen`) resolve to `/nix/store` before
`runCommand` runs. No IFD. No network. Sandbox-safe. Works under
`nix flake check` and pure eval.

## Verification

Per project CLAUDE.md (and the `feedback_nix_verification` memory — prefer
dry-build over full sudo build):

```bash
nixfmt modules/shared/matugen.nix \
       modules/shared/stylix.nix \
       modules/shared/stylix-settings.nix
nix flake check
sudo nixos-rebuild dry-build --flake .#nixos
home-manager build --flake .#felipe
```

Manual smoke after `nh os switch`:

- Toggle `useThemeFile = false` -> switch -> confirm colors flip in kitty,
  btop, niri border, noctalia bar, GTK apps.
- Toggle back to `true` -> confirm saga.yaml palette restored and Gowall
  wallpaper recolor still runs.

## Rollback

- **Quick**: set `useThemeFile = true`. Matugen derivation no longer evaluated,
  zero cost.
- **Full**: delete `matugen.nix` + `matugen-templates/`, restore the
  `lib.optionalAttrs` form of `base16Scheme` in `stylix.nix`, drop `polarity`
  from `stylix-settings.nix`.

## Open follow-ups (out of scope, noted)

- If the Material You -> base16 mapping consistently produces ugly accents for
  certain wallpapers, revisit the template (swap `primary_fixed` <-> `primary`,
  etc.). Single-file change.
- If light-mode is ever desired, flip `polarity` in `stylix-settings.nix`. No
  code change required.
