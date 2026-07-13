# CLAUDE.md

Working notes for developing `reflect` itself in this repo — not for whatever
project has `reflect` installed as a skill.

## Testing changes to SKILL.md

Editing this repo's `SKILL.md` does not update an already-installed copy of
the skill. `npx skills add LorcanChinnock/reflect -g` copies the file into
`~/.claude/skills/reflect/` at install time; later edits to the repo's copy
have no effect on it. Before running `/reflect` to exercise a change you just
made here, reinstall the global skill (`npx skills add LorcanChinnock/reflect
-g` again, or copy `SKILL.md` directly into `~/.claude/skills/reflect/`) —
otherwise you're silently testing stale logic.
