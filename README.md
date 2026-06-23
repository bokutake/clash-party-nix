# Clash Party Packaging Flake

This repository packages Clash Party as reusable Linux release artifacts and as
a reusable Nix flake. It is intended to separate upstream-coupled packaging and
integration logic from any single personal NixOS repository.

The repository owns:

- upstream release tracking
- Linux artifact production
- reusable Nix packaging
- reusable NixOS integration
- reusable Home Manager integration

The build workflow stays close to the upstream `smart_core` Linux build shape
to validate native components such as `sysproxy-rs`, while publishing artifacts
in a layout that is easier for Nix to consume directly.

Target:

1. Build from upstream release tags, not from the upstream `.deb`.
2. Produce a self-consistent Linux package where native modules such as
   `sysproxy-rs` are built during the normal upstream build.
3. Keep the personal flake responsible only for NixOS integration:
   sidecar relocation, TUN permissions, Home Manager config, and host defaults.

## Repository Layout

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
├── flake.nix
├── flake.lock
├── scripts/
│   ├── build-release.sh
│   ├── package-linux-tarball.sh
│   └── smoke-test.sh
└── README.md
```

## Release Flow

1. GitHub Actions is triggered either by pushing a `v*` tag or by manual dispatch.
2. The workflow clones upstream at the requested tag.
3. It runs the upstream-style Linux build matrix for `amd64` and `arm64`.
4. It repackages the built Linux app tree into a Nix-friendly `tar.xz`.
5. It publishes the generated archives and checksums to a GitHub Release for the same tag.
6. Downstream Nix repositories pin the resulting release URL and hash.

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
- Publishing:
  - upload workflow artifacts during the matrix build
  - aggregate artifacts after both architectures finish
  - create or update a GitHub Release for the resolved tag
- Linux deps:
  - `build-essential`
  - `pkg-config`
  - `ruby`
  - `rpm`
  - `libgtk-3-dev`
  - `libayatana-appindicator3-dev`
  - `patchelf`
  - `xvfb`

The current state is intentionally usable:

- GitHub Actions can build and repackage upstream Linux releases
- GitHub Actions can publish those repackaged archives to GitHub Releases
- the flake exports packages, modules, examples, and checks
- the local consumer examples demonstrate how a personal flake should adapt
  `desktop.proxy` into shared `programs.clash-party.links.*`

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
published release URL and hash once the release pipeline is finalized.

The shared Home Manager module already carries most of the typed Clash Party
schema and currently supports explicit linkage for:

- `links.mixedPort`
- `links.dnsListen`
- `links.systemProxy.enable`
- `links.systemProxy.mode`

It also keeps the raw escape hatches:

- `appConfigPatch`
- `mihomoConfigPatch`

## Local Path Testing

The repository now contains a minimal consumer example under
`examples/local-consumer/`.

It demonstrates:

- importing this repository as `path:../..`
- enabling the NixOS module with a fake package for pure module evaluation
- wiring Home Manager through an explicit adapter from `desktop.proxy` to `programs.clash-party.links.*`
- keeping personal proxy abstractions outside the shared module

Typical local test flow:

1. clone or copy this repository into its own repo
2. fill `packages/sources.nix`, or keep using fake packages for pure module evaluation
3. run `nix flake show ./examples/local-consumer`
4. switch your personal flake to a local `path:` input and adapt your
   `desktop.proxy` values into `programs.clash-party.links.*`

If `packages/sources.nix` points at an absolute local artifact path outside the
flake root, local builds must use `--impure`. For pure evaluation, either:

- publish the artifact and use `url` + `hash`, or
- place the test artifact inside the repository tree

The example adapter lives at `examples/local-consumer/adapter.nix`. It is meant
to show the intended layering:

- your personal flake owns `desktop.proxy`
- repository A owns `programs.clash-party.*`
- a thin adapter maps the former into the latter

The example also includes `examples/local-consumer/profile-balanced.nix`, which
captures a reusable Clash Party default profile without embedding host-specific
DNS endpoints, geography-specific upstream resolvers, or desktop migration
cleanup behavior.

For the later real migration, see `examples/personal-flake-migration/`. Those
files are templates for how a personal repository can consume this shared flake
while keeping local policy local.

The workflow intentionally invokes helper scripts via `bash ./scripts/...`
instead of relying on executable bits, because file mode preservation is easy to
lose when bootstrapping a fresh GitHub repo by hand.

## Repo Responsibilities

- Upstream source fetch and build.
- Native module correctness, including `sysproxy-rs`.
- Linux tarball assembly and smoke tests.
- GitHub Release publication, release metadata, and checksums.

## Personal Flake Responsibilities

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
- `packages/sources.nix` should stay neutral in Git. Local absolute artifact
  paths are fine for private testing, but should not be committed as shared
  defaults.
