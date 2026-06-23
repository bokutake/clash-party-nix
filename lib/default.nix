{ lib }:

{
  types = import ./types.nix { inherit lib; };
  configMap = import ./config-map.nix { inherit lib; };
}
