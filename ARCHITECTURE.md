# Clash Party Packaging Flake Architecture

This document describes the target shape for turning this draft into a reusable
standalone flake that owns Clash Party packaging, system integration, and Home
Manager integration.

The goal is to move upstream-coupled logic out of the personal NixOS flake
while keeping host-specific policy in the personal repo.

## Design Goals

1. Track upstream Clash Party releases in one place.
2. Publish reusable Linux artifacts and a reusable Nix flake.
3. Keep package, NixOS integration, and Home Manager config separate.
4. Avoid baking personal abstractions such as `desktop.proxy` into the shared
   project.
5. Make upstream breakage visible through structure checks and Nix CI.

## Proposed Repository Layout

```text
.
├── .github/
│   └── workflows/
│       ├── build-from-tag.yml
│       ├── sync-upstream.yml
│       └── flake-ci.yml
├── flake.nix
├── README.md
├── ARCHITECTURE.md
├── packages/
│   ├── default.nix
│   ├── clash-party-unwrapped.nix
│   └── clash-party.nix
├── modules/
│   ├── nixos/
│   │   ├── default.nix
│   │   └── clash-party.nix
│   └── home-manager/
│       ├── default.nix
│       └── clash-party.nix
├── lib/
│   ├── default.nix
│   ├── types.nix
│   └── config-map.nix
├── scripts/
│   ├── build-release.sh
│   ├── package-linux-tarball.sh
│   ├── smoke-test.sh
│   ├── diff-artifact-tree.sh
│   └── update-source.sh
└── ci/
    ├── fixture.nix
    └── checks.nix
```

## Flake API

The flake should export only generic reusable interfaces.

```nix
{
  outputs = { self, nixpkgs, home-manager, ... }: {
    packages = {
      x86_64-linux = {
        clash-party = ...;
        clash-party-unwrapped = ...;
      };
      aarch64-linux = {
        clash-party = ...;
        clash-party-unwrapped = ...;
      };
    };

    nixosModules.default = import ./modules/nixos/clash-party.nix;
    homeManagerModules.default = import ./modules/home-manager/clash-party.nix;

    lib = import ./lib;
  };
}
```

## Module Boundaries

### `packages/clash-party-unwrapped.nix`

Owns:

- fetching the released `tar.xz`
- unpacking into `$out`
- no host policy
- no `/var/lib`
- no setuid changes
- no proxy defaults

This package should closely reflect the published artifact tree.

### `packages/clash-party.nix`

Owns:

- wrapping the unwrapped package
- runtime library path fixes
- launch flags
- any generic launcher normalization

This package should still avoid machine-specific integration.

### `modules/nixos/clash-party.nix`

Owns:

- enabling the package on the system
- materializing privileged sidecars under `/var/lib/clash-party/sidecar`
- setuid install of Mihomo sidecars
- generic TUN-related integration required for Clash Party to work on NixOS

This module should expose generic options such as:

- `programs.clash-party.enable`
- `programs.clash-party.package`
- `programs.clash-party.sidecar.directory`
- `programs.clash-party.sidecar.installSetuid`
- `programs.clash-party.mihomo.packageNames`

This module should not expose or assume:

- `desktop.proxy`
- a specific frontend selector
- a specific mixed port
- a specific DNS port
- GNOME-only behavior

### `modules/home-manager/clash-party.nix`

Owns:

- declarative GUI config generation
- declarative Mihomo config generation
- typed options for app/mihomo fields
- optional linkage to external values via explicit HM options

This module should expose a generic link mechanism instead of reading personal
OS-level abstractions directly. For example:

- `programs.clash-party.links.mixedPort`
- `programs.clash-party.links.dnsListen`
- `programs.clash-party.links.systemProxy`

The current draft already follows this pattern and does not read
`osConfig.desktop.proxy.*` directly.

### `lib/`

Owns:

- reusable enum and submodule types
- config key mapping helpers
- merge helpers between typed Nix options and YAML output

This is the place for the stronger typing work that was previously embedded
directly inside the Home Manager module.

## Migration Map From The Personal Flake

### Move to repository A

From `packages/clash-party.nix`:

- package definition itself
- release fetch logic
- wrapper logic
- sidecar relocation inside the package tree

From `modules/apps/clash-party.nix`:

- `/var/lib/clash-party/sidecar` materialization
- setuid sidecar installation
- system package enablement

From `home/bokutake/programs/clash-party.nix`:

- typed option schema
- YAML generation
- app/mihomo mapping logic
- warnings for store-backed secrets

From the temporary build repo:

- upstream tag build workflow
- tarball repack workflow
- artifact smoke tests

### Keep in the personal flake

From `modules/network/proxy.nix`:

- `desktop.proxy` as the personal canonical proxy abstraction

From `modules/apps/clash.nix` and frontend glue:

- frontend selection policy between Clash Verge and Clash Party
- defaults like `desktop.clash.frontend = "party"`

From host modules:

- host-specific port defaults
- GNOME/Hyprland behavior
- host-specific autostart cleanup choices
- geography-specific DNS upstream choices
- host-specific sniffer skip lists and route exclusions

From `home/bokutake/desktop.nix`:

- cleanup of stale local desktop files if that remains a personal migration aid

## Adapter Pattern For The Personal Flake

After extraction, the personal flake should add a thin adapter layer that maps
its own abstractions onto the shared module.

Example shape:

```nix
{
  imports = [ inputs.clash-party-packaging.homeManagerModules.default ];

  programs.clash-party = {
    enable = true;
    links.mixedPort = config.desktop.proxy.endpoints.mixedPort;
    links.dnsListen = "0.0.0.0:${toString config.desktop.proxy.dnsPort}";
  };
}
```

This keeps the shared module reusable while still letting the personal flake
enforce one canonical proxy model.

## Default Value Split

When moving existing defaults out of the personal flake, split them into two
categories.

### Good shared defaults

- tray/window behavior
- proxy card display behavior
- generic TUN enablement defaults
- generic Mihomo profile persistence
- generic fake-IP mode defaults
- generic sniffer toggles such as `parsePureIp` and `forceDnsMapping`

These belong in reusable example profiles or optional presets.

### Personal policy defaults

- concrete DNS upstream providers
- geo-specific fallback filter domains
- Telegram or Apple-specific sniffer skip lists
- host-specific cleanup of stale desktop entries
- personal frontend selection policy

These should stay in the personal flake even after extraction.

## CI Plan

Repository A should eventually run three independent CI lanes.

### Upstream sync lane

- detect new upstream tags
- build `amd64` and `arm64`
- publish `tar.xz` release artifacts
- open a PR if the packaging repo pins release metadata in-tree

### Flake lane

- `nix flake check`
- build `packages.x86_64-linux.clash-party`
- build `packages.aarch64-linux.clash-party`
- evaluate example NixOS and Home Manager fixtures

### Review lane

- compare previous vs new tarball file trees
- fail if required files disappear
- emit a compact summary for PR review:
  - binary name changes
  - sidecar changes
  - desktop file changes
  - icon changes
  - native module changes

This review lane is the best place to plug in Codex review later.

## Suggested Migration Order

1. Turn the temporary upstream build draft into repository A.
2. Publish `tar.xz` artifacts for both architectures.
3. Add `packages/clash-party-unwrapped.nix` and `packages/clash-party.nix`.
4. Move the current NixOS sidecar logic into repository A.
5. Move the typed Home Manager module into repository A, but replace direct
   `desktop.proxy` reads with explicit link options.
6. Update the personal flake to consume repository A as an input.
7. Delete the in-tree Clash Party packaging and shared logic from the personal
   flake once the host build is green.

## Immediate Refactors Recommended Before Migration

The current personal repo has two places that should be cleaned during the move:

1. The Home Manager module currently mixes:
   - type definitions
   - field mapping
   - personal linkage to `desktop.proxy`

   Split those into `lib/types.nix`, `lib/config-map.nix`, and the HM module.

2. The NixOS module currently forces proxy defaults:
   - `desktop.proxy.enable = true`
   - `mixedPort = 7897`
   - `dnsPort = 11453`

   Those should not survive into the shared repository. They belong in the
   personal flake adapter or host defaults.
