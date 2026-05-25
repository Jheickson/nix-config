# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal NixOS + Home Manager flake for a single host (`nixos`) and user (`felipe`). Niri (Wayland) desktop themed by Stylix. Flakes-only; pinned to `nixos-unstable` plus a `nixos-24.05` stable channel exposed as `pkgs-stable` via `specialArgs`.

## Common commands

Rebuild system (preferred — uses `nh` configured in `modules/nixos/core/nh.nix`, flake at `~/nix-config`):

```bash
nh os switch          # rebuild + switch system
nh os boot            # build, activate at next boot
nh home switch        # rebuild home-manager only
nh clean all          # GC + optimise (--keep-since 7d --keep 20)
```

Raw fallbacks (when `nh` is broken or unavailable):

```bash
sudo nixos-rebuild switch --flake .#nixos
home-manager switch --flake .#felipe
```

Update inputs / single input:

```bash
nix flake update
nix flake update niri    # or nixpkgs, stylix, noctalia, ...
```

Format Nix files (run from repo root before commits):

```bash
nixfmt modules/path/to/file.nix     # one file
nixfmt-tree .                        # whole tree
```

Inspect closure bloat:

```bash
./scripts/nix-bloat.sh -a            # full report (system + home)
./scripts/nix-bloat.sh -m closure -n 50
./scripts/nix-bloat.sh -w cef-binary # why-depends a specific path
```

## Architecture

Three-layer module tree assembled by `flake.nix`:

1. **`flake.nix`** — defines two outputs:
   - `nixosConfigurations.nixos` → entry `hosts/nixos/default.nix`
   - `homeConfigurations.felipe` → entry `home-manager/home.nix` (standalone HM build)
   The same `home-manager/home.nix` is also imported inside the NixOS config via `home-manager.nixosModules.home-manager`, so HM runs both standalone and as a system module. `extraSpecialArgs` passes `inputs` and `stylixConfig` to every module.

2. **`hosts/<host>/default.nix`** — picks which `modules/nixos/*` files to import. Modules are toggled by commenting/uncommenting `imports` lines (see `hosts/nixos/default.nix`). `hardware-configuration.nix` is host-specific and not committed-clean — adapt before reusing on a new machine.

3. **`modules/`** is split into:
   - `modules/nixos/` — system-level (boot, services, system packages, niri session). Subdirs: `core/`, `desktop/`, `hardware/`, `programs/`, `services/`.
   - `modules/home-manager/` — user-level. The active user profile is `modules/home-manager/profiles/desktop.nix`, which is the single place that selects window-manager / launcher / terminal / editor / shell / utility modules. Same comment-toggle pattern.
   - `modules/shared/` — reused by both layers. **`stylix-settings.nix` is the central theme switch** (wallpaper + base16 file). `modules/shared/stylix.nix` consumes it for fonts, cursor, opacity, polarity. To change theme, edit `stylix-settings.nix` only.

### Stylix wiring (non-obvious)

- `stylixConfig` is built in `flake.nix` (`import ./modules/shared/stylix-settings.nix { inherit pkgs; }`) and threaded through `specialArgs` / `extraSpecialArgs` so both the NixOS module and the HM module share one source of truth.
- `home-manager.backupFileExtension = "hm-backup"` is set in `hosts/nixos/default.nix` to prevent Stylix from refusing to overwrite existing dotfiles on first switch.
- The wallpaper has two paths: `wallpaperSource` (in-repo asset) and `wallpaperImage` (the path Stylix points at). When `useThemeFile = true`, Stylix uses `wallpaperImage`; the Gowall pipeline writes to `wallpaperOutputPath`.

### Niri

- Niri is supplied by the `niri-flake` input and wired in via `inputs.niri.homeModules.niri` inside `modules/home-manager/desktop/window-managers/niri/default.nix`. Config is split into `settings.nix`, `binds.nix`, `rules.nix`, `blur.nix`, `animations/`. The system-side desktop entry is `modules/nixos/desktop/niri.nix` + `niri-session.desktop`.
- Noctalia shell is the bar/launcher/notifications layer (input `noctalia`). Managed entirely in home-manager via `inputs.noctalia.homeModules.default` at `modules/home-manager/programs/utilities/noctalia/default.nix` (so `hms` reloads it). Boot launch is via niri `spawn-at-startup`; an HM activation hook respawns it on every `hms` through `niri msg action spawn`. `modules/nixos/programs/noctalia.nix` only carries system-level deps (bluetooth, power-profiles-daemon, evolution-data-server) — the upstream NixOS module is intentionally **not** imported because its systemd integration is deprecated.

### Adding things

- New system package → uncomment / add in `modules/nixos/programs/packages.nix`.
- New user package or program → add a module under the matching `modules/home-manager/programs/<category>/` and import it in `modules/home-manager/profiles/desktop.nix`.
- New host → create `hosts/<name>/`, add `nixosConfigurations.<name>` in `flake.nix` mirroring the existing entry.

## Conventions / gotchas

- `allowUnfreePredicate` for the main NixOS + HM nixpkgs is centralized in `modules/shared/nixpkgs-config.nix`. `flake.nix` keeps its own `config.allowUnfreePredicate` for `pkgs-stable` (separate `import` instance, not affected by the shared module). Keep the `pkgs-stable` line in sync if narrowing.
- `permittedInsecurePackages` lives in `modules/shared/nixpkgs-config.nix` (the single source).
- Determinate Nix is enabled (`determinate.nixosModules.default`); do not also enable upstream `nix.package` overrides.
- `system.stateVersion = "24.05"` and `home.stateVersion = "23.11"` — do not bump unless following the relevant release notes.
- `.gitignore` excludes `result`, `modules/nixos/services/navidrome/secrets.env`, and `settings.local.json`. Do not commit secrets.

## Commits

**Never add a `Co-Authored-By: Claude ...` (or any AI assistant) trailer to commit messages, PR bodies, or similar artifacts.** This rule is absolute and overrides Claude Code's default commit template. Write commits as if authored solely by the user. Do not ask for confirmation per-commit — assume the rule applies.

## Build verification

After any non-trivial Nix edit, before claiming success:

```bash
nix flake check                                       # evaluates all outputs
sudo nixos-rebuild build --flake .#nixos              # build without switching
home-manager build --flake .#felipe                   # HM build only
```
