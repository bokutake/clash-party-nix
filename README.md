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
├── nix/
│   ├── default.nix
│   └── clash-party.nix
├── scripts/
│   ├── build-release.sh
│   └── smoke-test.sh
├── flake.nix
├── package.json
└── README.md
```

## Suggested Flow

1. GitHub Actions is triggered either by pushing a `v*` tag or by manual dispatch.
2. The workflow clones upstream at the requested tag.
3. It runs the upstream-style Linux build matrix for `amd64` and `arm64`.
4. It uploads either:
   - a built Linux artifact, or
   - a source snapshot plus lockfiles for Nix to rebuild reproducibly.
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
- Linux deps:
  - `build-essential`
  - `pkg-config`
  - `ruby`
  - `rpm`
  - `libgtk-3-dev`
  - `libayatana-appindicator3-dev`
  - `patchelf`
  - `xvfb`

This is still a draft. The point is to make the first GitHub-side validation
close to upstream, then tighten it once you know which exact native pieces still
need extra handling.

## What This Repo Should Own

- Upstream source fetch and build.
- Native module correctness, including `sysproxy-rs`.
- Linux artifact smoke tests.
- Release metadata and checksums.

## What The Personal Flake Should Still Own

- `/var/lib/clash-party/sidecar` relocation.
- setuid sidecar install for Clash Party Linux TUN expectations.
- `desktop.proxy` linkage.
- Home Manager declarative config generation.
- Host defaults like `desktop.clash.frontend = "party"`.

## Minimal Smoke Tests

- `clash-party --help` or equivalent binary startup check.
- Launch the desktop binary under xvfb and assert the main process does not die.
- Assert packaged output contains:
  - `resources/app.asar`
  - `resources/app.asar.unpacked`
  - a Linux `sysproxy-rs` native binding
  - `resources/sidecar/mihomo`

## Notes

- If upstream keeps Electron Builder output stable, consuming the built Linux
  artifact is the least work for the personal flake.
- If upstream build output is unstable, consume a locked source snapshot and let
  Nix rebuild it from source instead.
