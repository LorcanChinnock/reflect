![reflect](./assets/reflecthero.png)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

Every memory tool has the same failure mode: it only grows. You turn it on,
it's great for a couple of weeks, and then every session starts by loading a
memory file that's mostly noise — a note about a bug you fixed three weeks
ago, a style preference that got properly documented in `CLAUDE.md` and is
now just sitting there twice, a paragraph explaining something the codebase
already makes obvious. Nobody prunes it, because pruning isn't the fun part
of building an agent. So it just gets heavier, and every future session pays
the toll of loading it.

`reflect` is the pruning. Run it at the end of a session and it looks back
over what actually happened — the detours, the dead ends, the corrections —
and asks, honestly, whether any of it is worth keeping. Most of the time the
answer is no, and it says so and stops. When something does survive, `reflect`
doesn't just tack it on the end: it edits the entry that's already there,
merges near-duplicates, deletes what's no longer true, and writes new notes
lean enough to be worth the tokens they'll cost every session that loads them.

It also knows that not every lesson is *yours*. Some belong to whoever else
touches this repo. "Tests silently no-op if you don't run them from the
workspace root" isn't a fact about you — it's a fact about the codebase, and
it should live in `CLAUDE.md` where any agent that opens the repo will see
it, not buried in your personal memory where only you benefit. `reflect`
tells the two kinds of lesson apart and sends each one home.

## Requirements

`reflect` only really makes sense inside Claude Code — auto-memory is a
Claude Code feature, and `SKILL.md` only gets loaded there. You don't
strictly need auto-memory switched on, though: a team-durable lesson can
still be proposed as a `CLAUDE.md`/`AGENTS.md` edit with it off. If neither
applies to a given session — nothing personal worth remembering, nothing
team-worthy either — `reflect` just says so and does nothing. Saying nothing
is a valid, common outcome, not a failure.

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

Run it at the end of a session, or any time you want to bank what got
learned:

```
/reflect
```

It also fires on phrases like "reflect on this session", "save what you
learned", or "update your memory" — you don't have to remember the slash
command.

## What it does

`reflect` scans the session for the stuff that's actually worth carrying
forward: token-wasting detours, reusable workflows, blockers and how they got
unstuck, wrong assumptions that had to be corrected, and feedback you gave on
how it should work. Then it filters hard — a candidate only survives if it's
both *recurring* (it'll plausibly come up again) and *non-obvious* (you
couldn't just re-derive it from reading a file). Everything else gets
dropped, on purpose, including anything borderline.

What survives gets routed to its actual home. Personal stuff — your working
style, quirks of an external API, gotchas that are about you or your tools —
goes to auto-memory, where `reflect` will happily edit or delete an existing
entry instead of piling a new one on top. A durable convention the whole repo
needs goes to the repo's project-instructions file instead, and that routing
is structure-aware: it'll land in the right `@`-referenced sub-file if
`CLAUDE.md` splits that way, the root `CLAUDE.md` otherwise, or `AGENTS.md`
if that's what the repo uses. Either way, `reflect` shows you the full change
list first and waits. It never writes on spec.

## Example

Say a session spent several failed attempts getting an API's auth flow right,
and separately turned up a repo-wide testing convention nobody had written
down. `reflect` would propose something like this:

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

Nothing gets written until you say go. And a `CLAUDE.md`/`AGENTS.md`
proposal only ever touches your working tree — `reflect` will never stage,
commit, push, or open a PR on its own. Landing it is yours to do.

See [SKILL.md](./SKILL.md) for the full behavior spec — that's the actual
instruction set Claude reads and runs, so it's worth a read if you want the
precise rules rather than the summary above.

## Reliability & evals

Restraint is easy to claim and hard to verify, so `reflect`'s core contract
is pinned down as gradeable cases in
[`evals/evals.json`](./evals/evals.json): it saves a real detour as one lean
`NEW` entry, stays quiet on a trivial session instead of manufacturing
something to write, `EDIT`s an already-covered topic instead of duplicating
it, `DROP`s or fixes a memory that's been contradicted instead of leaving it
stale, never writes before showing the change list, routes a repo-wide
convention to the correct `@`-referenced sub-file instead of dumping it in
root `CLAUDE.md` or personal memory, and still finds `AGENTS.md` correctly
when auto-memory is off.

The most recent benchmark, in
[`evals/results/2026-07-10/`](./evals/results/2026-07-10/), runs this
version of `SKILL.md` against the pre-rewrite one, same 7 fixtures, same
model (`claude-opus-4-8`), 14 runs total:

| Eval | Checks that... | Current | Pre-rewrite |
|---|---|---|---|
| 1. acme-api-auth-detour | a real detour gets saved as one lean entry | 4/4 | 4/4 |
| 2. trivial-readme-typo | a boring session gets no memory at all | 3/3 | 3/3 |
| 3. already-covered-npm-test | an existing topic gets `EDIT`ed, not duplicated | 3/3 | 3/3 |
| 4. stale-deploy-pipeline | a contradicted memory gets fixed or dropped | 3/3 | 3/3 |
| 5. ask-dont-guess-feedback | personal feedback stays in memory, doesn't over-route | 3/3 | 3/3 |
| 6. team-convention-atref-subfile | a repo convention lands in the right `@`-ref sub-file | 4/4 | 1/4 |
| 7. memory-off-agents-md | still finds `AGENTS.md` with auto-memory off | 4/4 | 2/4 |
| **Total** | | **100%** | **82%** |

Cases 1–5 pass either way — the rewrite didn't disturb anything that already
worked, it just costs a little more to run it (168.9s / 38.1k tokens on
average, versus 142.6s / 36.4k before — call it +1.7k tokens for the extra
routing check). All the daylight is in 6 and 7, and it's worth seeing what
that actually looked like rather than just the score:

- **Case 6** drops `reflect` into a pnpm monorepo where integration tests
  silently no-op unless you run them as `pnpm -w test` from the repo root —
  exactly the kind of thing that should live in `docs/testing.md`, which
  this repo's `CLAUDE.md` already `@`-references. The pre-rewrite skill had
  no concept of that home. It filed the convention as a personal memory
  instead — `NEW pnpm-workspace-integration-tests` — so the lesson would
  have sat in one person's memory file, invisible to the next teammate who
  hit the exact same silent skip.
- **Case 7** turns auto-memory off entirely and drops in a deploy script that
  silently ships to production if `DEPLOY_ENV` isn't set — again, a
  whole-team gotcha, and this repo uses `AGENTS.md`. With no routing concept
  and no memory store to write to, the pre-rewrite skill proposed a `NEW`
  memory entry anyway, into a store the fixture had explicitly switched off.

Neither is a made-up edge case — they're the two failure modes you'd
actually expect from a skill that only knows about one home: it either
misfiles a team lesson somewhere only you can see it, or it tries to write
somewhere that isn't there. Open `eval-review.html` in that results folder
if you want the full transcripts rather than the summary above.

Run the suite yourself with the
[`skill-creator`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator)
plugin:

```
/plugin install skill-creator@claude-plugins-official
evaluate the reflect skill with skill-creator
```

Each case runs in its own isolated subagent and gets graded pass/fail with
evidence attached, so a green run actually means something. Run it before
merging any change to `SKILL.md`'s behavior, and use skill-creator's
version-comparison mode to make sure an edit is a real improvement and not a
regression wearing a nicer diff.

`allowed-tools` in `SKILL.md` is scoped tight — `Read, Grep, Glob, Edit,
Write` — on purpose. That's enough to read the memory index, write memory
files, and edit a `CLAUDE.md`/`AGENTS.md` in the working tree without a
permission prompt interrupting every run. Deleting a memory file still needs
`Bash(rm ...)`, which is deliberately left off the list, so a `DROP` always
stops and asks. Staging, committing, or opening a PR needs `Bash`/`gh`, also
off by design — `reflect` can propose and write the edit, but landing it is
always a manual step for you.

And `reflect` must run inline, never forked (`context: fork`). It works
entirely off the session transcript and memory index that are already
sitting in context by the time it runs — a forked subagent starts with
neither, so it'd have nothing real to reflect on and would either come back
empty or make something up.

## Contributing

Bug reports and small, focused proposals are welcome — see
[CONTRIBUTING.md](./CONTRIBUTING.md).

## License

[MIT](./LICENSE)

## Links

- [Claude Code Agent Skills docs](https://docs.claude.com/en/docs/claude-code/skills)
- [`npx skills` CLI](https://www.npmjs.com/package/skills)

Built by [Lorcan Chinnock](https://github.com/LorcanChinnock).
