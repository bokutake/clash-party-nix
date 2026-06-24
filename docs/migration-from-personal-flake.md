# Migrating From A Personal Flake

This repository is meant to be imported by a personal flake, not to replace the
consumer's local policy layer.

Keep the following split.

## Move Into This Repository

- upstream release tracking
- Linux artifact production
- reusable package definitions
- generic NixOS sidecar integration
- generic Home Manager config generation

## Keep Local

- local canonical proxy abstraction such as `desktop.proxy`
- frontend selection policy
- host-specific port defaults
- geography-specific DNS upstreams
- desktop-specific cleanup behavior
- route exclusions and sniffer skip lists that reflect personal policy

## Adapter Pattern

System-side adapter:

```nix
{ config, inputs, lib, pkgs, ... }:

let
  cfg = config.desktop.clash-party;
  clashPartyPackage =
    inputs.clash-party-packaging.packages.${pkgs.stdenv.hostPlatform.system}.clash-party;
in
{
  imports = [ inputs.clash-party-packaging.nixosModules.default ];

  options.desktop.clash-party.enable = lib.mkEnableOption "Clash Party";

  config = lib.mkIf cfg.enable {
    programs.clash-party = {
      enable = true;
      package = clashPartyPackage;
    };

    desktop.proxy = {
      enable = true;
      mixedPort = lib.mkDefault 7897;
      dnsPort = lib.mkDefault 11453;
    };
  };
}
```

Home Manager adapter:

```nix
{ inputs, lib, osConfig, pkgs, ... }:

let
  clashPartyEnabled = (osConfig.desktop.clash.frontend or null) == "party";
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
          if proxy.dnsPort != null then "0.0.0.0:${toString proxy.dnsPort}" else null;
        systemProxy = {
          enable = true;
          mode = "manual";
        };
      };
    };
  };
}
```

## What Not To Upstream

The following values should stay in the consumer flake or in host-local modules:

- concrete DNS providers
- country-specific fallback filters
- service-specific skip lists
- cleanup code for stale desktop entries from an older local migration

Those values are usually correct for one machine or one user, not for a shared
packaging repository.
