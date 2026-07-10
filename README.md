# reflect

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

A [Claude Code](https://claude.com/claude-code) skill that curates what a
session learned at the end of it — routing each lesson to whichever home it
actually belongs in, and editing, merging, or deleting entries as readily as
adding, so each store gets sharper over time instead of just growing.

`reflect` is a Claude Code skill — only Claude Code loads a `SKILL.md` and
auto-memory is a Claude Code feature, so it runs there and nowhere else. The
project-instructions route is where its benefit reaches further: conventions
it lands in `CLAUDE.md` or `AGENTS.md` are read by any agent that opens the
repo afterward, even though only Claude Code runs `reflect` itself.

## Requirements

`reflect` curates entries written by Claude Code's **auto-memory** feature
when it's enabled. It doesn't require it, though: a team-durable lesson can
still be proposed as a `CLAUDE.md`/`AGENTS.md` edit with auto-memory off. If
neither applies to a given session, `reflect` says so and no-ops.

## Install

Project-scoped (this project only):

```bash
npx skills add LorcanChinnock/reflect
```

Global (available in every project):

```bash
npx skills add LorcanChinnock/reflect -g
```

## Usage

Trigger it at the end of a session, or any time you want to bank what was
learned:

```
/reflect
```

It also fires on phrases like "reflect on this session", "save what you
learned", or "update your memory".

## What it does

`reflect` scans the current session for token-wasting detours, reusable
workflows, resolved blockers, corrected assumptions, and user feedback on
working style. It filters hard — a candidate only survives if it's both
recurring and non-obvious — then routes each survivor to its home: personal
auto-memory (editing or deleting stale entries rather than piling on new
ones), or, for a durable convention the whole repo needs, a proposed edit to
the repo's project-instructions file. That routing is structure-aware: it
lands in the right `@`-referenced sub-file if `CLAUDE.md` splits that way,
the root `CLAUDE.md` otherwise, or `AGENTS.md` if that's what the repo has.
Either way, `reflect` proposes a concise change list before writing anything.

## Example

Given a session where an API's auth flow took several failed attempts to get
right, and separately a repo-wide test convention was discovered, `reflect`
proposes something like:

```
Proposed memory changes:
  NEW   acme-api-auth — API requires an X-Client-Id header on every request,
        not just login; 401s otherwise. Not documented anywhere but the
        support forum.
  EDIT  acme-api-quirks — fold in the new auth note above instead of a
        separate file; same topic.
  DROP  acme-api-rate-limits — superseded, the API removed rate limiting in
        their March changelog.

Proposed project-instructions changes (you land these via a normal PR):
  CLAUDE  docs/testing.md › "Running tests"
          Integration tests only run correctly via `pnpm -w test` from the
          repo root; running from a package subdirectory silently skips them.
          why team-durable: anyone working in this repo can hit the silent
          skip, not just this session.
```

Nothing is written until you approve the list. A `CLAUDE.md`/`AGENTS.md`
proposal is applied to your working tree at most — `reflect` never stages,
commits, pushes, or opens the PR; landing it is yours to do.

See [SKILL.md](./SKILL.md) for the full behavior spec.

## Reliability & evals

`reflect`'s core contract is pinned down as gradeable cases in
[`evals/evals.json`](./evals/evals.json): it saves a real detour as one lean
`NEW` entry, stays silent on a trivial session, `EDIT`s instead of duplicating
an already-covered topic, `DROP`s or fixes a contradicted memory instead of
leaving it stale, never writes before showing the change list, routes a
repo-wide convention to the correct `@`-referenced sub-file instead of the
root `CLAUDE.md` or a personal memory, and still routes correctly to
`AGENTS.md` when auto-memory is off.

Benchmark runs comparing versions live under
[`evals/results/`](./evals/results/), each with a `benchmark.md` summary and
an `eval-review.html` you can open directly to see per-case outputs.

Run the suite with the
[`skill-creator`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator)
plugin:

```
/plugin install skill-creator@claude-plugins-official
evaluate the reflect skill with skill-creator
```

Each case runs in an isolated subagent and is graded pass/fail with evidence.
Run the suite before merging any change to `SKILL.md`'s behavior, and use
skill-creator's version-comparison mode to confirm an edit is actually an
improvement rather than a regression in disguise.

`allowed-tools` in `SKILL.md` is scoped to `Read, Grep, Glob, Edit, Write` —
enough to read the memory index, write memory files, and edit a
`CLAUDE.md`/`AGENTS.md` in the working tree, all without a permission prompt
on every run. Deleting a memory file still requires `Bash(rm ...)`, which is
intentionally left off the allowlist, so a `DROP` always prompts you. Staging,
committing, or opening a PR for a project-instructions edit needs `Bash`/`gh`,
also off the allowlist by design — `reflect` can propose and write the edit,
but landing it is always a manual step for you.

`reflect` must run inline, never forked (`context: fork`) — it depends on
already having the session transcript and memory index in context, which a
forked subagent would not have.

## Contributing

Bug reports and small, focused proposals are welcome — see
[CONTRIBUTING.md](./CONTRIBUTING.md).

## License

[MIT](./LICENSE)

## Links

- [Claude Code Agent Skills docs](https://docs.claude.com/en/docs/claude-code/skills)
- [`npx skills` CLI](https://www.npmjs.com/package/skills)

Built by [Lorcan Chinnock](https://github.com/LorcanChinnock).
