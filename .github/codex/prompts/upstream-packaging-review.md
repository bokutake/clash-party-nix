Review this pull request with a packaging-maintainer mindset.

Primary goal:
- determine whether the current repository packaging and release assumptions are
  likely to break for the new upstream Clash Party version or for the changes in
  this PR

Required context:
- read `AGENTS.md`
- read `.github/codex/context/upstream-change-summary.md` when present
- read `.github/codex/context/packaging-assumptions.md`
- inspect the repository diff itself, especially `scripts/`, `packages/`,
  `.github/workflows/`, and `modules/`

Focus on:
- build entrypoint changes in upstream
- native binding risks, especially `sysproxy-rs`
- changed output layout or asset naming
- assumptions in smoke tests that may no longer hold
- release pipeline mismatches
- Nix interface breakage

Report only meaningful findings. If no likely breaking issue is visible, say so
explicitly.
