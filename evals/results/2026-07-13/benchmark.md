# Skill Benchmark: reflect

**Model**: claude-opus-4-8
**Date**: 2026-07-13T00:00:00Z
**Evals**: 1, 2, 3, 4, 5, 6, 7, 10 (3-4 runs each per configuration, matching the 2026-07-10 benchmark's per-case run counts; case 10 is new this round)

## Summary

| Metric | Current (`.claude/memories/` routing) | Pre-rewrite (routes into `CLAUDE.md` body) | Delta |
|--------|------------------------|-------------------------------|-------|
| Pass Rate (literal self-grading) | 93% (26/28) | 75% (21/28) | +18pp |
| Pass Rate (intent-based, see Notes) | 100% (28/28) | 86% (24/28) | +14pp |

Per-run timing/token stats aren't included here — this benchmark used a lighter methodology than 2026-07-10's (see Notes) and didn't capture consistent per-run token counts.

## Per-eval pass rate

| Eval | Current | Pre-rewrite |
|------|-----------|----------------|
| 1. acme-api-auth-detour | 2/4¹ | 4/4¹ |
| 2. trivial-readme-typo | 3/3 | 3/3 |
| 3. already-covered-npm-test | 3/3 | 3/3 |
| 4. stale-deploy-pipeline | 3/3² | 0/3² |
| 5. ask-dont-guess-feedback | 3/3 | 3/3 |
| 6. team-convention-atref-subfile | 4/4 | 4/4 |
| 7. memory-off-agents-md | 4/4 | 4/4 |
| 10. no-home-convention-memories-folder (new) | 4/4 | 0/4 |

¹ Grading-strictness split, not a behavior difference: both versions consistently produced a correct `NEW` auto-memory entry with no project-instructions block in every run. The literal gap comes from two different self-grading passes disagreeing on whether printing an empty `Proposed project-instructions changes: (none — ...)` header counts as "omitting the block" (`SKILL.md` §7 says to omit it outright). Reading the raw run transcripts, the actual routing decision was identical and correct in all 8 runs across both versions.

² Grading-strictness split, not a behavior difference: both versions consistently corrected the stale CircleCI memory in place via an `EDIT`. The literal gap comes from one grading pass expecting the assertion's literal wording ("DROP or FIX") rather than `SKILL.md` §4's actual documented case-2 verb (`EDIT`, "fix ... in place. Stays in auto-memory"). Reading the raw run transcripts, both versions made the identical correct edit in all 7 runs.

## Notes

- **Methodology, and how it differs from 2026-07-10's**: this run did not use skill-creator's full pipeline (separate executor/grader subagents, `aggregate_benchmark.py`, `generate_review.py` viewer). Instead, one agent per (fixture, version) pair read the relevant `SKILL.md` (current, or a `git show HEAD:SKILL.md` pre-rewrite snapshot) directly, executed all of that fixture's runs itself, self-graded each run against the fixture's assertions, and returned an aggregate. This was a deliberate scope trade-off given the size of the sweep (8 fixtures × 2 versions), not an oversight — but it means grading strictness could vary between agents on ambiguous wording, which is exactly what happened on cases 1 and 4 (see footnotes above). A stricter re-run with a single dedicated grader agent per assertion would remove that noise; the underlying behavior is already confirmed identical by direct transcript inspection.
- **Cases 1, 2, 3, 5, 6, 7 are unaffected by this change** (this diff only touches §4 routing, §5 prune scope, §6 house style, and §7's template — none of which alter these fixtures' expected behavior), and every one came back behaviorally identical between versions, confirming no regression.
- **Case 10 is the actual point of this change**: pre-rewrite fails all 4 runs by construction — with no fitting `@`-referenced sub-file, the old routing test's only fallback was the root `CLAUDE.md` body, so every run proposed a new section inlined directly into it. The current version instead proposes a new `.claude/memories/<slug>.md` file with the `index.md` + `CLAUDE.md` `@`-import wiring, in all 4 runs, never touching `CLAUDE.md`'s body. This is the landfill-avoidance behavior the change exists to add.
- One benchmark agent (case 1, current version) initially misread its instructions as a request to spawn nested sub-agents, which aren't supported from that context; it was resumed with a corrected instruction and completed directly. Flagging for transparency, not because it affected the result.
