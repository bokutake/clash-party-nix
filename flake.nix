{
  description = "Reusable Clash Party packaging and integration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: lib.genAttrs supportedSystems (system: f system);
      sourceMetadata = import ./packages/sources.nix;
      mkPkgs = system: import nixpkgs { inherit system; };
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

      nixosModules = {
        default = import ./modules/nixos/clash-party.nix;
        clash-party = import ./modules/nixos/clash-party.nix;
      };

      homeManagerModules = {
        default = import ./modules/home-manager/clash-party.nix;
        clash-party = import ./modules/home-manager/clash-party.nix;
      };
    };
}
