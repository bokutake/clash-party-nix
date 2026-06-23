{ config, inputs, lib, osConfig, pkgs, ... }:

let
  clashPartyEnabled =
    (osConfig.desktop.clash.frontend or null) == "party"
    || (osConfig.desktop.clash-party.enable or false);
  proxy = osConfig.desktop.proxy;
  clashPartyPackage =
    inputs.clash-party-packaging.packages.${pkgs.stdenv.hostPlatform.system}.clash-party;
in
{
  imports = [ inputs.clash-party-packaging.homeManagerModules.default ];

  config = lib.mkIf clashPartyEnabled {
    programs.clash-party = {
      enable = true;
      package = clashPartyPackage;

      links = {
        mixedPort = proxy.endpoints.mixedPort;
        dnsListen =
          if proxy.dnsPort != null then
            "0.0.0.0:${toString proxy.dnsPort}"
          else
            null;
        systemProxy = {
          enable = true;
          mode = "manual";
        };
      };
    };
  };
}
