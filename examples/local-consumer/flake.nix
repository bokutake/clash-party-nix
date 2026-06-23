{
  description = "Local consumer example for clash-party-packaging";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    clash-party-packaging.url = "path:../..";
  };

  outputs = inputs@{ nixpkgs, home-manager, clash-party-packaging, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations.example = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          home-manager.nixosModules.home-manager
          clash-party-packaging.nixosModules.default
          ./nixos-example.nix
        ];
        specialArgs = { inherit inputs; };
      };

      homeConfigurations.example = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          clash-party-packaging.homeManagerModules.default
          ./home-example.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
}
