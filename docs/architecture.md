# Architecture

This repository exists to keep Clash Party packaging and reusable integration
logic out of any single personal NixOS flake.

The split is intentional:

- this repository owns upstream-coupled build and packaging logic
- this repository exports reusable Nix packages, a NixOS module, and a Home
  Manager module
- downstream flakes keep host policy, frontend selection, and personal proxy
  abstractions local

## Design Goals

1. Track upstream Clash Party releases in one place.
2. Publish reusable Linux artifacts that Nix can consume directly.
3. Keep package, system integration, and declarative GUI config separate.
4. Avoid baking personal abstractions such as `desktop.proxy` into the shared
   flake API.
5. Surface upstream breakage through CI and flake checks.

## Repository Layout

```text
.
├── docs/
├── examples/
│   └── local-consumer/
├── lib/
├── modules/
│   ├── home-manager/
│   └── nixos/
├── packages/
├── scripts/
└── .github/workflows/
```

## Boundaries

### `packages/clash-party-unwrapped.nix`

Owns:

- fetching the published `tar.xz`
- unpacking the artifact into `$out`
- preserving the released tree with minimal transformation

Does not own:

- `/var/lib` materialization
- setuid handling
- machine-specific defaults

### `packages/clash-party.nix`

Owns:

- generic wrapping
- launcher normalization
- runtime path fixes needed by Nix packaging

Does not own:

- host policy
- privileged system integration

### `modules/nixos/clash-party.nix`

Owns:

- enabling the package on the system
- sidecar materialization under `/var/lib/clash-party/sidecar`
- setuid installation for Mihomo sidecars on NixOS
- generic TUN-related integration needed for Clash Party to function

Does not own:

- frontend selection
- concrete port defaults
- GNOME- or Hyprland-specific policy
- personal proxy abstraction

### `modules/home-manager/clash-party.nix`

Owns:

- declarative app config generation
- declarative Mihomo config generation
- typed options for supported app and Mihomo fields
- explicit linkage points for downstream values

The module should only read values passed through its own option tree, such as
`programs.clash-party.links.*`.

### `lib/`

Owns:

- shared types
- config mapping helpers
- merge helpers used by the Home Manager module

## Downstream Integration Model

The intended downstream layering is:

1. keep a local canonical proxy abstraction in the consumer flake
2. import this repository's NixOS and Home Manager modules
3. add a thin adapter that maps local values into
   `programs.clash-party.links.*`

That keeps this repository reusable without forcing other flakes to adopt one
specific local option schema.

## Release Flow

1. GitHub Actions builds from an upstream release tag.
2. Native modules such as `sysproxy-rs` are compiled as part of the upstream
   build.
3. The workflow repackages the Linux app tree into a Nix-friendly `tar.xz`.
4. Release archives and checksums are published on GitHub Releases.
5. `packages/sources.nix` points Nix packaging at those release artifacts.
