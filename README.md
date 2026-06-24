# Clash Party Nix

This repository builds Clash Party from upstream release tags, publishes
Nix-friendly Linux release artifacts, and exposes reusable Nix packages, a
NixOS module, and a Home Manager module.

It is meant to be imported by another flake, while host policy stays local.

## Quick Start

Add the flake input:

```nix
{
  inputs.clash-party-packaging.url = "github:bokutake/clash-party-nix";
}
```

Import the exported modules or package:

```nix
{
  imports = [
    inputs.clash-party-packaging.nixosModules.default
    inputs.clash-party-packaging.homeManagerModules.default
  ];
}
```

Get the packaged app for the current system:

```nix
inputs.clash-party-packaging.packages.${pkgs.stdenv.hostPlatform.system}.clash-party
```

## Flake Outputs

- `packages.<system>.clash-party`
- `packages.<system>.clash-party-unwrapped`
- `nixosModules.default`
- `homeManagerModules.default`
- `lib`
- `templates.local-consumer`

## Releases

Each GitHub release publishes:

- `clash-party-linux-<version>-amd64.tar.xz`
- `clash-party-linux-<version>-arm64.tar.xz`
- matching `.sha256` checksum files

`packages/sources.nix` pins those artifacts for Nix consumption.

## Documentation

- [Consuming the flake](./docs/consuming.md)
- [Repository architecture](./docs/architecture.md)
- [Migration from a personal flake](./docs/migration-from-personal-flake.md)
- [Examples](./docs/examples.md)
- [Maintenance and automation](./docs/maintenance.md)

## Example

[`examples/local-consumer/`](./examples/local-consumer/) is the generic runnable
consumer example. It demonstrates the intended adapter pattern without embedding
host-local policy.
