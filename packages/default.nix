{ pkgs, source ? null }:

let
  clashPartyUnwrapped = pkgs.callPackage ./clash-party-unwrapped.nix {
    inherit source;
  };
in
{
  clash-party-unwrapped = clashPartyUnwrapped;
  clash-party = pkgs.callPackage ./clash-party.nix {
    clashPartyUnwrapped = clashPartyUnwrapped;
  };
}
