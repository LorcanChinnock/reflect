# reflect

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

A [Claude Code](https://claude.com/claude-code) skill that curates your
auto-memory store at the end of a session — editing, merging, and deleting
entries as readily as adding, so the store gets sharper over time instead of
just growing.

## Requirements

`reflect` curates entries written by Claude Code's **auto-memory** feature. If
auto-memory isn't enabled, there's nothing for this skill to curate and it
will no-op. Enable it first, then install this skill on top.

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
recurring and non-obvious — then reconciles against the existing memory store
(editing or deleting stale entries rather than piling on new ones) and
proposes a concise change list before writing anything.

## Example

Given a session where an API's auth flow took several failed attempts to get
right, `reflect` proposes something like:

```
Proposed memory changes:
  NEW   acme-api-auth — API requires an X-Client-Id header on every request,
        not just login; 401s otherwise. Not documented anywhere but the
        support forum.
  EDIT  acme-api-quirks — fold in the new auth note above instead of a
        separate file; same topic.
  DROP  acme-api-rate-limits — superseded, the API removed rate limiting in
        their March changelog.
```

Nothing is written until you approve the list.

See [SKILL.md](./SKILL.md) for the full behavior spec.

## Reliability & evals

`reflect`'s core contract is pinned down as gradeable cases in
[`evals/evals.json`](./evals/evals.json): it saves a real detour as one lean
`NEW` entry, stays silent on a trivial session, `EDIT`s instead of duplicating
an already-covered topic, `DROP`s or fixes a contradicted memory instead of
leaving it stale, and never writes before showing the change list.

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
enough to read the memory index and write memory files without a permission
prompt on every run. Deleting a memory file still requires `Bash(rm ...)`,
which is intentionally left off the allowlist, so a `DROP` always prompts you.

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
