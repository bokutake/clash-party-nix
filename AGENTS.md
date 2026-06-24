# AGENTS.md

This repository packages upstream Clash Party releases for downstream Nix
consumption.

## Review Focus

When reviewing pull requests, prioritize packaging breakage over style.

Treat the following as high-signal risks:

- upstream build entrypoints changed and the current scripts no longer match
- native modules such as `sysproxy-rs` may stop building or loading
- expected Electron output layout changed
- the packaged archive no longer contains the files assumed by the smoke tests
- the release artifact naming changed in a way that would break
  `packages/sources.nix`
- the NixOS or Home Manager module interface changed incompatibly

## Upstream Tag Bumps

For pull requests that update the tracked upstream tag:

1. inspect the upstream commit range between the previous and new tag
2. compare that diff against the assumptions in `scripts/` and `packages/`
3. call out any likely breakage in build commands, native bindings, output
   layout, or release asset naming
4. state explicitly when no likely breaking change is visible

## Findings

- Lead with concrete breakage risks.
- Prefer file references and exact assumptions.
- Keep summaries brief after the findings.
