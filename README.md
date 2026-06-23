# Clash Party Upstream Build Draft

This directory is a temporary draft for splitting Clash Party upstream packaging
out of the personal flake.

The GitHub Actions draft here intentionally follows the upstream `smart_core`
workflow's Linux build shape as closely as practical, so validation can start
from known upstream behavior instead of a fully custom pipeline.

Target:

1. Build from upstream release tags, not from the upstream `.deb`.
2. Produce a self-consistent Linux package where native modules such as
   `sysproxy-rs` are built during the normal upstream build.
3. Keep the personal flake responsible only for NixOS integration:
   sidecar relocation, TUN permissions, Home Manager config, and host defaults.

## Suggested Repository Layout

```text
.
├── .github/
│   └── workflows/
│       └── build-from-tag.yml
├── modules/
│   ├── home-manager/
│   └── nixos/
├── lib/
├── packages/
│   ├── clash-party-unwrapped.nix
│   ├── clash-party.nix
│   ├── default.nix
│   └── sources.nix
├── nix/
│   ├── default.nix
│   └── clash-party.nix
├── flake.nix
├── scripts/
│   ├── build-release.sh
│   ├── package-linux-tarball.sh
│   └── smoke-test.sh
├── package.json
└── README.md
```

## Suggested Flow

1. GitHub Actions is triggered either by pushing a `v*` tag or by manual dispatch.
2. The workflow clones upstream at the requested tag.
3. It runs the upstream-style Linux build matrix for `amd64` and `arm64`.
4. It repackages the built Linux app tree into a Nix-friendly `tar.xz`.
5. The personal Nix repo updates only the consumed source/artifact pin and hash.

## Current Workflow Shape

- Trigger:
  - `push.tags = v*`
  - `workflow_dispatch` with optional `upstream_tag`
- Matrix:
  - `x64 -> amd64`
  - `arm64 -> arm64`
- Toolchain:
  - Node 22
  - `pnpm/action-setup@v4`
  - `corepack enable`
  - stable Rust
- Output:
  - `clash-party-linux-<version>-<target>.tar.xz`
  - `clash-party-linux-<version>-<target>.tar.xz.sha256`
- Linux deps:
  - `build-essential`
  - `pkg-config`
  - `ruby`
  - `rpm`
  - `libgtk-3-dev`
  - `libayatana-appindicator3-dev`
  - `patchelf`
  - `xvfb`

This is still a draft. The point is to keep the actual build close to upstream,
while making the published artifact match what the personal flake really wants
to consume.

The repository now also contains an initial reusable flake skeleton:

- `packages/`
  - `clash-party-unwrapped.nix` consumes the published `tar.xz`
  - `clash-party.nix` applies Nix-specific wrapping and sidecar relocation
- `modules/nixos/`
  - generic system integration for sidecar materialization
- `modules/home-manager/`
  - generic declarative config generation with explicit link inputs
- `lib/`
  - shared helpers that will absorb the stronger type and mapping logic over time

`packages/sources.nix` is intentionally a metadata stub. Fill it with the
published artifact URL and hash once the release pipeline is finalized.

The workflow intentionally invokes helper scripts via `bash ./scripts/...`
instead of relying on executable bits, because file mode preservation is easy to
lose when bootstrapping a fresh GitHub repo by hand.

## What This Repo Should Own

- Upstream source fetch and build.
- Native module correctness, including `sysproxy-rs`.
- Linux tarball assembly and smoke tests.
- Release metadata and checksums.

## What The Personal Flake Should Still Own

- `/var/lib/clash-party/sidecar` relocation.
- setuid sidecar install for Clash Party Linux TUN expectations.
- `desktop.proxy` linkage.
- Home Manager declarative config generation.
- Host defaults like `desktop.clash.frontend = "party"`.

## Minimal Smoke Tests

- Assert packaged output contains:
  - `bin/clash-party`
  - `bin/mihomo-party`
  - `lib/clash-party/resources/app.asar`
  - `share/applications/mihomo-party.desktop`
- Optionally launch the desktop binary under xvfb and assert the main process
  does not die.
- Assert the upstream source still contains:
  - `resources/app.asar`
  - `src/native/sysproxy`

## Notes

- The workflow still uses the upstream Electron Builder path to produce a Linux
  app bundle, but it no longer treats `deb` or `rpm` as the public artifact.
- The tarball layout is intentionally closer to a Nix install tree:
  `bin/`, `lib/`, and `share/`.
