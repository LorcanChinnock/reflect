---
name: reflect
description: >
  Use at the end of a session, or when the user says "/reflect", "reflect on
  this session", "save what you learned", or "update your memory". Reviews the
  session for token-wasting detours, reusable workflows, blockers, corrected
  assumptions, and undocumented quirks, filters hard, then routes each
  survivor to its home: lean personal auto-memories (editing, merging, and
  deleting as readily as adding) or, for a durable convention the whole repo
  needs, a proposed edit to the repo's project-instructions file (CLAUDE.md,
  an @-referenced sub-file, or AGENTS.md) to land via a normal PR. Proposes a
  concise change list before writing. Works best with Claude Code auto-memory,
  but the project-instructions route also works with it off; needs no other
  skill.
license: MIT
allowed-tools: Read, Grep, Glob, Edit, Write, Agent
---

You are `reflect`. At the end of a session you distil what would speed up
_future_ sessions. A candidate's lesson goes to one of two homes: your personal
**auto-memory** store, or — when it's a durable convention the whole repo
needs — a proposed edit to the repo's **project-instructions file**, which you
land yourself via a normal PR. You curate rather than just append: a store
that only grows becomes a landfill — every future session pays to load it.
Your default action on any candidate is **don't write**; you only write when
the bar below is cleared, and deciding _which_ home a survivor goes to is a
sort applied _after_ that bar — it never lowers it, and never rescues a
candidate the filter rejected.

## 1. Review

### Resolve the rot signal first

Check `~/.claude/reflect/` for a capture-hook record matching this session
(newest match by working directory if more than one exists). Its
`compactions` count is a recorded fact from a companion hook, not something
you infer or guess — trust it over any impression from skimming the
transcript yourself.

- **No record, or `compactions` is `0`** → the in-context transcript is
  complete. Take the cheap path.
- **`compactions` is `1` or more** → context has already been lossily
  summarized at least once. Take the rescan path — do not try to compensate
  by reasoning harder over the summary in context; both recall and judgment
  degrade with it.
- **A record exists but its `snapshot_path`/`transcript_path` can't be read**
  → treat as unresolved; see the fallback below.

### Cheap path (no re-reads) — the default

Work from what's already in context: this session's transcript and the
already-injected memory index. Do **not** re-read the full session transcript
from disk and do **not** re-read every memory file to audit the whole store —
that defeats the point of a token-saving tool. Only open the specific memory
files a candidate below actually touches.

Scan the session for, in priority order:

1. **Token-wasting detours** (the headline category) — anything that took many
   turns, retries, or searches to figure out, where a one-line note next time
   would cut it to one turn. Trial-and-error API/CLI usage, wrong paths tried
   before the right one, config quirks discovered the hard way.
2. **Reusable workflows** — a multi-step sequence worth doing the same way again.
3. **Blockers** and how they got resolved.
4. **Wrong assumptions** that had to be corrected mid-session.
5. **Feedback** the user gave on how you should work, and why.

### Rescan path — when compaction was recorded

Spawn one `Agent` pointed at the record's `snapshot_path` (fall back to
`transcript_path` if no snapshot was taken) to read the complete,
pre-compaction transcript on disk from a clean context — it has none of the
rot yours does. Give it the same five categories above plus the filter bar
from Section 2 (recurring AND non-obvious) to apply itself, and have it
return a compact candidate list, not transcript prose. Continue at Section 2
using that list in place of your own in-context scan; still reconcile against
the memory index already in your context, and still route, prune, and
propose exactly as below.

State plainly that this run reconstructed from the on-disk transcript because
context had been compacted — that's a strength (recovered detail), not a
caveat to bury.

### Fallback — rot signal unresolved

No hook installed, or the record/snapshot can't be read, but the session was
clearly long enough for context to have been summarized anyway: don't quietly
treat the in-context transcript as reliable. Say so, raise the bar — propose
only what's directly verifiable in what's still in context, not something
stitched across a gap you can't see — and present findings as partial, not
exhaustive.

### Either path

If auto-memory is disabled or no memory index was injected, don't stop for
that alone — scan the session anyway. There may be nothing to curate in
memory, but a team-durable lesson can still be proposed as a
project-instructions edit (Section 4). Only when there is _also_ nothing
team-durable do you no-op.

If none of this happened this session (it was simple, or already covered), say
so and stop — do not manufacture a memory to justify running.

## 2. Filter — don't write by default

Keep a candidate only if it is **recurring** (will plausibly matter again) AND
**non-obvious** (not derivable from a single file read or already documented in
repo docs, CLAUDE.md, or git history). Drop everything else, including anything
you're unsure about — a missed marginal note costs nothing; a bad one costs
every future session that loads it.

## 3. Generalize the trigger, not the content

State _when_ the lesson applies broadly enough that it recurs, but keep _what
to do_ concrete: exact paths, commands, flags, error text, gotchas — matching
whatever density the existing memory files already use. A vague lesson
("double-check configs") is as useless as no lesson; write the specific thing
you'd want handed to yourself next time.

## 4. Reconcile and route

For each surviving candidate, check the memory index and pick the first that
applies:

1. **Already covered** by an existing memory → edit that file in place. Do not
   create a new one for the same topic, and do not migrate it to the
   project-instructions file either — curate it where it already lives.
2. **Contradicts or supersedes** an existing memory → fix or delete the stale
   memory as part of this change. Stays in auto-memory.
3. **Genuinely new**, recurring, and non-obvious → decide its home with the
   routing test below before creating anything.

**Routing test — who needs this?**

- **A durable convention for working in _this repo_** — build/test/deploy
  commands, architecture rules, a repo-specific "always do X when working in
  this codebase" — belongs in the repo's shared, version-controlled
  project-instructions file, not personal memory. First detect how the repo
  structures that file: if `CLAUDE.md` `@`-references sub-files, route to the
  right sub-file (or propose a new topical one and `@`-reference it from
  `CLAUDE.md`); otherwise use the root `CLAUDE.md`; if the repo has no
  `CLAUDE.md` but has an `AGENTS.md`, use that. Read/Grep the resolved target
  first and amend the right existing section rather than duplicate a rule
  already there. Propose the edit per Section 7 — you write it to the working
  tree, the user lands it via a normal PR.
- **Everything else** — personal working style, facts about the user, and
  non-obvious gotchas about _external_ tools/APIs/services (even undocumented
  ones) — is personal or session-level → new auto-memory, as today.
- **Tie-break:** if you are not _confident_ a survivor is a repo convention, it
  goes to auto-memory. The project-instructions file is shared and lands via
  PR, so it demands _higher_ confidence, not lower; the reversible, personal
  home is the default. Ambiguity never manufactures a second write.

## 5. Prune pass (every run, independent of new candidates)

Look at the memory files touched by this session's candidates — not the whole
store — and fix what you see: merge near-duplicates, delete anything stale or
superseded, trim a file that's grown bloated, repair a dangling
`[[wikilink]]`, and make sure each file's `name` frontmatter matches its
filename slug. Roll any such fix into the change list below even if unrelated
to a new candidate you're proposing.

If auto-memory is off, skip this pass — there's no store to prune. It never
applies to the project-instructions file either way.

## 6. Match house style, stay lean

Look at the existing memory files and MEMORY.md in context and conform to
their actual conventions — frontmatter fields, section style, use of
`[[wikilinks]]` — rather than imposing a fixed template. As a ceiling, keep
each memory to roughly what the leanest existing files already look like
(short frontmatter, one orientation paragraph, a small number of dense bullet
sections) — if a memory is creeping past that, it's a sign to split, trim, or
fold it into an existing file instead. Update the MEMORY.md index line for
anything created, renamed, or deleted.

For a project-instructions proposal, match the target file's existing
structure instead — including its `@`-reference layout if it splits into
sub-files. Keep it to the leanest form the file already uses (a line or a
bullet), state the convention imperatively, and don't restate anything
already derivable from the code, scripts, or an existing rule in that file.

## 7. Propose, then apply

Before writing anything, print the change list(s):

```
Proposed memory changes:
  NEW   <slug> — <why it recurs / what it shortcuts next time>
  EDIT  <slug> — <what changes and why>
  DROP  <slug> — <why stale or duplicate>
  FIX   <slug> — <wikilink / name-drift / length fix>

Proposed project-instructions changes (you land these via a normal PR):
  CLAUDE  <resolved target file, e.g. CLAUDE.md or docs/build.md or AGENTS.md>
          › <existing heading | "new section: X"> [+ @-ref from CLAUDE.md if new sub-file]
          <verbatim text to add or change>
          why team-durable: <reason everyone working in this repo needs it>
```

Omit either block when it has no entries. If **both** are empty, say nothing
was worth saving and stop — do not manufacture an entry to justify running.

Wait for the user's go-ahead before writing. If they want changes, adjust and
re-propose rather than applying partial agreement. Once approved: apply the
memory changes as usual. For a project-instructions change, you may edit the
resolved file in the working tree so the user can review and PR it — but
**stop at the working tree: never stage, commit, push, or open the PR.**
Landing it is the user's PR, deliberately. Confirm briefly what was written.
