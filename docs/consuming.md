# Consuming This Flake

This repository can be consumed in three ways:

- as a package source for `clash-party`
- as a reusable NixOS module
- as a reusable Home Manager module

## Add As An Input

```nix
{
  inputs.clash-party-packaging.url = "github:bokutake/clash-party-nix";
}
```

## Use The Package

```nix
{ inputs, pkgs, ... }:

let
  clashPartyPackage =
    inputs.clash-party-packaging.packages.${pkgs.stdenv.hostPlatform.system}.clash-party;
in
{
  environment.systemPackages = [ clashPartyPackage ];
}
```

## Use The NixOS Module

```nix
{ inputs, pkgs, ... }:

let
  clashPartyPackage =
    inputs.clash-party-packaging.packages.${pkgs.stdenv.hostPlatform.system}.clash-party;
in
{
  imports = [ inputs.clash-party-packaging.nixosModules.default ];

  programs.clash-party = {
    enable = true;
    package = clashPartyPackage;
  };
}
```

## Use The Home Manager Module

```nix
{ inputs, pkgs, ... }:

let
  clashPartyPackage =
    inputs.clash-party-packaging.packages.${pkgs.stdenv.hostPlatform.system}.clash-party;
in
{
  imports = [ inputs.clash-party-packaging.homeManagerModules.default ];

  programs.clash-party = {
    enable = true;
    package = clashPartyPackage;

    links = {
      mixedPort = 7897;
      dnsListen = "0.0.0.0:11453";
      systemProxy = {
        enable = true;
        mode = "manual";
      };
    };
  };
}
```

## Example Consumer

The runnable generic example lives under [`examples/local-consumer/`](../examples/local-consumer/).

It demonstrates:

- importing this repository by local path
- enabling both exported modules
- keeping a downstream proxy abstraction outside the shared module
- adapting downstream values into `programs.clash-party.links.*`

## Release Artifacts

Published releases provide one archive per supported Linux target:

- `clash-party-linux-<version>-amd64.tar.xz`
- `clash-party-linux-<version>-arm64.tar.xz`

`packages/sources.nix` is the only place that should need updating when a new
release artifact is published.
