{
  config,
  pkgs,
  lib,
  stylixConfig,
  ...
}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = false;
    syntaxHighlighting.enable = true;

    shellAliases =
      let
        flakeDir = "~/nix-config";
        # Apply stylix wallpaper after rebuild using awww. The path is resolved
        # at runtime from the HM profile the switch just wrote — baking it at
        # build time (or reading the shell env) goes stale in shells that
        # predate the config change.
        applyWallpaper = ''
          # Refresh session vars from the freshly-switched HM profile
          # (~/.local/state for standalone HM, /etc/profiles for NixOS-managed)
          source "$HOME/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh" 2>/dev/null \
            || source /etc/profiles/per-user/felipe/etc/profile.d/hm-session-vars.sh 2>/dev/null

          WALLPAPER="$HOME/nix-config/assets/wallpapers/wallpaper.png"
          [ -n "$STYLIX_WALLPAPER" ] && WALLPAPER=$(eval echo "$STYLIX_WALLPAPER")

          echo "========================================" >&2
          echo "[DEBUG] Starting wallpaper application..." >&2
          echo "[DEBUG] Wallpaper path: $WALLPAPER" >&2
          echo "[DEBUG] File exists check: $([ -f "$WALLPAPER" ] && echo YES || echo NO)" >&2
          echo "========================================" >&2

          awww img "$WALLPAPER" --resize ${stylixConfig.wallpaperResize} && echo 'Wallpaper applied successfully' || echo 'Failed to apply wallpaper'
        '';
      in
      {
        # ===== NIXOS SYSTEM MANAGEMENT (nh) =====
        # Rebuild and switch to new NixOS configuration (also applies wallpaper)
        rb = "nixre 'os switch' nh os switch ${flakeDir} && ${applyWallpaper}";

        # Rebuild and switch NixOS configuration offline
        rbo = "nixre 'os switch' nh os switch ${flakeDir} --offline && ${applyWallpaper}";

        # Rebuild and switch NixOS configuration using nixos-rebuild
        rbn = "nixre 'os switch' sudo nixos-rebuild switch --flake ${flakeDir} && ${applyWallpaper}";

        # Rebuild and switch NixOS configuration offline using nixos-rebuild
        rbno = "nixre 'os switch' sudo nixos-rebuild switch --flake ${flakeDir} --offline && ${applyWallpaper}";

        # Update flake.lock with latest versions from inputs
        upd = "nixre 'update' nh os switch ${flakeDir} -u";

        # Update flake.lock file using nix flake update
        updn = "sudo nix flake update";

        # ===== HOME-MANAGER CONFIGURATION (nh) =====
        # Apply home-manager configuration (also re-applies the wallpaper)
        hms = "nixre 'home switch' nh home switch ${flakeDir} && ${applyWallpaper}";

        # Apply home-manager with backup of previous generation
        hmsb = "nixre 'home switch' nh home switch ${flakeDir} -b backup && ${applyWallpaper}";

        # ===== CONFIGURATION EDITING =====
        # Edit main NixOS configuration file
        confc = "code ${flakeDir}";
        confv = "vim ${flakeDir}";

        # Edit NixOS packages configuration
        pkgs = "nvim ${flakeDir}/nixos/packages.nix";

        # ===== NIX BUILD TESTING (nh) =====
        # Build NixOS configuration without switching (test build)
        nbt = "nixre 'os build' nh os build ${flakeDir}";

        # Dry run - show what would change without applying
        ndr = "nixre 'dry-run' sudo nixos-rebuild dry-run --flake ${flakeDir}";

        # Build current system configuration
        nbc = "nixre 'build' sudo nix build ${flakeDir}#nixosConfigurations.$(hostname).config.system.build.toplevel";

        # Build home-manager configuration
        nbh = "nixre 'home build' nh home build";

        # ===== DEVELOPMENT ENVIRONMENTS (nh) =====
        # Enter development shell for current directory
        dev = "nh develop";

        # Enter development shell from flake
        dev-flake = "nh develop ${flakeDir}";

        # Create shell with specific package(s) - usage: n-shell package1 package2
        n-shell = "nh shell";

        # ===== PACKAGE MANAGEMENT (nh) =====
        # Search for packages - usage: n-search package-name
        n-search = "nh search";

        # Install package to user profile - usage: n-install package-name
        n-install = "nh profile install";

        # Remove package from user profile - usage: n-remove package-name
        n-remove = "nh profile remove";

        # ===== MAINTENANCE & CLEANUP (nh) =====
        # Garbage collect unused nix store paths
        ngc = "nh clean all";

        # Garbage collect with dry-run (show what would be deleted)
        ngcd = "nh clean all --dry";

        # Garbage collect current user's profiles only
        ngcu = "nh clean user";

        # Check flake for issues
        flake-check = "nixre 'flake check' nh check";

        # Show nix system information
        nix-info = "nh os info";

        # Inspect nix store / system bloat (top packages by size)
        nbloat = "${flakeDir}/scripts/nix-bloat.sh";

        # ===== GIT COMMANDS =====
        # Quick status
        gst = "git status";

        # Add files
        gadd = "git add";

        # Commit changes
        gcom = "git commit";

        # Branch management
        gbr = "git branch";

        # Checkout (switch branch/file)
        gch = "git checkout";
        gco = "git checkout";

        # Push to remote
        gpsh = "git push";
        gpush = "git push";

        # Pull from remote
        gpll = "git pull";
        gpull = "git pull";

        # Fetch from remote
        gftch = "git fetch";
        gftcho = "git fetch origin";

        # Log viewing
        glog = "git log";

        # Diff viewing
        gdiff = "git diff";

        # Merge branches
        gmrg = "git merge";

        # ===== GENERAL UTILITY =====
        # List all files including hidden ones
        ll = "ls -a";

        # Quick vim alias
        # v = "nvim";

        # Edit system files with sudo
        se = "sudoedit";

        # System information display
        ff = "fastfetch";

        # OpenCode CLI
        oc = "opencode";

        # Bare OpenCode — isolated HOME (~/.opencode-home), no personal config/state/auth
        ocb = "opencode-bare";

        # Zoxide directory jumping
        z = "__zoxide_z";

        # Bitwarden Secrets Manager CLI (docker wrapper)
        bws = "/home/felipe/bws/bws";
      };

    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";

    oh-my-zsh = {
      enable = true;
      plugins = [
        "aliases"
        "alias-finder"
        "colorize"
        "command-not-found"
        "composer"
        "copypath"
        "docker"
        "docker-compose"
        "flutter"
        "git"
        "golang"
        "gh"
        "git-auto-fetch"
        "sudo"
        # "thefuck"
        "vscode"
        "zsh-interactive-cd"
      ];
      theme = "minimal";
      # Themes I liked (https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)
      # lambda, blinks, strug, sammy, refined, peepcode, nicoulaj, kardan, emotty, bureau, minimal
    };

    initContent = ''
            # Notify after rebuild commands (critical priority, persists until dismissed)
            nixre() {
              local label="$1" ec pretty
              shift
              SECONDS=0
              "$@"
              ec=$?
              if [ $SECONDS -ge 60 ]; then
                pretty="$((SECONDS / 60))m $((SECONDS % 60))s"
              else
                pretty="''${SECONDS}s"
              fi
              if [ $ec -eq 0 ]; then
                ${pkgs.libnotify}/bin/notify-send -a Nix -u critical "✓ $label" "Done — ''${pretty}"
              else
                ${pkgs.libnotify}/bin/notify-send -a Nix -u critical "✗ $label" "Failed ($ec) — ''${pretty}"
              fi
              return $ec
            }

            # hook "F" (or a custom alias) to pay-respects
            eval "$(pay-respects zsh --alias)"

            # If you use oh-my-zsh command-not-found, skip its hook here to avoid duplicates:
            # eval "$(pay-respects zsh --alias --nocnf)"

            # Optional: disable AI suggestions
            # export _PR_AI_DISABLE=1

            # Auto-load Bitwarden Secrets Manager token (file is gitignored, chmod 600)
            if [ -r "$HOME/.config/bws/token.env" ]; then
              set -a
              source "$HOME/.config/bws/token.env"
              set +a
            fi

            # Create a new DataAnnotation task directory with standard structure
            newtask() {
              if [ $# -eq 0 ]; then
                echo "Usage: newtask <task-name>"
                return 1
              fi

              local ROOT="$HOME/Programming/DataAnnotation"
              local DIR="$ROOT/$(date +%F)_$1"

              mkdir -p "$DIR"/{references,work,outputs}

              cp "$ROOT/templates/notes.md" "$DIR/notes.md" 2>/dev/null || true
              cp "$ROOT/templates/task_state.md" "$DIR/TASK_STATE.md" 2>/dev/null || true

              cat > "$DIR/AGENTS.md" <<'EOT'
      # Task

      ## Objective

      ## Task-specific Instructions

      ## Rubric

      ## Constraints

      ## Expected Output

      ## Notes
      EOT

              touch "$DIR/prompt.txt"

              echo
              echo "Created:"
              find "$DIR"
              echo
            }
            # Deja predictive inline suggestions. It replaces zsh-autosuggestions.
            if [[ -r "$HOME/.local/share/deja/init.zsh" ]]; then
              source "$HOME/.local/share/deja/init.zsh"
            elif (( $+commands[deja] )); then
              eval "$(deja init zsh)"
            fi
    '';

  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    # thefuck # has been removed due to lack of maintenance upstream and incompatible with python 3.12+. Consider using 'pay-respects' instead
    fzf
    pay-respects
    deja
    zoxide
    # Bare OpenCode — runs opencode with an isolated HOME so it starts
    # with no personal config, state, or auth (see alias `ocb`)
    (writeShellScriptBin "opencode-bare" ''
      export HOME="$HOME/.opencode-home"
      exec opencode "$@"
    '')
  ];

}
