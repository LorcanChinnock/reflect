# reflect

A [Claude Code](https://claude.com/claude-code) skill that curates your
auto-memory store at the end of a session — editing, merging, and deleting
entries as readily as adding, so the store gets sharper over time instead of
just growing.

## Install

```bash
npx skills add LorcanChinnock/reflect
```

Global install (available in every project):

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

See [SKILL.md](./SKILL.md) for the full behavior spec.

## License

MIT
