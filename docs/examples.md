# Examples

## Runnable Example

[`examples/local-consumer/`](../examples/local-consumer/) is the only runnable
example kept in this repository.

It is intentionally generic:

- no personal host names
- no geography-specific DNS providers
- no migration cleanup logic
- no assumptions about a larger local module tree

Use it as the reference shape for external consumers.

## What The Example Covers

- `flake.nix`: imports this repository through a local `path:` input
- `nixos-example.nix`: enables the exported NixOS module with a fake package for
  evaluation
- `home-example.nix`: enables the exported Home Manager module
- `adapter.nix`: shows how a downstream flake can map its own proxy abstraction
  into `programs.clash-party.links.*`
- `profile-balanced.nix`: provides a neutral profile with generic defaults

## What Is Intentionally Not In Examples

Migration-specific templates for one personal flake are documented under
[`docs/migration-from-personal-flake.md`](./migration-from-personal-flake.md)
instead of living in `examples/`.
