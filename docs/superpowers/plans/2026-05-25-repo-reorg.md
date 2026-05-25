# Repo Reorganization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the `nix-config` repo per the design at `docs/superpowers/specs/2026-05-25-repo-reorg-design.md` — five phases, each its own commit, each verifiable by `nix flake check` + dry-run builds.

**Architecture:** Pure reorg, no semantic changes. Move dead modules to `_archive/`, centralize `nixpkgs.config`, consolidate `systemPackages`, split the monolithic host file into focused modules, relocate `home.nix` into `hosts/nixos/`.

**Tech Stack:** Nix flakes, NixOS unstable, Home Manager, niri WM, `nh` build wrapper, `nixfmt-tree` formatter.

**Working directory:** `/home/felipe/nix-config`

**Branch:** `refactor/repo-reorg` (create from `main` before Task 1).

**Verification per phase (DO NOT SKIP):**
```bash
nix flake check
sudo nixos-rebuild build --flake .#nixos
home-manager build --flake .#felipe
```
All three must succeed before committing. If any fail, do not commit — diagnose and fix.

**Commit policy:** Conventional Commits. **No `Co-Authored-By: Claude` trailer** (per `/home/felipe/nix-config/CLAUDE.md`). Use `git commit -F - <<'EOF' ... EOF` heredoc for multiline bodies.

---

## Task 0: Branch setup

**Files:** none (git only).

- [ ] **Step 1: Confirm clean tree**

```bash
cd /home/felipe/nix-config
git status --short
```
Expected: only `NIRI_IDEAS.md` and `modules/home-manager/desktop/window-managers/niri/animations/niri-animation-collection/` show as untracked (pre-existing, out of scope). If any tracked files are modified, stop and ask the user.

- [ ] **Step 2: Create branch**

```bash
git checkout -b refactor/repo-reorg
```
Expected: `Switched to a new branch 'refactor/repo-reorg'`.

---

## Task 1: Phase 1 — Archive dead modules

**Files:**
- Create: `modules/_archive/README.md`
- Move (git mv): 15+ paths (listed in steps below)
- Modify: `hosts/nixos/default.nix` (strip commented imports)
- Modify: `modules/home-manager/profiles/desktop.nix` (strip commented imports)

- [ ] **Step 1: Create archive directories**

```bash
mkdir -p /home/felipe/nix-config/modules/_archive/nixos/programs
mkdir -p /home/felipe/nix-config/modules/_archive/nixos/services
mkdir -p /home/felipe/nix-config/modules/_archive/home-manager/desktop
mkdir -p /home/felipe/nix-config/modules/_archive/home-manager/programs/editors/nvim
mkdir -p /home/felipe/nix-config/modules/_archive/home-manager/programs/terminals
```

- [ ] **Step 2: Write archive README**

Write to `/home/felipe/nix-config/modules/_archive/README.md`:

```markdown
# _archive

Dormant Nix modules. Not imported anywhere in the active configuration.

These modules previously existed in the live tree but were toggled off
via commented imports. They are kept here for reference and quick revival
rather than relying solely on `git log`.

To reactivate a module:

```bash
git mv modules/_archive/<path> modules/<original-path>
```

Then re-add its import line in `hosts/nixos/default.nix` or
`modules/home-manager/profiles/desktop.nix` as appropriate.
```

- [ ] **Step 3: Move NixOS dead modules (programs)**

```bash
cd /home/felipe/nix-config
git mv modules/nixos/programs/steam.nix       modules/_archive/nixos/programs/
git mv modules/nixos/programs/wine.nix        modules/_archive/nixos/programs/
git mv modules/nixos/programs/flutter.nix     modules/_archive/nixos/programs/
git mv modules/nixos/programs/thunderbird.nix modules/_archive/nixos/programs/
```

- [ ] **Step 4: Move NixOS dead modules (services)**

```bash
cd /home/felipe/nix-config
git mv modules/nixos/services/mysql.nix    modules/_archive/nixos/services/
git mv modules/nixos/services/subsonic.nix modules/_archive/nixos/services/
```

- [ ] **Step 5: Move HM dead modules (desktop)**

```bash
cd /home/felipe/nix-config
git mv modules/home-manager/desktop/window-managers/i3.nix      modules/_archive/home-manager/desktop/
git mv modules/home-manager/desktop/compositors/picom.nix       modules/_archive/home-manager/desktop/
git mv modules/home-manager/desktop/compositors/quickshell.nix  modules/_archive/home-manager/desktop/
git mv modules/home-manager/desktop/launchers/anyrun.nix        modules/_archive/home-manager/desktop/
git mv modules/home-manager/desktop/launchers/fuzzel.nix        modules/_archive/home-manager/desktop/
git mv modules/home-manager/desktop/launchers/rofi.nix          modules/_archive/home-manager/desktop/
git mv modules/home-manager/desktop/bars/polybar                modules/_archive/home-manager/desktop/polybar
git mv modules/home-manager/desktop/bars/waybar                 modules/_archive/home-manager/desktop/waybar
git mv modules/home-manager/desktop/notifications/dunst         modules/_archive/home-manager/desktop/dunst
```

- [ ] **Step 6: Move HM dead modules (programs)**

```bash
cd /home/felipe/nix-config
git mv modules/home-manager/programs/terminals/alacritty.nix      modules/_archive/home-manager/programs/terminals/
git mv modules/home-manager/programs/editors/nvim/nixcats         modules/_archive/home-manager/programs/editors/nvim/nixcats
git mv modules/home-manager/programs/editors/nvim/nixvim          modules/_archive/home-manager/programs/editors/nvim/nixvim
```

- [ ] **Step 7: Verify source dirs are now empty or only contain active files**

```bash
ls /home/felipe/nix-config/modules/home-manager/desktop/compositors
ls /home/felipe/nix-config/modules/home-manager/desktop/launchers
ls /home/felipe/nix-config/modules/home-manager/desktop/bars
ls /home/felipe/nix-config/modules/home-manager/desktop/notifications
ls /home/felipe/nix-config/modules/home-manager/programs/editors/nvim
ls /home/felipe/nix-config/modules/home-manager/programs/terminals
ls /home/felipe/nix-config/modules/nixos/programs
ls /home/felipe/nix-config/modules/nixos/services
```
Expected:
- `compositors/`: empty (remove with `rmdir`)
- `launchers/`: empty (remove with `rmdir`)
- `bars/`: empty (remove with `rmdir`)
- `notifications/`: contains only `battery/`
- `nvim/`: contains only `vanilla/`
- `terminals/`: contains only `ghostty.nix`
- `programs/` (nixos): contains noctalia.nix, nicotine-plus.nix, nix-ld.nix, packages.nix
- `services/` (nixos): contains docker.nix, jellyfin.nix, navidrome/, postgresql.nix

- [ ] **Step 8: Remove now-empty dirs**

```bash
cd /home/felipe/nix-config
rmdir modules/home-manager/desktop/compositors
rmdir modules/home-manager/desktop/launchers
rmdir modules/home-manager/desktop/bars
```

- [ ] **Step 9: Strip commented imports from `hosts/nixos/default.nix`**

Open `/home/felipe/nix-config/hosts/nixos/default.nix`. Delete **only** these specific commented lines from the `imports = [ ... ];` block (they reference modules archived in Steps 3-4):

```
    # ../../modules/nixos/services/mysql.nix
    # ../../modules/nixos/services/subsonic.nix
    # ../../modules/nixos/programs/flutter.nix
    # ../../modules/nixos/programs/steam.nix
    # ../../modules/nixos/programs/thunderbird.nix
    # ../../modules/nixos/programs/wine.nix
```

**Keep** these commented imports — their modules still exist on disk and were not archived:
- `# ../../modules/nixos/core/networkmanager.nix`
- `# ../../modules/nixos/desktop/gtk.nix`
- `# ../../modules/nixos/desktop/xautolock.nix`

- [ ] **Step 10: Strip commented imports from `modules/home-manager/profiles/desktop.nix`**

Open `/home/felipe/nix-config/modules/home-manager/profiles/desktop.nix`. Delete these specific commented lines from the `imports = [ ... ];` block:

```
    # ../desktop/window-managers/i3.nix
    # ../desktop/bars/polybar/polybar.nix
    # ../desktop/bars/waybar/waybar.nix
    # ../desktop/launchers/anyrun.nix
    # ../desktop/launchers/fuzzel.nix
    # ../desktop/launchers/rofi.nix
    # ../desktop/notifications/dunst/dunst.nix
    # ../desktop/compositors/picom.nix
    # ../desktop/compositors/quickshell.nix
    # ../programs/terminals/alacritty.nix
    # ../programs/editors/nvim/nixcats/nixcats.nix
    # ../programs/editors/nvim/nixvim/nixvim.nix
```

- [ ] **Step 11: Run flake check**

```bash
cd /home/felipe/nix-config
nix flake check
```
Expected: no errors. Warnings about `documentation.nixos` (`builtins.derivation ... without a proper context`) are pre-existing and acceptable.

- [ ] **Step 12: Build system (dry-run)**

```bash
cd /home/felipe/nix-config
sudo nixos-rebuild build --flake .#nixos
```
Expected: succeeds, produces `./result` symlink. No activation.

- [ ] **Step 13: Build home-manager (dry-run)**

```bash
cd /home/felipe/nix-config
home-manager build --flake .#felipe
```
Expected: succeeds.

- [ ] **Step 14: Format**

```bash
cd /home/felipe/nix-config
nixfmt hosts/nixos/default.nix modules/home-manager/profiles/desktop.nix
```

- [ ] **Step 15: Commit phase 1**

```bash
cd /home/felipe/nix-config
git add -A
git commit -F - <<'EOF'
refactor(archive): move dormant modules to _archive/

Relocates 15 inactive modules (steam, wine, flutter, thunderbird, mysql,
subsonic, i3, picom, quickshell, anyrun, fuzzel, rofi, polybar, waybar,
dunst, alacritty, nixcats, nixvim) out of the live import tree. Strips
the matching commented-out import lines from host + profile.

Modules stay on disk for browse/revive; no functional change.
EOF
```
Expected: commit succeeds, working tree clean.

---

## Task 2: Phase 2 — Central `nixpkgs-config.nix`

**Files:**
- Create: `modules/shared/nixpkgs-config.nix`
- Modify: `hosts/nixos/default.nix` (drop inline `nixpkgs = {...}`)
- Modify: `home-manager/home.nix` (drop inline `nixpkgs = {...}`)
- Modify: `CLAUDE.md` (update duplication note)

- [ ] **Step 1: Write central nixpkgs config**

Write to `/home/felipe/nix-config/modules/shared/nixpkgs-config.nix`:

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

- [ ] **Step 2: Add import to host file**

Open `/home/felipe/nix-config/hosts/nixos/default.nix`. In the `imports = [ ... ];` block, immediately after the existing line:

```
    ../../modules/shared/stylix.nix
```

Insert:

```
    ../../modules/shared/nixpkgs-config.nix
```

- [ ] **Step 3: Remove inline `nixpkgs` block from host file**

In `/home/felipe/nix-config/hosts/nixos/default.nix`, find and delete the entire block:

```nix
  nixpkgs = {
    config.allowUnfreePredicate = pkg: true;
    config.permittedInsecurePackages = [
      "googleearth-pro-7.3.6.10201"
      "xpdf-4.05"
      "python-2.7.18.12"
    ];
    overlays = [
      (final: prev: {
        nvchad = inputs.nix4nvchad.packages."${pkgs.system}".nvchad;
      })
    ];
  };
```

(Currently around lines 266-278.)

- [ ] **Step 4: Add import to home.nix**

Open `/home/felipe/nix-config/home-manager/home.nix`. In the `imports = [ ... ];` block (lines 5-8), append:

```
    ../modules/shared/nixpkgs-config.nix
```

Resulting imports block:

```nix
  imports = [
    ../modules/shared/stylix.nix
    ../modules/home-manager/profiles/desktop.nix
    ../modules/shared/nixpkgs-config.nix
  ];
```

- [ ] **Step 5: Remove inline `nixpkgs` block from home.nix**

In `/home/felipe/nix-config/home-manager/home.nix`, find and delete:

```nix
  nixpkgs = {
    config.allowUnfreePredicate = pkg: true;
  };
```

(Currently lines 10-12.)

- [ ] **Step 5b: Remove duplicate `nixpkgs.config` from packages.nix**

`modules/nixos/programs/packages.nix` carries its own `nixpkgs.config` block at the top (lines 8-15). After centralization, leaving it in place will cause a duplicate-definition error (NixOS module merging refuses two non-`mkForce` settings of `allowUnfreePredicate`).

Open `/home/felipe/nix-config/modules/nixos/programs/packages.nix` and delete:

```nix
  nixpkgs.config = {
    allowUnfreePredicate = pkg: true;
    permittedInsecurePackages = [
      "googleearth-pro-7.3.6.10201"
      "xpdf-4.05"
      "python-2.7.18.12"
    ];
  };
```

(Currently lines 8-15.) Leave everything else in the file untouched.

- [ ] **Step 6: Run flake check**

```bash
cd /home/felipe/nix-config
nix flake check
```
Expected: no errors.

- [ ] **Step 7: Build system (dry-run)**

```bash
cd /home/felipe/nix-config
sudo nixos-rebuild build --flake .#nixos
```
Expected: succeeds.

- [ ] **Step 8: Build home-manager (dry-run)**

```bash
cd /home/felipe/nix-config
home-manager build --flake .#felipe
```
Expected: succeeds.

**If Step 8 fails with "the option `nixpkgs.overlays` does not exist" or similar:**

Home Manager does not always accept the overlay format the same way as NixOS. Split the file:

- Rename `modules/shared/nixpkgs-config.nix` → `modules/shared/nixpkgs-config-system.nix` (full content, overlays included).
- Create `modules/shared/nixpkgs-config-home.nix`:

  ```nix
  { ... }:
  {
    nixpkgs.config.allowUnfreePredicate = _: true;
  }
  ```

- Update host import to `../../modules/shared/nixpkgs-config-system.nix`.
- Update home.nix import to `../modules/shared/nixpkgs-config-home.nix`.
- Re-run Steps 6-8 to confirm both builds.

- [ ] **Step 9: Verify `pkgs.nvchad` still resolves**

```bash
cd /home/felipe/nix-config
nix eval .#nixosConfigurations.nixos.config.nixpkgs.overlays --apply 'builtins.length' 2>/dev/null || nix eval .#nixosConfigurations.nixos.pkgs.nvchad --apply 'p: p.name'
```
Expected: at least one of these returns a non-empty value (overlay length or nvchad package name). If both error, the overlay isn't applied — revisit Step 8.

- [ ] **Step 10: Update CLAUDE.md duplication caveat**

In `/home/felipe/nix-config/CLAUDE.md`, find the line:

```
- `allowUnfreePredicate = pkg: true` is set in both `flake.nix` (for `pkgs-stable`), `hosts/nixos/default.nix`, and `home-manager/home.nix`. Keep them in sync if narrowing.
```

Replace with:

```
- `allowUnfreePredicate` for the main NixOS + HM nixpkgs is centralized in `modules/shared/nixpkgs-config.nix`. `flake.nix` keeps its own `config.allowUnfreePredicate` for `pkgs-stable` (separate `import` instance, not affected by the shared module). Keep the `pkgs-stable` line in sync if narrowing.
```

Also find:

```
- `permittedInsecurePackages` is duplicated in `hosts/nixos/default.nix` and `modules/nixos/programs/packages.nix` — update both when changing.
```

Replace with:

```
- `permittedInsecurePackages` lives in `modules/shared/nixpkgs-config.nix` (the single source). Check `modules/nixos/programs/packages.nix` if a package needs adding there too (some modules pin their own).
```

- [ ] **Step 11: Format**

```bash
cd /home/felipe/nix-config
nixfmt modules/shared/nixpkgs-config.nix hosts/nixos/default.nix home-manager/home.nix modules/nixos/programs/packages.nix
```

- [ ] **Step 12: Commit phase 2**

```bash
cd /home/felipe/nix-config
git add -A
git commit -F - <<'EOF'
refactor(nixpkgs): centralize unfree/insecure/overlays in shared module

Pulls allowUnfreePredicate + permittedInsecurePackages + nvchad overlay
into modules/shared/nixpkgs-config.nix, imported by both the NixOS host
config and the home-manager entry. flake.nix's pkgs-stable instance
remains inline (separate pkgs evaluation).
EOF
```

---

## Task 3: Phase 3 — Consolidate `systemPackages`

**Files:**
- Modify: `hosts/nixos/default.nix` (drop `environment.systemPackages` block; drop kate from `users.users.felipe.packages`)
- Modify: `modules/nixos/programs/packages.nix` (merge in needed packages)
- Modify: `modules/nixos/desktop/xdg.nix` (add portal packages)
- Modify: `modules/home-manager/profiles/desktop.nix` (re-enable zen-browser import)
- Modify: `home-manager/home.nix` (add kate to `home.packages`)

- [ ] **Step 1: Inspect current packages.nix**

```bash
cd /home/felipe/nix-config
cat modules/nixos/programs/packages.nix
```
Confirm which of `home-manager`, `micro`, `git` are already present. Note: this is read-only — no edits yet.

- [ ] **Step 2: Add missing core packages to packages.nix**

Open `/home/felipe/nix-config/modules/nixos/programs/packages.nix`. Inside the `environment.systemPackages = with pkgs; [ ... ];` block, add any of these three that are not already present:

```
    home-manager
    micro
    git
```

If all three are already there, skip this step.

- [ ] **Step 3: Add portal packages to xdg.nix**

Open `/home/felipe/nix-config/modules/nixos/desktop/xdg.nix`. If it has a `environment.systemPackages = with pkgs; [ ... ];` block, append:

```
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
```

If no `environment.systemPackages` block exists, add one at the top level of the module:

```nix
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
  ];
```

- [ ] **Step 4: Remove `environment.systemPackages` from host file**

In `/home/felipe/nix-config/hosts/nixos/default.nix`, delete the entire block:

```nix
  environment.systemPackages = with pkgs; [
    home-manager
    micro
    git
    vscode
    inputs.zen-browser.packages."${system}".default

    # Portal packages for file dialogs to work in Wayland
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
  ];
```

(Currently around lines 253-264. Note: `vscode` and `zen-browser` are intentionally dropped from system here — they will be picked up via HM in Steps 5-6.)

- [ ] **Step 5: Re-enable zen-browser HM import**

Open `/home/felipe/nix-config/modules/home-manager/profiles/desktop.nix`. Find the line:

```
    # ../programs/browsers/zen-browser.nix
```

Uncomment it:

```
    ../programs/browsers/zen-browser.nix
```

- [ ] **Step 6: Move kate from user.packages to HM home.packages**

In `/home/felipe/nix-config/hosts/nixos/default.nix`, find:

```nix
      packages = with pkgs; [
        kdePackages.kate
        # thunderbird  # Disabled - uncomment to enable
      ];
```

Replace with:

```nix
      packages = [ ];
```

(Or delete the entire `packages = ...;` line if the surrounding `users.users.felipe` block tolerates it — both are equivalent.)

In `/home/felipe/nix-config/home-manager/home.nix`, find:

```nix
  home.packages = with pkgs; [
    numlockx # Enable numlock in graphical session
```

Insert immediately after `numlockx ...` line:

```
    kdePackages.kate
    vscode
```

Resulting beginning of block:

```nix
  home.packages = with pkgs; [
    numlockx # Enable numlock in graphical session
    kdePackages.kate
    vscode
```

(`vscode` is added here because the HM `vscode.nix` module only generates a `colors.json` — it does not install the editor. Without this line, dropping vscode from `environment.systemPackages` in Step 4 would remove access to the binary.)

- [ ] **Step 7: Run flake check**

```bash
cd /home/felipe/nix-config
nix flake check
```
Expected: no errors.

- [ ] **Step 8: Build system (dry-run)**

```bash
cd /home/felipe/nix-config
sudo nixos-rebuild build --flake .#nixos
```
Expected: succeeds.

- [ ] **Step 9: Build home-manager (dry-run)**

```bash
cd /home/felipe/nix-config
home-manager build --flake .#felipe
```
Expected: succeeds.

- [ ] **Step 10: Sanity-check HM closure contains the moved binaries**

```bash
cd /home/felipe/nix-config
home-manager build --flake .#felipe
ls -L result/home-path/bin/ | grep -E 'zen|kate|^code$' || echo "binaries not in expected path"
```
Expected: `zen` (or `zen-browser`), `kate`, and `code` appear in the result. If any are missing, check via:

```bash
find result/home-path -maxdepth 3 -name 'kate*' -o -name 'zen*' -o -name 'code' 2>/dev/null
```

- [ ] **Step 11: Format**

```bash
cd /home/felipe/nix-config
nixfmt hosts/nixos/default.nix modules/nixos/programs/packages.nix modules/nixos/desktop/xdg.nix modules/home-manager/profiles/desktop.nix home-manager/home.nix
```

- [ ] **Step 12: Commit phase 3**

```bash
cd /home/felipe/nix-config
git add -A
git commit -F - <<'EOF'
refactor(packages): consolidate systemPackages into packages.nix and HM

Moves vscode + zen-browser to home-manager (where the matching modules
already live), moves kdePackages.kate to home.packages, and moves the
xdg-desktop-portal triplet into desktop/xdg.nix where the portal config
already lives. environment.systemPackages now only lives in
modules/nixos/programs/packages.nix.
EOF
```

---

## Task 4: Phase 4 — Split host file

**Files:**
- Create: 13 new modules under `modules/nixos/{core,programs,services}/`
- Modify: `hosts/nixos/default.nix` (reduce to composition only)

This is the largest task. Each new module is a focused fragment lifted from the current host file. The goal is 1:1 transcription — no behavior change.

### Task 4.1: Create core modules

- [ ] **Step 1: Create `modules/nixos/core/boot.nix`**

Write to `/home/felipe/nix-config/modules/nixos/core/boot.nix`:

```nix
{ ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
```

- [ ] **Step 2: Create `modules/nixos/core/networking.nix`**

Write to `/home/felipe/nix-config/modules/nixos/core/networking.nix`:

```nix
{ ... }:

{
  networking.networkmanager.enable = true;
}
```

(Note: `networking.hostName` stays in the host file as host-unique — see Task 4.4 Step 1.)

- [ ] **Step 3: Create `modules/nixos/core/locale.nix`**

Write to `/home/felipe/nix-config/modules/nixos/core/locale.nix`:

```nix
{ ... }:

{
  time.timeZone = "America/Santarem";

  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };
}
```

- [ ] **Step 4: Create `modules/nixos/core/audio.nix`**

Write to `/home/felipe/nix-config/modules/nixos/core/audio.nix`:

```nix
{ ... }:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
  };
}
```

- [ ] **Step 5: Create `modules/nixos/core/users.nix`**

Write to `/home/felipe/nix-config/modules/nixos/core/users.nix`:

```nix
{ pkgs, ... }:

{
  users = {
    defaultUserShell = pkgs.zsh;
    users.felipe = {
      isNormalUser = true;
      description = "felipe";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        "audio"
        "video"
      ];
      packages = [ ];
    };
  };
}
```

(`packages = [ ];` retained as a placeholder — kate was moved to HM in Task 3.)

- [ ] **Step 6: Create `modules/nixos/core/nix.nix`**

Write to `/home/felipe/nix-config/modules/nixos/core/nix.nix`:

```nix
{ inputs, ... }:

{
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    settings.auto-optimise-store = true;
    nixPath = [ "nixpkgs = ${inputs.nixpkgs}" ];

    # Automatic garbage collection (disabled — see flake.nix nh wrapper)
    /*
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    */
  };
}
```

- [ ] **Step 7: Create `modules/nixos/core/documentation.nix`**

Write to `/home/felipe/nix-config/modules/nixos/core/documentation.nix`:

```nix
{ ... }:

{
  # Skip building NixOS option docs (options.json) — avoids the upstream
  # "builtins.derivation ... without a proper context" eval warning.
  documentation.enable = false;
  documentation.nixos.enable = false;
}
```

### Task 4.2: Create programs modules

- [ ] **Step 1: Create `modules/nixos/programs/base.nix`**

Write to `/home/felipe/nix-config/modules/nixos/programs/base.nix`:

```nix
{ ... }:

{
  programs.firefox.enable = true;
  programs.zsh.enable = true;
}
```

- [ ] **Step 2: Create `modules/nixos/programs/direnv.nix`**

Write to `/home/felipe/nix-config/modules/nixos/programs/direnv.nix`:

```nix
{ ... }:

{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
}
```

### Task 4.3: Create services modules

- [ ] **Step 1: Create `modules/nixos/services/printing.nix`**

Write to `/home/felipe/nix-config/modules/nixos/services/printing.nix`:

```nix
{ ... }:

{
  services.printing.enable = true;
}
```

- [ ] **Step 2: Create `modules/nixos/services/flatpak.nix`**

Write to `/home/felipe/nix-config/modules/nixos/services/flatpak.nix`:

```nix
{ ... }:

{
  services.flatpak.enable = true;
}
```

- [ ] **Step 3: Create `modules/nixos/services/udisks2.nix`**

Write to `/home/felipe/nix-config/modules/nixos/services/udisks2.nix`:

```nix
{ ... }:

{
  services.udisks2.enable = true;
}
```

- [ ] **Step 4: Create `modules/nixos/services/mpd.nix`**

Write to `/home/felipe/nix-config/modules/nixos/services/mpd.nix`:

```nix
{ ... }:

{
  services.mpd = {
    enable = true;
    settings.music_directory = "/home/felipe/Music";
  };
}
```

### Task 4.4: Rewrite host file as composition

- [ ] **Step 1: Rewrite `hosts/nixos/default.nix`**

Open `/home/felipe/nix-config/hosts/nixos/default.nix` and **replace the entire file content** with:

```nix
{
  inputs,
  stylixConfig,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared/stylix.nix
    ../../modules/shared/nixpkgs-config.nix
    inputs.home-manager.nixosModules.home-manager

    # Core
    ../../modules/nixos/core/boot.nix
    ../../modules/nixos/core/networking.nix
    ../../modules/nixos/core/locale.nix
    ../../modules/nixos/core/audio.nix
    ../../modules/nixos/core/users.nix
    ../../modules/nixos/core/nix.nix
    ../../modules/nixos/core/nh.nix
    ../../modules/nixos/core/substituters.nix
    ../../modules/nixos/core/documentation.nix

    # Desktop
    ../../modules/nixos/desktop/stylix-wallpaper.nix
    ../../modules/nixos/desktop/niri.nix
    ../../modules/nixos/desktop/xdg.nix

    # Hardware
    ../../modules/nixos/hardware/upower.nix
    ../../modules/nixos/hardware/vial.nix

    # Services
    ../../modules/nixos/services/docker.nix
    ../../modules/nixos/services/jellyfin.nix
    ../../modules/nixos/services/navidrome/navidrome.nix
    ../../modules/nixos/services/printing.nix
    ../../modules/nixos/services/flatpak.nix
    ../../modules/nixos/services/udisks2.nix
    ../../modules/nixos/services/mpd.nix

    # Programs
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
    users.felipe = import ../../home-manager/home.nix;
  };

  networking.hostName = "nixos";  # host-unique
  system.stateVersion = "24.05";  # host-unique
}
```

(`users.felipe = import ../../home-manager/home.nix;` will be updated to `./home.nix` in Phase 5.)

- [ ] **Step 2: Verify line count**

```bash
cd /home/felipe/nix-config
wc -l hosts/nixos/default.nix
```
Expected: ~60 lines (was 304). If significantly higher (>80), re-check that all extracted blocks were removed.

- [ ] **Step 3: Run flake check**

```bash
cd /home/felipe/nix-config
nix flake check
```
Expected: no errors. **Common failure modes:**
- "attribute `nh` missing": `core/nh.nix` referenced but `nh.nix` doesn't import correctly. Confirm `modules/nixos/core/nh.nix` exists and is valid.
- duplicate definition errors: a block was extracted but the original was not removed from the host file. Diff against the previous host file commit to identify.

- [ ] **Step 4: Build system (dry-run)**

```bash
cd /home/felipe/nix-config
sudo nixos-rebuild build --flake .#nixos
```
Expected: succeeds.

- [ ] **Step 5: Build home-manager (dry-run)**

```bash
cd /home/felipe/nix-config
home-manager build --flake .#felipe
```
Expected: succeeds.

- [ ] **Step 6: 1:1 transcription sanity check**

Phase 4 is pure code movement — same NixOS config, just split across files. The system closure's store path should be **byte-for-byte identical** before vs. after.

```bash
cd /home/felipe/nix-config
sudo nixos-rebuild build --flake .#nixos
readlink -f ./result > /tmp/phase4-after.path
git stash --include-untracked
sudo nixos-rebuild build --flake .#nixos
readlink -f ./result > /tmp/phase4-before.path
git stash pop
diff /tmp/phase4-before.path /tmp/phase4-after.path && echo MATCH
```
Expected: `diff` produces no output, prints `MATCH`. If `diff` prints two lines, the closures differ — open both files with the `Read` tool to get the exact store paths, then run `nix store diff-closures <path-before> <path-after>` with both paths inlined manually to see what diverged. Trace the diff back to a missing or duplicated setting in the extracted modules. **Do not commit until the closures match.**

Cleanup after success: `rm /tmp/phase4-before.path /tmp/phase4-after.path`.

- [ ] **Step 7: Format**

```bash
cd /home/felipe/nix-config
nixfmt-tree modules/nixos/core modules/nixos/programs modules/nixos/services hosts/nixos/default.nix
```

- [ ] **Step 8: Commit phase 4**

```bash
cd /home/felipe/nix-config
git add -A
git commit -F - <<'EOF'
refactor(host): split monolithic default.nix into focused modules

Extracts boot, networking, locale, audio, users, nix, documentation,
direnv, base programs (firefox/zsh), printing, flatpak, udisks2, and
mpd into individual modules under modules/nixos/{core,programs,services}/.
hosts/nixos/default.nix becomes pure composition (~60 lines) with only
host-unique settings (hostName, stateVersion) inline.

Behavior preserved 1:1 (verified by store path of system.build.toplevel).
EOF
```

---

## Task 5: Phase 5 — Move `home.nix`

**Files:**
- Move: `home-manager/home.nix` → `hosts/nixos/home.nix`
- Modify: moved file (update import paths)
- Modify: `flake.nix` (update `homeConfigurations.felipe` path)
- Modify: `hosts/nixos/default.nix` (update `users.felipe = import ...` path)
- Delete: empty `home-manager/` dir

- [ ] **Step 1: Move home.nix**

```bash
cd /home/felipe/nix-config
git mv home-manager/home.nix hosts/nixos/home.nix
```

- [ ] **Step 2: Update import paths in moved file**

Open `/home/felipe/nix-config/hosts/nixos/home.nix`. In the `imports = [ ... ];` block, change every `../modules/...` to `../../modules/...`:

Before:
```nix
  imports = [
    ../modules/shared/stylix.nix
    ../modules/home-manager/profiles/desktop.nix
    ../modules/shared/nixpkgs-config.nix
  ];
```

After:
```nix
  imports = [
    ../../modules/shared/stylix.nix
    ../../modules/home-manager/profiles/desktop.nix
    ../../modules/shared/nixpkgs-config.nix
  ];
```

- [ ] **Step 3: Update `flake.nix`**

Open `/home/felipe/nix-config/flake.nix`. Find the `homeConfigurations.felipe = { ... }` block. Inside it, find:

```nix
        modules = [ ./home-manager/home.nix ];
```

Replace with:

```nix
        modules = [ ./hosts/nixos/home.nix ];
```

- [ ] **Step 4: Update host file HM reference**

Open `/home/felipe/nix-config/hosts/nixos/default.nix`. Find:

```nix
    users.felipe = import ../../home-manager/home.nix;
```

Replace with:

```nix
    users.felipe = import ./home.nix;
```

- [ ] **Step 5: Remove empty home-manager dir**

```bash
cd /home/felipe/nix-config
rmdir home-manager
```
Expected: succeeds (dir is empty after the git mv).

If it fails with "Directory not empty", run `ls home-manager/` to see what's left and either move it or report back.

- [ ] **Step 6: Run flake check**

```bash
cd /home/felipe/nix-config
nix flake check
```
Expected: no errors.

- [ ] **Step 7: Confirm flake outputs**

```bash
cd /home/felipe/nix-config
nix flake show 2>&1 | grep -E 'nixosConfigurations|homeConfigurations'
```
Expected output contains both `nixosConfigurations` and `homeConfigurations.felipe`.

- [ ] **Step 8: Build system (dry-run)**

```bash
cd /home/felipe/nix-config
sudo nixos-rebuild build --flake .#nixos
```
Expected: succeeds.

- [ ] **Step 9: Build home-manager (dry-run)**

```bash
cd /home/felipe/nix-config
home-manager build --flake .#felipe
```
Expected: succeeds.

- [ ] **Step 10: Format**

```bash
cd /home/felipe/nix-config
nixfmt hosts/nixos/home.nix hosts/nixos/default.nix flake.nix
```

- [ ] **Step 11: Commit phase 5**

```bash
cd /home/felipe/nix-config
git add -A
git commit -F - <<'EOF'
refactor(home): move home.nix into hosts/nixos/

Relocates home-manager/home.nix to hosts/nixos/home.nix to mirror the
host config layout — same dir = same host. Updates relative imports
inside the moved file, the standalone HM modules path in flake.nix,
and the users.felipe reference in hosts/nixos/default.nix. Removes
the now-empty home-manager/ directory.
EOF
```

---

## Task 6: Final smoke test

This task **does** apply changes to the running system. Only run after Tasks 1-5 are committed and all dry-run builds passed.

- [ ] **Step 1: Build for next boot (safety)**

```bash
cd /home/felipe/nix-config
nh os boot
```
Expected: builds, marks the new generation as the default for next boot. Current generation stays active until reboot. Safe rollback path.

- [ ] **Step 2: Apply system switch**

```bash
cd /home/felipe/nix-config
nh os switch
```
Expected: activates the new generation in-place. If activation fails, run `sudo nixos-rebuild --rollback switch` to revert.

- [ ] **Step 3: Apply HM switch**

```bash
cd /home/felipe/nix-config
nh home switch
```
Expected: HM activation succeeds, noctalia reload activation script runs (visible in output if niri is running).

- [ ] **Step 4: Visual smoke checks**

Run these manually and confirm:

- Niri session still active (no restart needed).
- `noctalia-shell` running: `pgrep -x noctalia-shell` returns a PID.
- Audio: `pactl info` reports PipeWire as server.
- Firefox launches: `firefox --version` succeeds.
- Zen browser launches: `zen` or `zen-browser` from a launcher.
- Kate launches: `kate --version` succeeds.
- File dialog in a Wayland app (e.g. open via Firefox `Ctrl+O`): renders without portal errors.

If any of the above fail, capture the error and rollback:

```bash
sudo nixos-rebuild --rollback switch
home-manager generations | head -3
home-manager rollback   # if available, else manually activate previous
```

- [ ] **Step 5: Merge to main**

If all smoke checks pass:

```bash
cd /home/felipe/nix-config
git checkout main
git merge --ff-only refactor/repo-reorg
```

If fast-forward fails (someone pushed to `main`), rebase first:

```bash
cd /home/felipe/nix-config
git checkout refactor/repo-reorg
git rebase main
git checkout main
git merge --ff-only refactor/repo-reorg
```

Do **not** push without the user's explicit say-so.

---

## Spec coverage check

| Spec requirement | Task |
|---|---|
| Phase 1: archive dead modules + strip commented imports | Task 1 |
| Phase 2: central `nixpkgs-config.nix` + HM split caveat handling | Task 2 |
| Phase 3: consolidate `systemPackages` (vscode/zen → HM, portals → xdg, kate → HM) | Task 3 |
| Phase 4: split host file into core/programs/services modules | Task 4 |
| Phase 5: move `home.nix` → `hosts/nixos/home.nix` | Task 5 |
| Verification per phase (`flake check` + both builds) | every phase task, last 3 steps |
| Final activation only after all phases merge | Task 6 |
| No `Co-Authored-By: Claude` trailer | All `git commit` invocations use heredoc with hand-written messages |
| Wallpapers + `NIRI_IDEAS.md` out of scope | Not referenced |

## Notes for the executing engineer

- **Stop on red.** If any `nix flake check`, `nixos-rebuild build`, or `home-manager build` fails, **do not commit**. Diagnose first. The whole point of phased dry-runs is to never push a broken generation.
- **`git mv` not `mv`.** Preserves history for the moved modules. The plan uses `git mv` throughout.
- **`nixfmt` is opinionated** but never introduces semantic changes. Run it before each commit for consistency.
- **The repo CLAUDE.md says:** never add `Co-Authored-By: Claude` trailers. The heredocs above already comply — do not modify them to add the trailer.
- **Hardware-specific file is host-local.** Do not touch `hosts/nixos/hardware-configuration.nix` — it's generated and host-bound.
