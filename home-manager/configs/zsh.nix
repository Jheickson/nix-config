{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases =
      let
        flakeDir = "~/nix-config";
        # Apply stylix wallpaper after rebuild using swww
        # Apply stylix wallpaper after rebuild using swww
        applyWallpaper = "swww img ~/nix-config/nixos/wallpapers/wallpaper.png --resize crop && echo 'Wallpaper applied' || echo 'Failed to apply wallpaper'";
      in
      {
        # ===== NIXOS SYSTEM MANAGEMENT (nh) =====
        # Rebuild and switch to new NixOS configuration (also applies wallpaper)
        rb = "nh os switch ${flakeDir} && ${applyWallpaper}";

        # Rebuild and switch NixOS configuration offline
        rbo = "nh os switch ${flakeDir} --offline && ${applyWallpaper}";

        # Rebuild and switch NixOS configuration using nixos-rebuild
        rbn = "sudo nixos-rebuild switch --flake ${flakeDir} && ${applyWallpaper}";

        # Rebuild and switch NixOS configuration offline using nixos-rebuild
        rbno = "sudo nixos-rebuild switch --flake ${flakeDir} --offline && ${applyWallpaper}";

        # Update flake.lock with latest versions from inputs
        upd = "nh os switch ${flakeDir} -u";

        # Update flake.lock file using nix flake update
        updn = "sudo nix flake update";

        # ===== HOME-MANAGER CONFIGURATION (nh) =====
        # Apply home-manager configuration
        hms = "nh home switch ${flakeDir}";

        # Apply home-manager with backup of previous generation
        hmsb = "nh home switch ${flakeDir} -b backup";

        # ===== CONFIGURATION EDITING =====
        # Edit main NixOS configuration file
        confc = "code ${flakeDir}";
        confv = "vim ${flakeDir}";

        # Edit NixOS packages configuration
        pkgs = "nvim ${flakeDir}/nixos/packages.nix";

        # ===== NIX BUILD TESTING (nh) =====
        # Build NixOS configuration without switching (test build)
        nbt = "nh os build ${flakeDir}";

        # Dry run - show what would change without applying
        ndr = "sudo nixos-rebuild dry-run --flake ${flakeDir}";

        # Build current system configuration
        nbc = "sudo nix build ${flakeDir}#nixosConfigurations.$(hostname).config.system.build.toplevel";

        # Build home-manager configuration
        nbh = "nh home build";

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
        ngc = "nh clean";

        # Garbage collect with dry-run (show what would be deleted)
        ngcd = "nh clean --dry-run";

        # Check flake for issues
        flake-check = "nh check";

        # Show nix system information
        nix-info = "nh os info";

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

        # Zoxide directory jumping
        z = "__zoxide_z";
      };

    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        # "thefuck"
      ];
      theme = "lambda"; # blinks is also really nice
      # TODO Create own zsh theme
    };

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
    # thefuck
    zsh-autocomplete
    zsh-autosuggestions
    zoxide
  ];

}
