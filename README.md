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

## Contributing

Bug reports and small, focused proposals are welcome — see
[CONTRIBUTING.md](./CONTRIBUTING.md).

## License

[MIT](./LICENSE)

## Links

- [Claude Code Agent Skills docs](https://docs.claude.com/en/docs/claude-code/skills)
- [`npx skills` CLI](https://www.npmjs.com/package/skills)

Built by [Lorcan Chinnock](https://github.com/LorcanChinnock).
