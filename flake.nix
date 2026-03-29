{
  description = "cdprice nix system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      # Supported systems
      systems = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];

      username = "cdprice";

      pkgsConfig = {
        allowUnfree = true;
      };

      mkSpecialArgs = system: {
        inherit system username;
      };

      # Create Darwin config for a specific system
      mkDarwinConfig = system: nix-darwin.lib.darwinSystem rec {
        inherit system;
        specialArgs = mkSpecialArgs system;
        modules = [
          ./darwin-configuration.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs.config = pkgsConfig;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = false;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = mkSpecialArgs system;
            home-manager.users.${username} = import ./home.nix;
          }
        ];
      };

      # Create NixOS config for a specific system
      mkNixosConfig = system: nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = mkSpecialArgs system;
        modules = [
          ./nixos-configuration.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.config = pkgsConfig;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = mkSpecialArgs system;
            home-manager.users.${username} = import ./home.nix;
          }
        ];
      };
    in {
      darwinConfigurations =
        let
          configs = nixpkgs.lib.genAttrs
            [ "x86_64-darwin" "aarch64-darwin" ]
            (system: mkDarwinConfig system);
        in configs // {
          "cdprice-lap" = configs."x86_64-darwin";
        };

      nixosConfigurations =
        let
          configs = nixpkgs.lib.genAttrs
            [ "x86_64-linux" "aarch64-linux" ]
            (system: mkNixosConfig system);
        in configs // {
        };
    };
}
