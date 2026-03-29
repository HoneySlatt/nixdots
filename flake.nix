{
  description = "Honey NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    awww = {
      url = "git+https://codeberg.org/LGFae/awww";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium = {
      url = "github:AlvaroParker/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {

      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/desktop
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [ inputs.nixvim.homeModules.nixvim ];
            home-manager.users.honey = import ./modules/home/desktop.nix;
          }
        ];
      };

      steamdeck = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/steamdeck
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.honey = import ./modules/home/common.nix;
          }
        ];
      };

    };
  };
}
