# Repo Reorganization — Design

**Date:** 2026-05-25
**Scope:** Cleanup pass over the `nix-config` repository. Seven items identified in an audit of the current tree; all in-scope except `NIRI_IDEAS.md` (deferred). Wallpapers deferred out of scope.
**Goal:** Reduce clutter, eliminate duplication, restore the "host file as composition only" convention claimed by `CLAUDE.md`.

---

## Decisions (from clarifying questions)

| Decision | Value |
|---|---|
| Cadence | Phased — one commit per phase, sequential |
| Dead modules policy | Move to `modules/_archive/` (not deleted) |
| `home-manager/home.nix` location | Move to `hosts/nixos/home.nix` |
| Wallpapers (473 MB) | Out of scope |
| Phase order | Safest → riskiest |
| Verification | `nix flake check` + `nixos-rebuild build` (dry-run, no `switch`) + `home-manager build` per phase |

---

## Target tree

```
nix-config/
├── flake.nix
├── flake.lock
├── hosts/
│   └── nixos/
│       ├── default.nix              # composition only (~50 lines)
│       ├── home.nix                 # moved from home-manager/home.nix
│       └── hardware-configuration.nix
├── modules/
│   ├── nixos/
│   │   ├── core/
│   │   │   ├── boot.nix             # NEW
│   │   │   ├── locale.nix           # NEW
│   │   │   ├── networking.nix       # NEW
│   │   │   ├── audio.nix            # NEW (pipewire + rtkit)
│   │   │   ├── users.nix            # NEW
│   │   │   ├── nix.nix              # NEW (nix settings)
│   │   │   ├── documentation.nix    # NEW
│   │   │   ├── nh.nix
│   │   │   └── substituters.nix
│   │   ├── desktop/                 # niri, gtk, xdg, stylix-wallpaper
│   │   ├── hardware/
│   │   ├── programs/
│   │   │   ├── base.nix             # NEW (firefox + zsh enables)
│   │   │   ├── direnv.nix           # NEW
│   │   │   ├── packages.nix         # consolidated systemPackages
│   │   │   └── ...
│   │   └── services/
│   │       ├── mpd.nix              # NEW
│   │       ├── printing.nix         # NEW
│   │       ├── flatpak.nix          # NEW
│   │       ├── udisks2.nix          # NEW
│   │       └── ...
│   ├── home-manager/
│   │   ├── desktop/
│   │   │   ├── notifications/
│   │   │   │   └── battery.nix      # flattened from battery/battery-notify.nix
│   │   │   └── ...
│   │   ├── programs/
│   │   │   └── utilities/
│   │   │       └── noctalia.nix     # flattened from noctalia/default.nix
│   │   └── profiles/desktop.nix
│   ├── shared/
│   │   ├── nixpkgs-config.nix       # NEW — central unfree/insecure/overlays
│   │   ├── stylix.nix
│   │   └── stylix-settings.nix
│   └── _archive/                    # NEW — dormant modules, no imports
│       ├── README.md
│       ├── nixos/
│       │   ├── programs/{steam,wine,flutter,thunderbird}.nix
│       │   └── services/{mysql,subsonic}.nix
│       └── home-manager/
│           ├── desktop/{i3,picom,quickshell,polybar,waybar,anyrun,fuzzel,rofi,dunst,alacritty}.nix
│           └── programs/editors/nvim/{nixcats,nixvim}/
└── ...
```

Kept-as-dirs (≥2 files, justified): `niri/`, `nvim/vanilla/`, `services/navidrome/`.

---

## Phase summary

| # | Phase | Risk | Verifies |
|---|---|---|---|
| 1 | Archive dead modules | low | flake check + builds |
| 2 | Flatten single-file dirs | low | flake check + builds |
| 3 | Central `nixpkgs-config.nix` | med | both builds, `pkgs.nvchad` still resolves |
| 4 | Consolidate `systemPackages` | med | both builds + portal sanity |
| 5 | Split host file | high | both builds, host file ≤80 lines |
| 6 | Move `home.nix` | med | both builds, `nix flake show` lists `homeConfigurations.felipe` |

Each phase: own commit. Branch `refactor/repo-reorg`. Final activation (`nh os switch` / `nh home switch`) only after all six phases merge cleanly.

---

## Phase 1 — Archive dead modules

**Create:** `modules/_archive/` with `nixos/` + `home-manager/` subtrees and a `README.md` (one line: *"Dormant modules. Not imported. Restore via `git mv` if reactivating."*).

**Move:**
- `modules/nixos/programs/{steam,wine,flutter,thunderbird}.nix` → `_archive/nixos/programs/`
- `modules/nixos/services/{mysql,subsonic}.nix` → `_archive/nixos/services/`
- `modules/home-manager/desktop/window-managers/i3.nix` → `_archive/home-manager/desktop/`
- `modules/home-manager/desktop/compositors/{picom,quickshell}.nix` → `_archive/home-manager/desktop/`
- `modules/home-manager/desktop/launchers/{anyrun,fuzzel,rofi}.nix` → `_archive/home-manager/desktop/`
- `modules/home-manager/desktop/bars/{polybar,waybar}/` → `_archive/home-manager/desktop/`
- `modules/home-manager/desktop/notifications/dunst/` → `_archive/home-manager/desktop/`
- `modules/home-manager/programs/terminals/alacritty.nix` → `_archive/home-manager/programs/`
- `modules/home-manager/programs/editors/nvim/{nixcats,nixvim}/` → `_archive/home-manager/programs/editors/nvim/`

**Edit (strip commented imports for moved files):**
- `hosts/nixos/default.nix` lines 29, 34, 37, 48-49, 54, 56-58
- `modules/home-manager/profiles/desktop.nix` lines 13, 17-18, 21-23, 27, 30-31, 35-37, 42

**Verify:** `nix flake check` + `nixos-rebuild build --flake .#nixos` + `home-manager build --flake .#felipe`.

**Commit:** `refactor(archive): move dormant modules to _archive/`

---

## Phase 2 — Flatten single-file dirs

**Move:**
- `modules/home-manager/desktop/notifications/battery/battery-notify.nix` → `modules/home-manager/desktop/notifications/battery.nix`
- `modules/home-manager/programs/utilities/noctalia/default.nix` → `modules/home-manager/programs/utilities/noctalia.nix`

**Edit:** `modules/home-manager/profiles/desktop.nix`
- import path → `../desktop/notifications/battery.nix`
- import path → `../programs/utilities/noctalia.nix`

**Verify:** `nix flake check` + both builds. Confirm noctalia HM activation hook still resolves (script lives inside the moved module — path-relative changes inside the file itself must be re-checked).

**Commit:** `refactor(flatten): collapse single-file directories`

---

## Phase 3 — Central `nixpkgs-config.nix`

**Create** `modules/shared/nixpkgs-config.nix`:
```nix
{ inputs, pkgs, ... }:
{
  nixpkgs = {
    config = {
      allowUnfreePredicate = _: true;
      permittedInsecurePackages = [
        "googleearth-pro-7.3.6.10201"
        "xpdf-4.05"
        "python-2.7.18.12"
      ];
    };
    overlays = [
      (final: prev: {
        nvchad = inputs.nix4nvchad.packages.${pkgs.system}.nvchad;
      })
    ];
  };
}
```

**Edit:**
- `hosts/nixos/default.nix`: delete `nixpkgs = { ... }` block (lines 266-278); add import of `../../modules/shared/nixpkgs-config.nix`.
- `home-manager/home.nix`: delete `nixpkgs = { ... }` block (lines 10-12); add import of `../modules/shared/nixpkgs-config.nix`.
- `flake.nix`: **leave `pkgs-stable` config alone.** That `import nixpkgs-stable { config.allowUnfreePredicate = ...; }` is a separate pkgs instance; the shared module only applies to the main NixOS / HM `nixpkgs`. Touching it would break `pkgs-stable.<unfree-pkg>` references.
- `CLAUDE.md`: update the duplication caveat — note that the system + HM dup is centralized, but `pkgs-stable` still has its own inline config by design.

**Caveat:** Home Manager and NixOS handle `nixpkgs.overlays` differently. If HM rejects the overlay in its module context, split into two files:
- `nixpkgs-config-system.nix` — overlays + insecure + unfree
- `nixpkgs-config-home.nix` — unfree only

Decide which path during verification.

**Verify:** `nix flake check` + both builds. Confirm `pkgs.nvchad` still resolves end-to-end (HM build either still references the overlay or has been split per the caveat).

**Commit:** `refactor(nixpkgs): centralize unfree/insecure/overlays in shared module`

---

## Phase 4 — Consolidate `systemPackages`

**Audit `hosts/nixos/default.nix:253-264`:**

| Package | Action |
|---|---|
| `home-manager`, `micro`, `git` | Keep in `modules/nixos/programs/packages.nix` (single source) |
| `vscode` | Remove from system (already imported via HM `programs/editors/vscode.nix`) |
| `inputs.zen-browser.packages."${system}".default` | Re-enable HM import (`profiles/desktop.nix:42`), remove from system |
| `xdg-desktop-portal`, `xdg-desktop-portal-gtk`, `xdg-desktop-portal-wlr` | Move into `modules/nixos/desktop/xdg.nix` |
| `users.users.felipe.packages = [ kdePackages.kate ]` (line 193-196) | Move to `home.packages` in `hosts/nixos/home.nix` (location post-phase-6) — for this phase, stage in `home-manager/home.nix` |

**Edit:**
- `hosts/nixos/default.nix`: remove `environment.systemPackages` block; merge `home-manager`/`micro`/`git` into `modules/nixos/programs/packages.nix` if not already present.
- `modules/nixos/desktop/xdg.nix`: append the 3 portal packages.
- `modules/home-manager/profiles/desktop.nix:42`: uncomment `../programs/browsers/zen-browser.nix`.
- `home-manager/home.nix`: add `kdePackages.kate` to `home.packages`.

**Verify:** both builds. Launch zen-browser + kate from a launcher post-final-switch (visual smoke only; not part of per-phase gate).

**Commit:** `refactor(packages): consolidate systemPackages into packages.nix and HM`

---

## Phase 5 — Split host file

**Create modules** (each is `{ pkgs, ... }: { ... }`). Content refs are **by block**, not by line number — phases 3-4 will have shifted the host file by the time phase 5 runs.

| New file | Block extracted from `hosts/nixos/default.nix` |
|---|---|
| `modules/nixos/core/boot.nix` | `boot.loader` block |
| `modules/nixos/core/networking.nix` | `networking` block (`networkmanager.enable`); `hostName` stays in host file as host-unique |
| `modules/nixos/core/locale.nix` | `time.timeZone` + `i18n` block |
| `modules/nixos/core/audio.nix` | `services.pipewire` sub-block + `security.rtkit.enable` |
| `modules/nixos/core/users.nix` | full `users` block (default shell + felipe definition) |
| `modules/nixos/core/nix.nix` | `nix` block (experimental-features, auto-optimise-store, nixPath, gc) |
| `modules/nixos/core/documentation.nix` | `documentation.enable` + `documentation.nixos.enable` |
| `modules/nixos/programs/base.nix` | `programs.firefox.enable` + `programs.zsh.enable` |
| `modules/nixos/programs/direnv.nix` | `programs.direnv` block |
| `modules/nixos/services/printing.nix` | `services.printing.enable` |
| `modules/nixos/services/flatpak.nix` | `services.flatpak.enable` |
| `modules/nixos/services/udisks2.nix` | `services.udisks2.enable` |
| `modules/nixos/services/mpd.nix` | `services.mpd` block |

**Edit `hosts/nixos/default.nix` → composition + host-unique only (target ~50 lines):**

```nix
{ inputs, stylixConfig, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared/stylix.nix
    ../../modules/shared/nixpkgs-config.nix
    inputs.home-manager.nixosModules.home-manager

    # core
    ../../modules/nixos/core/boot.nix
    ../../modules/nixos/core/networking.nix
    ../../modules/nixos/core/locale.nix
    ../../modules/nixos/core/audio.nix
    ../../modules/nixos/core/users.nix
    ../../modules/nixos/core/nix.nix
    ../../modules/nixos/core/nh.nix
    ../../modules/nixos/core/substituters.nix
    ../../modules/nixos/core/documentation.nix

    # desktop
    ../../modules/nixos/desktop/stylix-wallpaper.nix
    ../../modules/nixos/desktop/niri.nix
    ../../modules/nixos/desktop/xdg.nix

    # hardware
    ../../modules/nixos/hardware/upower.nix
    ../../modules/nixos/hardware/vial.nix

    # services
    ../../modules/nixos/services/docker.nix
    ../../modules/nixos/services/jellyfin.nix
    ../../modules/nixos/services/navidrome/navidrome.nix
    ../../modules/nixos/services/printing.nix
    ../../modules/nixos/services/flatpak.nix
    ../../modules/nixos/services/udisks2.nix
    ../../modules/nixos/services/mpd.nix

    # programs
    ../../modules/nixos/programs/nix-ld.nix
    ../../modules/nixos/programs/packages.nix
    ../../modules/nixos/programs/noctalia.nix
    ../../modules/nixos/programs/nicotine-plus.nix
    ../../modules/nixos/programs/base.nix
    ../../modules/nixos/programs/direnv.nix
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs stylixConfig; };
    backupFileExtension = "hm-backup";
    users.felipe = import ../../home-manager/home.nix;  # path updated in phase 6
  };

  networking.hostName = "nixos";    # host-unique
  system.stateVersion = "24.05";    # host-unique
}
```

**Verify:** `nix flake check` + both builds. Diff every extracted module vs. its original lines to confirm 1:1 transcription (no behavior change). Confirm host file ≤80 lines.

**Commit:** `refactor(host): split monolithic default.nix into focused modules`

---

## Phase 6 — Move `home.nix`

**Move:** `home-manager/home.nix` → `hosts/nixos/home.nix`.

**Edit moved file (paths relative to `hosts/nixos/`):**
- `../modules/shared/stylix.nix` → `../../modules/shared/stylix.nix`
- `../modules/home-manager/profiles/desktop.nix` → `../../modules/home-manager/profiles/desktop.nix`
- `../modules/shared/nixpkgs-config.nix` (added in phase 3) → `../../modules/shared/nixpkgs-config.nix`

**Edit `flake.nix`** `homeConfigurations.felipe`:
- Change `modules = [ ./home-manager/home.nix ];` → `modules = [ ./hosts/nixos/home.nix ];`

**Edit `hosts/nixos/default.nix`** (post-phase-5):
- `users.felipe = import ../../home-manager/home.nix;` → `users.felipe = import ./home.nix;`

**Delete:** empty `home-manager/` dir.

**Verify:** `nix flake check`, `nix flake show` (confirms `homeConfigurations.felipe` still enumerates), both builds.

**Commit:** `refactor(home): move home.nix into hosts/nixos/`

---

## Verification protocol

**Per-phase loop (must pass before commit):**

```bash
nix flake check
sudo nixos-rebuild build --flake .#nixos       # or: nh os build
home-manager build --flake .#felipe
nixfmt-tree modules/<changed-paths>
```

Green = commit. Red = revert WIP, diagnose, retry.

**Branching:** single feature branch `refactor/repo-reorg`, one commit per phase. If a phase regresses, `git revert <sha>` cleanly drops just that phase.

**Final smoke test** (only after all six phases merged, apply `switch` exactly once):

```bash
nh os switch
nh home switch
# visual: niri starts, noctalia bar renders, zen-browser launches, audio works,
# kate launches, file dialog in a Wayland app opens (portal sanity)
```

**Rollback insurance:** `nh os boot` for the final activation if nervous — current generation stays in bootloader.

---

## Out of scope

- `assets/wallpapers/` (473 MB) — defer
- `NIRI_IDEAS.md` — defer
- Any change to module semantics (this is a pure reorg)
- Renaming existing modules unless required by a move

## Commit policy

Per `CLAUDE.md`: **no `Co-Authored-By: Claude` trailers**. Conventional Commits format. One commit per phase.
