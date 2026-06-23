{ config, inputs, lib, pkgs, ... }:

let
  cfg = config.desktop.clash-party;
  clashPartyPackage =
    inputs.clash-party-packaging.packages.${pkgs.stdenv.hostPlatform.system}.clash-party;
in
{
  imports = [ inputs.clash-party-packaging.nixosModules.default ];

  options.desktop.clash-party = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Clash Party through the external packaging flake.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.clash-party = {
      enable = true;
      package = clashPartyPackage;
    };

    # Personal repository policy stays here, not in the shared flake.
    desktop.proxy = {
      enable = true;
      mixedPort = lib.mkDefault 7897;
      dnsPort = lib.mkDefault 11453;
    };
  };
}
