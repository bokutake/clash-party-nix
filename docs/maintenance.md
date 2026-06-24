# Maintenance And Automation

This repository separates upstream tracking, PR validation, review, and release
publication into distinct stages.

## Version Tracking

- `versions/upstream.json` stores the tracked upstream Clash Party tag
- `renovate.json5` updates that file from
  `mihomo-party-org/clash-party` Git tags
- the Renovate PR updates only the tracked tag, not
  `packages/sources.nix`

## Pull Request Validation

`pr-ci.yml` runs on pull requests that affect packaging or the tracked upstream
tag.

It performs:

- `nix flake check --no-build`
- Linux builds for `amd64` and `arm64`
- tarball repackaging
- smoke tests

## Codex Review

`codex-review.yml` prepares two pieces of context for Codex:

- the current repository packaging assumptions
- the upstream commit range between the previous and new tracked tag

That review is intended to answer one question: will this upstream change
likely break the current packaging or release logic?

## Release After Merge

`release-on-main.yml` runs after the tracked upstream tag lands on the default
branch.

It:

1. resolves the tracked upstream tag
2. rebuilds `amd64` and `arm64`
3. publishes release artifacts to GitHub Releases
4. rewrites `packages/sources.nix` with the final release URLs and hashes
5. commits the updated source metadata back to the default branch

## Operational Notes

- `packages/sources.nix` represents published artifacts, not merely intended
  upstream versions
- release asset hashes are only considered authoritative after the release job
  finishes
- Codex review requires the Codex GitHub integration to be enabled for the
  repository so `@codex review` comments are handled
