# Personal Flake Migration Template

This directory documents the intended integration shape for the personal flake
once repository A is consumed as an input.

Nothing here should be imported automatically. These files are templates and
references for the later migration step.

## Intended Replacement Map

- replace in-tree `packages/clash-party.nix`
  - use `inputs.clash-party-packaging.packages.<system>.clash-party`
- replace in-tree `modules/apps/clash-party.nix`
  - use `inputs.clash-party-packaging.nixosModules.default`
  - keep only personal `desktop.proxy` defaults locally
- replace direct Home Manager implementation sourcing
  - use `inputs.clash-party-packaging.homeManagerModules.default`
  - keep only personal adapter and policy defaults locally

## Files

- `system-adapter.nix`
  - local system-side adapter for `desktop.clash.frontend = "party"`
  - keeps local `desktop.proxy` defaults
- `home-adapter.nix`
  - local Home Manager adapter from `desktop.proxy` to
    `programs.clash-party.links.*`
- `host-defaults.nix`
  - example host/user policy layer that stays personal
