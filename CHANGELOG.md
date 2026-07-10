# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-07-10

### Changed

- `README.md` and `CONTRIBUTING.md` rewritten in a warmer, narrative voice —
  same documented behavior, no functional change. `SKILL.md` (the operational
  spec Claude actually runs) is untouched.
- `README.md`'s "Reliability & evals" section now shows the actual per-case
  benchmark table and two concrete before/after examples from the eval
  transcripts, instead of just a summary pass-rate claim.
- Issue and PR templates given the same friendlier pass.

### Added

- `assets/reflecthero.png` — README header image.

## [0.3.0] - 2026-07-10

### Added

- Routing of surviving lessons to a second home: a proposed edit to the
  repo's project-instructions file (`CLAUDE.md`, an `@`-referenced sub-file,
  or `AGENTS.md`) for a durable convention the whole repo needs, landed via a
  normal PR. Structure-aware — detects and targets the right sub-file rather
  than bloating a root `CLAUDE.md`.
- Two eval cases: a repo-wide convention routes to the correct
  `@`-referenced sub-file rather than personal memory or the root file
  (case 6), and routing to `AGENTS.md` still works with auto-memory off
  (case 7). Negative assertions on cases 1 and 5 confirming no
  project-instructions block is proposed alongside the memory entry for a
  personal/external-gotcha lesson — added after benchmarking flagged the gap
  (see below).
- `evals/results/2026-07-10/`: benchmark comparing this rewrite against the
  pre-rewrite `SKILL.md` across all 7 cases (14 runs, graded and reviewable
  via `eval-review.html`). 100% pass rate on the rewrite vs. 82% on the
  pre-rewrite baseline — the gap is entirely cases 6/7, confirming the
  routing feature closes a real problem without regressing cases 1-5.

### Changed

- `description` and the README no longer state a hard dependency on
  auto-memory — the project-instructions route works with it off.
  `allowed-tools` is unchanged; it already covers reading and writing the
  target file.
- README clarifies `reflect` runs only in Claude Code, but what it lands in
  `CLAUDE.md`/`AGENTS.md` is read by any agent that opens the repo.

## [0.2.0] - 2026-07-10

### Added

- `allowed-tools` frontmatter (`Read, Grep, Glob, Edit, Write`) so runs no
  longer stall on permission prompts for the tools reflect always uses;
  deletions still prompt since `Bash` is intentionally excluded.
- `evals/evals.json` with five gradeable cases covering the core contract:
  saving a real detour, staying silent on a trivial session, editing instead
  of duplicating, dropping a contradicted memory, and always proposing before
  writing. Runnable via the `skill-creator` plugin.
- README "Reliability & evals" section documenting the eval workflow and the
  `allowed-tools` scoping rationale.
- CONTRIBUTING note: never run this skill forked (`context: fork`), and run
  evals before merging a behavior change.

## [0.1.0] - 2026-07-10

### Added

- Initial release of the `reflect` skill: reviews a Claude Code session for
  token-wasting detours, reusable workflows, resolved blockers, corrected
  assumptions, and user feedback, then proposes a curated set of auto-memory
  changes (add/edit/drop/fix) before writing anything.

[Unreleased]: https://github.com/LorcanChinnock/reflect/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/LorcanChinnock/reflect/compare/v0.3.0...v1.0.0
[0.3.0]: https://github.com/LorcanChinnock/reflect/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/LorcanChinnock/reflect/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/LorcanChinnock/reflect/releases/tag/v0.1.0
