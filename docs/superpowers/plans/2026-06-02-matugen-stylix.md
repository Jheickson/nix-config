# Matugen → Stylix base16 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** When `useThemeFile = false`, source Stylix's `base16Scheme` from a Matugen Material You palette derived at build-time from `wallpaperSource`.

**Architecture:** A new `modules/shared/matugen.nix` module exposes a `pkgs.runCommand` derivation that runs `pkgs.matugen` against the wallpaper using a Tera template that emits a base16 yaml file. `modules/shared/stylix.nix` picks this path (instead of `themeFile`) when `useThemeFile = false`. A new `polarity` field in `stylix-settings.nix` is shared between Stylix and Matugen.

**Tech Stack:** Nix flakes, Home Manager, `danth/stylix` (release-25.11), `pkgs.matugen` 4.0.0 from nixpkgs (no new flake input), base16 yaml.

**Spec:** `docs/superpowers/specs/2026-06-02-matugen-stylix-design.md`

---

## File Structure

```
modules/shared/
├── stylix-settings.nix              # MODIFY — add `polarity = "dark";`
├── stylix.nix                       # MODIFY — replace lib.optionalAttrs branch with if/else
├── matugen.nix                      # CREATE — derivation that runs matugen and emits base16 yaml
└── matugen-templates/
    └── base16.yaml                  # CREATE — Tera template mapping Material You → base00-base0F
```

No other files change. Gowall pipeline (`modules/nixos/desktop/stylix-wallpaper.nix`) is untouched — it already short-circuits when `useThemeFile = false`.

Verification commands follow the project CLAUDE.md "Build verification" section, biased toward `dry-build` per the `feedback_nix_verification` memory.

---

## Task 1: Add `polarity` field to `stylix-settings.nix`

**Files:**
- Modify: `modules/shared/stylix-settings.nix:1-12`

- [ ] **Step 1: Add the field**

Edit `modules/shared/stylix-settings.nix` to add `polarity = "dark";` right after `useThemeFile`:

```nix
{ pkgs, ... }:

{
  enable = true;
  useThemeFile = true;
  polarity = "dark";

  wallpaperSource = ../../assets/wallpapers/Landscape/wallhaven-ml2zwy.png;
  wallpaperImage = ../../assets/wallpapers/wallpaper.png;
  wallpaperOutputPath = "/home/felipe/nix-config/assets/wallpapers/wallpaper.png";

  themeFile = "${pkgs.base16-schemes}/share/themes/saga.yaml";
}
```

- [ ] **Step 2: Format and verify it still evaluates**

Run:
```bash
nixfmt modules/shared/stylix-settings.nix
nix flake check
```
Expected: no errors. (Stylix still picks polarity from its own hardcoded line — no behavioral change yet.)

- [ ] **Step 3: Commit**

```bash
git add modules/shared/stylix-settings.nix
git commit -F - <<'EOF'
feat(stylix): expose polarity in stylix-settings

Prep for matugen integration: polarity becomes a shared config value so
both stylix and matugen can read the same source of truth.
EOF
```

---

## Task 2: Create matugen base16 template

**Files:**
- Create: `modules/shared/matugen-templates/base16.yaml`

- [ ] **Step 1: Create the template directory and file**

Create `modules/shared/matugen-templates/base16.yaml` with the following exact content:

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
  base08: "{{ colors.error.default.hex_stripped }}"
  base09: "{{ colors.tertiary.default.hex_stripped }}"
  base0A: "{{ colors.secondary.default.hex_stripped }}"
  base0B: "{{ colors.primary.default.hex_stripped }}"
  base0C: "{{ colors.primary_container.default.hex_stripped }}"
  base0D: "{{ colors.primary_fixed.default.hex_stripped }}"
  base0E: "{{ colors.tertiary_container.default.hex_stripped }}"
  base0F: "{{ colors.error_container.default.hex_stripped }}"
```

The Tera placeholders are resolved by matugen at build time. `mode` and the `colors.*` tree are matugen-provided context. `hex_stripped` returns the hex without the leading `#`, which is what base16 yaml expects.

- [ ] **Step 2: Verify the file exists and is non-empty**

Run:
```bash
ls -l modules/shared/matugen-templates/base16.yaml
wc -l modules/shared/matugen-templates/base16.yaml
```
Expected: file exists, ~20 lines.

- [ ] **Step 3: Commit**

```bash
git add modules/shared/matugen-templates/base16.yaml
git commit -F - <<'EOF'
feat(matugen): add base16 yaml template

Tera template mapping Material You roles to base00-base0F. Greyscale
ramp uses surface roles; accents pull from primary/secondary/tertiary/
error. Slug 'matugen' identifies the scheme in stylix.
EOF
```

---

## Task 3: Create `matugen.nix` module

**Files:**
- Create: `modules/shared/matugen.nix`

- [ ] **Step 1: Write the module**

Create `modules/shared/matugen.nix` with this exact content:

```nix
{ pkgs, stylixConfig, ... }:

let
  configToml = pkgs.writeText "matugen-config.toml" ''
    [config]
    [templates.base16]
    input_path  = '${./matugen-templates/base16.yaml}'
    output_path = './base16.yaml'
  '';
in
{
  matugenScheme = pkgs.runCommand "matugen-base16.yaml"
    {
      nativeBuildInputs = [ pkgs.matugen ];
    }
    ''
      export HOME=$PWD
      matugen image ${stylixConfig.wallpaperSource} \
        --mode ${stylixConfig.polarity} \
        --config ${configToml}
      cp base16.yaml $out
    '';
}
```

Notes for the engineer:
- The file evaluates to `{ matugenScheme = <derivation>; }`. Consumers do `(import ./matugen.nix args).matugenScheme`.
- `HOME=$PWD` is required because matugen writes state files to `$HOME`.
- `output_path` is relative to PWD, so the cp picks it up.
- `wallpaperSource` is an in-repo path — Nix coerces it to a store path automatically.

- [ ] **Step 2: Format**

Run:
```bash
nixfmt modules/shared/matugen.nix
```
Expected: no errors.

- [ ] **Step 3: Smoke-build the derivation in isolation**

The module is not yet wired in, but we can evaluate it standalone via a one-off expression. Run:

```bash
nix build --no-link --print-out-paths --impure --expr '
  let
    flake = builtins.getFlake (toString ./.);
    pkgs = flake.inputs.nixpkgs.legacyPackages.x86_64-linux;
    stylixConfig = import ./modules/shared/stylix-settings.nix { inherit pkgs; };
  in
    (import ./modules/shared/matugen.nix { inherit pkgs stylixConfig; }).matugenScheme
'
```

Expected: a `/nix/store/...-matugen-base16.yaml` path is printed. If matugen fails on a missing color role, the build error names the role — swap the offending line in `matugen-templates/base16.yaml` for an available role (e.g. `primary` for `primary_fixed`, `surface_variant` for `surface_container_high`) and retry.

- [ ] **Step 4: Inspect the generated yaml**

Run:
```bash
cat $(nix build --no-link --print-out-paths --impure --expr '
  let
    flake = builtins.getFlake (toString ./.);
    pkgs = flake.inputs.nixpkgs.legacyPackages.x86_64-linux;
    stylixConfig = import ./modules/shared/stylix-settings.nix { inherit pkgs; };
  in
    (import ./modules/shared/matugen.nix { inherit pkgs stylixConfig; }).matugenScheme
')
```

Expected: a complete base16 yaml with `system: "base16"`, all 16 `baseXX` keys present, each value a 6-hex-digit string with no `#` prefix. If any value is empty or contains `{{ ... }}`, the template variable name is wrong — fix in `matugen-templates/base16.yaml` and re-run.

- [ ] **Step 5: Commit**

```bash
git add modules/shared/matugen.nix
git commit -F - <<'EOF'
feat(matugen): module that builds a base16 yaml from a wallpaper

Pure build-time derivation: matugen + template → /nix/store yaml path.
Consumed by stylix.nix in a later commit. HOME is forced inside the
sandbox to keep matugen's state writes scoped.
EOF
```

---

## Task 4: Wire matugen into `stylix.nix`

**Files:**
- Modify: `modules/shared/stylix.nix`

- [ ] **Step 1: Replace the file contents**

Replace `modules/shared/stylix.nix` with this exact content:

```nix
{ pkgs, lib, stylixConfig, ... }:

let
  matugen = import ./matugen.nix { inherit pkgs stylixConfig; };
in
{
  stylix = {
    enable = stylixConfig.enable;
    autoEnable = stylixConfig.enable;

    # Stylix has no release-26.05 branch yet; we pin to release-25.11 (closest
    # available) while HM/nixpkgs are on the 26.05 cycle. Remove this once a
    # matching Stylix release branch exists.
    enableReleaseChecks = false;

    polarity = stylixConfig.polarity;

    opacity = {
      terminal = 0.75;
    };

    fonts = with pkgs; rec {
      monospace = {
        package = nerd-fonts.hack;
        name = "HackNerdFontMono";
      };
      sansSerif = monospace;
      serif = monospace;
    };

    cursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
      size = 16;
    };

    image =
      if stylixConfig.useThemeFile then
        stylixConfig.wallpaperImage
      else
        stylixConfig.wallpaperSource;

    base16Scheme =
      if stylixConfig.useThemeFile then
        stylixConfig.themeFile
      else
        matugen.matugenScheme;
  };
}
```

Changes vs. previous version:
- `polarity` now reads `stylixConfig.polarity` (was hardcoded `"dark"`).
- `base16Scheme` always set, branched by `useThemeFile`. The `lib.optionalAttrs` trailer is removed.
- `lib` is still in the function args (kept in case future use, harmless; remove if `nixfmt` or eval complains about an unused arg — it won't).

- [ ] **Step 2: Format**

Run:
```bash
nixfmt modules/shared/stylix.nix
```
Expected: no errors.

- [ ] **Step 3: Evaluate the flake**

Run:
```bash
nix flake check
```
Expected: no errors. (Still using `useThemeFile = true`, so matugen is not evaluated yet — this catches syntax/type errors only.)

- [ ] **Step 4: Dry-build the system**

Run:
```bash
sudo nixos-rebuild dry-build --flake .#nixos
```
Expected: dry-build completes, no errors. Same colors as before since `useThemeFile = true`.

- [ ] **Step 5: Commit**

```bash
git add modules/shared/stylix.nix
git commit -F - <<'EOF'
feat(stylix): branch base16Scheme between themeFile and matugen

useThemeFile=true preserves the existing fixed-yaml + gowall path.
useThemeFile=false now sources base16Scheme from the matugen
derivation instead of stylix's built-in mean-color extraction.
Polarity reads from stylix-settings (was hardcoded).
EOF
```

---

## Task 5: End-to-end verification with `useThemeFile = false`

**Files:**
- Modify (temporarily): `modules/shared/stylix-settings.nix`

This task validates the full pipeline by flipping the toggle, dry-building, and inspecting Stylix's view of the scheme. We do not commit the toggle flip.

- [ ] **Step 1: Flip the toggle**

Edit `modules/shared/stylix-settings.nix`, change `useThemeFile = true;` to `useThemeFile = false;`. Do NOT commit.

- [ ] **Step 2: Dry-build**

Run:
```bash
sudo nixos-rebuild dry-build --flake .#nixos
```
Expected: completes without errors. Matugen runs as a build dependency; the build log includes matugen's output. If matugen errors on a missing color role, fix `matugen-templates/base16.yaml` per Task 3 Step 3 guidance, then retry.

- [ ] **Step 3: Inspect the realized scheme path**

Run:
```bash
nix eval --raw .#nixosConfigurations.nixos.config.stylix.base16Scheme
```
Expected: a `/nix/store/...-matugen-base16.yaml` path.

Then:
```bash
cat "$(nix eval --raw .#nixosConfigurations.nixos.config.stylix.base16Scheme)"
```
Expected: a base16 yaml with `slug: "matugen"`, `variant: "dark"`, and all 16 `baseXX` keys populated with 6-hex-digit values.

- [ ] **Step 4: Inspect a derived color to confirm Stylix consumed it**

Run:
```bash
nix eval .#nixosConfigurations.nixos.config.lib.stylix.colors.base00
```
Expected: a hex string. Compare to `base00` in the yaml from Step 3 — they must match.

- [ ] **Step 5: (Optional) Live switch**

If you want a visual check, run:
```bash
nh os switch
```
Expected: system rebuilds, niri/kitty/btop/gtk apps update to the Material You-derived palette. Toggle `useThemeFile` back to `true` and `nh os switch` again to confirm the saga.yaml + gowall path still works.

- [ ] **Step 6: Restore the toggle**

Edit `modules/shared/stylix-settings.nix`, change `useThemeFile = false;` back to `useThemeFile = true;` (the default for the repo's main branch). Do not commit any change in this task — Tasks 1–4 already capture the feature.

- [ ] **Step 7: Sanity-check the working tree**

Run:
```bash
git status
git diff
```
Expected: clean working tree (no diffs). All four feature commits are present in `git log`.

---

## Self-review notes

- Spec coverage: every section of `2026-06-02-matugen-stylix-design.md` maps to a task. `stylix-settings.nix` change → Task 1. Template → Task 2. `matugen.nix` → Task 3. `stylix.nix` patch → Task 4. Edge-case verification, purity, rollback → exercised by Task 5.
- Placeholder scan: no TBD/TODO/"add validation"-style steps. Every code change is a literal block.
- Type/name consistency: `matugenScheme` defined in Task 3 is referenced in Task 4 as `matugen.matugenScheme`. `polarity` added in Task 1 is consumed in Tasks 3 and 4. Template path `./matugen-templates/base16.yaml` is consistent across tasks.
- Rollback: removing the feature is a 4-file revert (`git revert` the four feature commits).
