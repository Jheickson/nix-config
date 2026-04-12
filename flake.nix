{
  description = "My nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    # When updating the flake, zen-browser will create a new user profile.
    # To go back to the previous profile, you can need to go go "about:profiles"
    # and select the previous profile.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix4nvchad = {
    #   url = "github:nix-community/nix4nvchad";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nixCats = {
      url = "github:BirdeeHub/nixCats-nvim";
    };

    nixvim = {
        url = "github:nix-community/nixvim";
        # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
      };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      determinate,
      ...
    }@inputs:

    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      stylixConfig = import ./modules/shared/stylix-settings.nix { inherit pkgs; };
    in
    {

      packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

      packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

      # nixos - system hostname
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          pkgs-stable = import nixpkgs-stable {
            inherit inputs system;
            config.allowUnfree = true;
          };
          inherit inputs system stylixConfig;
        };
        modules = [
          ./hosts/nixos/default.nix
          inputs.stylix.nixosModules.stylix
          determinate.nixosModules.default
        ];
      };

      homeConfigurations.felipe = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./home-manager/home.nix
          inputs.stylix.homeModules.stylix
        ];
        extraSpecialArgs = { inherit inputs stylixConfig; };
      };

    };
}
