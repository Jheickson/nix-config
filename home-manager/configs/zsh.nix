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
      in
      {
        # ===== NIXOS SYSTEM MANAGEMENT =====
        # Rebuild and switch to new NixOS configuration
        rb = "sudo nixos-rebuild switch --flake ${flakeDir}";
        
        # Update flake.lock with latest versions from inputs
        upd = "sudo nix flake update --flake ${flakeDir}";
        
        # Upgrade system packages and rebuild
        upg = "sudo nixos-rebuild switch --upgrade --flake ${flakeDir}";

        # ===== HOME-MANAGER CONFIGURATION =====
        # Apply home-manager configuration
        hms = "home-manager switch --flake ${flakeDir}";
        
        # Apply home-manager with backup of previous generation
        hmsb = "home-manager switch --flake ${flakeDir} -b backup";

        # ===== CONFIGURATION EDITING =====        
        # Edit main NixOS configuration file
        conf = "code ${flakeDir}";
        
        # Edit NixOS packages configuration
        pkgs = "nvim ${flakeDir}/nixos/packages.nix";

        # ===== NIX BUILD TESTING =====
        # Build NixOS configuration without switching (test build)
        nbt = "sudo nixos-rebuild build --flake ${flakeDir}";
        
        # Dry run - show what would change without applying
        ndr = "sudo nixos-rebuild dry-run --flake ${flakeDir}";
        
        # Build current system configuration
        nbc = "sudo nix build ${flakeDir}#nixosConfigurations.$(hostname).config.system.build.toplevel";
        
        # Build home-manager configuration
        nbh = "nix build ${flakeDir}#homeConfigurations.$(whoami).activationPackage";

        # ===== DEVELOPMENT ENVIRONMENTS =====
        # Enter development shell for current directory
        dev = "nix develop";
        
        # Enter development shell from flake
        dev-flake = "nix develop ${flakeDir}";
        
        # Create shell with specific package(s) - usage: n-shell package1 package2
        n-shell = "nix shell";

        # ===== PACKAGE MANAGEMENT =====
        # Search for packages - usage: n-search package-name
        n-search = "nix search nixpkgs";
        
        # Install package to user profile - usage: n-install package-name
        n-install = "nix profile install nixpkgs#";
        
        # Remove package from user profile - usage: n-remove package-name
        n-remove = "nix profile remove";

        # ===== MAINTENANCE & CLEANUP =====
        # Garbage collect unused nix store paths
        ngc = "nix-collect-garbage -d";
        
        # Garbage collect with dry-run (show what would be deleted)
        ngcd = "nix-collect-garbage --dry-run";
        
        # Check flake for issues
        flake-check = "nix flake check ${flakeDir}";
        
        # Show nix system information
        nix-info = "nix-shell -p nix-info --run 'nix-info -m'";

        # ===== GENERAL UTILITY =====
        # List all files including hidden ones
        ll = "ls -a";
        
        # Quick vim alias
        v = "nvim";
        
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
