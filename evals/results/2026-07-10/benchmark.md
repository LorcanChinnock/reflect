# Skill Benchmark: reflect

**Model**: claude-opus-4-8
**Date**: 2026-07-10T00:00:00Z
**Evals**: 1, 2, 3, 4, 5, 6, 7 (1 run each per configuration)

## Summary

| Metric | With Skill (rewrite) | Without Skill (pre-rewrite) | Delta |
|--------|------------------------|-------------------------------|-------|
| Pass Rate | 100% ± 0% | 82% ± 31% | +0.18 |
| Time | 168.9s ± 66.1s | 142.6s ± 81.1s | +26.3s |
| Tokens | 38081 ± 2764 | 36375 ± 2659 | +1707 |

## Per-eval pass rate

| Eval | With Skill | Without Skill |
|------|-----------|----------------|
| 1. acme-api-auth-detour | 4/4 | 4/4 |
| 2. trivial-readme-typo | 3/3 | 3/3 |
| 3. already-covered-npm-test | 3/3 | 3/3 |
| 4. stale-deploy-pipeline | 3/3 | 3/3 |
| 5. ask-dont-guess-feedback | 3/3 | 3/3 |
| 6. team-convention-atref-subfile | 4/4 | 1/4 |
| 7. memory-off-agents-md | 4/4 | 2/4 |

## Notes

- with_skill = current rewritten SKILL.md (structure-aware routing to auto-memory or repo CLAUDE.md/AGENTS.md/@-referenced sub-file). without_skill = pre-rewrite SKILL.md snapshot from git HEAD (auto-memory only, no routing concept) -- an 'old version' baseline, not a no-skill baseline.
- Cases 1-5 (pre-existing behavior) pass 100% on BOTH configurations -- the rewrite preserved all prior behavior with no regression.
- Cases 6-7 (new project-instructions routing feature) pass 4/4 on with_skill but only 1/4 and 2/4 on without_skill -- confirms the rewrite closes a real gap (old skill misfiled a repo convention into personal memory in case 6, and proposed writing into a non-existent memory store in case 7) rather than a hypothetical one.
- Cases 1 and 5 are the discriminator pair for over-routing risk (external API gotcha, and generic working-style feedback) -- both correctly stayed in auto-memory on with_skill, including case 1 where the fixture's own CLAUDE.md deliberately mentions the API name as a routing trap.
- Recurring eval-harness observation: several executor runs used Bash (find/ls) instead of Glob for fixture discovery, a self-disclosed deviation from the skill's Read/Grep/Glob/Edit/Write allowed-tools scope. Not a correctness failure in any case, but worth tightening in a future eval-harness revision so it doesn't mask a real allowed-tools violation.
- Grader-flagged eval-design gap: case 1's assertions don't explicitly check that no project-instructions/CLAUDE.md block is also proposed alongside the memory entry, even though the fixture is a deliberate routing trap for that. Same gap noted for case 5. Recommend adding an explicit negative assertion to both before the next iteration.
