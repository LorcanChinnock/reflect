# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/LorcanChinnock/reflect/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/LorcanChinnock/reflect/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/LorcanChinnock/reflect/releases/tag/v0.1.0
