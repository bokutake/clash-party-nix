{
  description = "Reusable Clash Party packaging and integration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      lib = nixpkgs.lib;
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: lib.genAttrs supportedSystems (system: f system);
      sourceMetadata = import ./packages/sources.nix;
      mkPkgs = system: import nixpkgs { inherit system; };
      mkCheckPkgs = system: import nixpkgs { inherit system; };
      packageSetFor = system:
        let
          pkgs = mkPkgs system;
          source = sourceMetadata.${system} or null;
        in
        if source == null then
          { }
        else
          let
            clash-party-unwrapped = pkgs.callPackage ./packages/clash-party-unwrapped.nix {
              inherit source;
            };
            clash-party = pkgs.callPackage ./packages/clash-party.nix {
              clashPartyUnwrapped = clash-party-unwrapped;
            };
          in
          {
            inherit clash-party-unwrapped clash-party;
            default = clash-party;
          };
    in
    {
      lib = import ./lib { inherit lib; };

      packages = forAllSystems packageSetFor;

      formatter = forAllSystems (system: (mkPkgs system).nixfmt-rfc-style);

      checks = forAllSystems (
        system:
        let
          pkgs = mkCheckPkgs system;
          nixosEval = lib.nixosSystem {
            inherit system;
            modules = [
              home-manager.nixosModules.home-manager
              self.nixosModules.default
              ./examples/local-consumer/nixos-example.nix
            ];
          };
          homeEval = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              self.homeManagerModules.default
              ./examples/local-consumer/home-example.nix
            ];
            extraSpecialArgs = { inputs = { clash-party-packaging = self; }; };
          };
        in
        {
          nixos-eval = pkgs.runCommand "clash-party-nixos-eval" { } ''
            test -n "${nixosEval.config.system.build.toplevel.drvPath}"
            touch "$out"
          '';

          home-manager-eval = pkgs.runCommand "clash-party-home-manager-eval" { } ''
            test -n "${homeEval.activationPackage.drvPath}"
            touch "$out"
          '';
        }
      );

      nixosModules = {
        default = import ./modules/nixos/clash-party.nix;
        clash-party = import ./modules/nixos/clash-party.nix;
      };

      homeManagerModules = {
        default = import ./modules/home-manager/clash-party.nix;
        clash-party = import ./modules/home-manager/clash-party.nix;
      };

      templates.local-consumer = {
        path = ./examples/local-consumer;
        description = "Minimal consumer flake that imports this repository by local path and wires adapter links.";
      };
    };
}
