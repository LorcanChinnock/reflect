# reflect

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

A Claude Code skill that decides, at the end of a session, whether anything is
worth remembering — and if so, writes it down properly instead of just
appending to a pile.

## The problem

Auto-memory tools have one failure mode in common: they only grow. Turn one
on and the first couple of weeks are great. Then sessions start opening with
a memory file full of things that stopped mattering — a bug fixed a month
ago, a preference that's now also written in `CLAUDE.md`, a paragraph
re-explaining something the code already says plainly. Nobody goes back and
prunes it, because pruning was never the interesting part of building the
thing. So it keeps growing, and every session after that pays to load it.

`reflect` is the part that was missing. At the end of a session it looks back
at what actually happened, asks whether any of it clears a fairly high bar,
and in most cases decides the answer is no and says so. When something does
survive, it doesn't just tack a new file onto the end — it edits the entry
that's already there, folds in near-duplicates, deletes what's gone stale,
and keeps the result lean enough to justify the tokens every future session
will spend loading it.

It also separates two kinds of lesson that most memory tools conflate. "The
integration tests silently no-op unless you run them from the workspace
root" isn't a fact about you, it's a fact about the repo, and it belongs in
`CLAUDE.md` where the next person who opens the project sees it — not
locked away in your personal memory where only you ever benefit from it.
`reflect` tells these apart and routes each one to where it actually helps.

## Install

Project-scoped:

```bash
npx skills add LorcanChinnock/reflect
```

Global, so it's available in every project:

```bash
npx skills add LorcanChinnock/reflect -g
```

## Usage

```
/reflect
```

Or just say something like "reflect on this session" or "save what you
learned" — it's wired to fire on those too, so you don't have to remember
the slash command.

## What it actually does

It scans the session transcript for five things: detours that burned several
turns before landing on the right answer, multi-step workflows worth
repeating verbatim, blockers and how they got resolved, assumptions that
turned out wrong and had to be corrected, and direct feedback you gave about
how it should work. Then it filters hard. A candidate only survives if it's
both *recurring* — it'll plausibly come up again — and *non-obvious* — you
couldn't just re-derive it by reading a file. Everything else is dropped on
purpose, including anything borderline. A missed marginal note costs
nothing; a bad one costs every session that has to load it afterward.

Whatever survives gets sorted into one of two homes. Personal stuff — your
own working habits, quirks of an external API, gotchas that are about you or
your tools rather than the repo — goes to auto-memory, where `reflect` will
edit or delete an existing entry rather than pile a new one on top of it. A
convention the whole team needs goes to the repo's project-instructions file
instead, and the routing is structure-aware: it finds the right
`@`-referenced sub-file if `CLAUDE.md` splits that way, falls back to the
root `CLAUDE.md`, or targets `AGENTS.md` if that's what the repo actually
uses.

Either way, it shows you the full change list before writing anything, and
waits.

## Example

Say a session burned several attempts getting an internal API's auth working,
and separately turned up a repo-wide testing convention nobody had bothered
to write down. `reflect` would propose something like this:

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

Nothing gets written until you say go. And the project-instructions block
only ever touches your working tree — `reflect` will not stage, commit,
push, or open a PR for you. Landing it is yours to do.

Full behavior spec, if you want the precise rules instead of the summary
above: [SKILL.md](./SKILL.md).

## Requirements

`reflect` only makes sense inside Claude Code, since auto-memory is a Claude
Code feature and `SKILL.md` is only loaded there. Auto-memory itself doesn't
have to be switched on — a team-durable lesson can still land as a
`CLAUDE.md`/`AGENTS.md` proposal without it. If neither applies to a given
session, `reflect` says so and does nothing. That's a normal outcome, not a
failure of the skill.

## Reliability & evals

Restraint is easy to claim and hard to verify, so the actual contract is
pinned down as gradeable cases in
[`evals/evals.json`](./evals/evals.json): a real detour becomes one lean
`NEW` entry, a trivial session gets nothing manufactured for it, an
already-covered topic gets `EDIT`ed instead of duplicated, a contradicted
memory gets `DROP`ped or fixed rather than left stale, nothing is ever
written before the change list is shown, a repo-wide convention lands in the
right `@`-referenced sub-file, and `AGENTS.md` still gets found correctly
when auto-memory is off.

The most recent benchmark, in
[`evals/results/2026-07-10/`](./evals/results/2026-07-10/), runs the current
`SKILL.md` against the version that predates the project-instructions
routing feature — same 7 fixtures, same model (`claude-opus-4-8`), 14 runs
total:

| Eval                              | Checks that...                                         | Current  | Pre-rewrite |
| ---------------------------------- | ------------------------------------------------------- | -------- | ----------- |
| 1. acme-api-auth-detour            | a real detour gets saved as one lean entry               | 4/4      | 4/4         |
| 2. trivial-readme-typo             | a boring session gets no memory at all                   | 3/3      | 3/3         |
| 3. already-covered-npm-test        | an existing topic gets `EDIT`ed, not duplicated          | 3/3      | 3/3         |
| 4. stale-deploy-pipeline           | a contradicted memory gets fixed or dropped               | 3/3      | 3/3         |
| 5. ask-dont-guess-feedback         | personal feedback stays in memory, doesn't over-route     | 3/3      | 3/3         |
| 6. team-convention-atref-subfile   | a repo convention lands in the right `@`-ref sub-file      | 4/4      | 1/4         |
| 7. memory-off-agents-md            | still finds `AGENTS.md` with auto-memory off               | 4/4      | 2/4         |
| **Total**                          |                                                           | **100%** | **82%**     |

Cases 1 through 5 pass on both versions — the routing rewrite didn't disturb
anything that already worked, it just costs a bit more to run (168.9s /
38.1k tokens on average, versus 142.6s / 36.4k before — call it +1.7k tokens
for the extra check). All the daylight is in cases 6 and 7:

- **Case 6** drops `reflect` into a pnpm monorepo where integration tests
  silently no-op unless run as `pnpm -w test` from the repo root — exactly
  the kind of thing that belongs in `docs/testing.md`, which this fixture's
  `CLAUDE.md` already `@`-references. The pre-rewrite skill had no concept
  of that home and filed it as a personal memory instead, so the lesson
  would have sat in one person's memory file, invisible to the next teammate
  who hit the same silent skip.
- **Case 7** turns auto-memory off and drops in a deploy script that ships
  to production silently if `DEPLOY_ENV` isn't set — again a whole-team
  gotcha, in a repo that uses `AGENTS.md`. With no routing concept and no
  memory store to write to, the pre-rewrite skill proposed a memory entry
  anyway, into a store the fixture had explicitly switched off.

Open `eval-review.html` in that results folder for the full transcripts
rather than the summary above.

Run the suite yourself with the
[`skill-creator`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator)
plugin:

```
/plugin install skill-creator@claude-plugins-official
evaluate the reflect skill with skill-creator
```

Each case runs in an isolated subagent and gets graded pass/fail with
evidence attached, so a green run means something. Run it before merging any
change to `SKILL.md`'s behavior, and use skill-creator's version-comparison
mode to confirm an edit is a real improvement and not a regression with a
tidier diff.

`allowed-tools` in `SKILL.md` is deliberately narrow — `Read, Grep, Glob,
Edit, Write` — enough to read the memory index, write memory files, and edit
a `CLAUDE.md`/`AGENTS.md` in the working tree without a permission prompt on
every run. Deleting a memory file still needs `Bash(rm ...)`, which is
intentionally left off, so a `DROP` always stops and asks. Staging,
committing, or opening a PR needs `Bash`/`gh`, also excluded by design —
`reflect` can propose and write the edit, but landing it stays a manual step.

`reflect` also has to run inline, never forked (no `context: fork`). It
works entirely off the session transcript and memory index already sitting
in context when it runs; a forked subagent starts with neither, so it would
have nothing real to reflect on and would either come back empty or invent
something.

## Contributing

Bug reports and small, focused proposals are welcome — see
[CONTRIBUTING.md](./CONTRIBUTING.md).

## License

[MIT](./LICENSE)

## Links

- [Claude Code Agent Skills docs](https://docs.claude.com/en/docs/claude-code/skills)
- [`npx skills` CLI](https://www.npmjs.com/package/skills)

Built by [Lorcan Chinnock](https://github.com/LorcanChinnock).
