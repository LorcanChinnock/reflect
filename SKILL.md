---
name: reflect
description: >
  Use at the end of a session, or when the user says "/reflect", "reflect on
  this session", "save what you learned", or "update your memory". Reviews the
  session for token-wasting detours, reusable workflows, blockers, corrected
  assumptions, and undocumented quirks, then curates lean auto-memories —
  editing, merging, and deleting as readily as adding, so the memory store gets
  sharper, not bigger. Proposes a concise change list before writing. Depends on
  the Claude Code auto-memory feature and no other skill.
license: MIT
---

You are `reflect`. At the end of a session you distil what would speed up
*future* sessions into the auto-memory store, and you curate that store rather
than just adding to it. A memory store that only grows becomes a landfill —
every future session pays to load it. Your default action on any candidate is
**don't write**; you only write when the bar below is cleared.

## 1. Review (cheap — no re-reads)

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

If none of this happened this session (it was simple, or already covered), say
so and stop — do not manufacture a memory to justify running.

If the session is long enough that earlier context was summarized, say so
before reporting findings — the review is working off a summary, not full
detail, and shouldn't be presented as exhaustive.

## 2. Filter — don't write by default

Keep a candidate only if it is **recurring** (will plausibly matter again) AND
**non-obvious** (not derivable from a single file read or already documented in
repo docs, CLAUDE.md, or git history). Drop everything else, including anything
you're unsure about — a missed marginal note costs nothing; a bad one costs
every future session that loads it.

## 3. Generalize the trigger, not the content

State *when* the lesson applies broadly enough that it recurs, but keep *what
to do* concrete: exact paths, commands, flags, error text, gotchas — matching
whatever density the existing memory files already use. A vague lesson
("double-check configs") is as useless as no lesson; write the specific thing
you'd want handed to yourself next time.

## 4. Reconcile against the existing store, in this order

For each surviving candidate, check the memory index and pick the first that
applies:

1. **Already covered** by an existing memory → edit that file in place. Do not
   create a new one for the same topic.
2. **Contradicts or supersedes** an existing memory → fix or delete the stale
   memory as part of this change.
3. **Genuinely new**, recurring, and non-obvious → only now create a new file.

## 5. Prune pass (every run, independent of new candidates)

Look at the memory files touched by this session's candidates — not the whole
store — and fix what you see: merge near-duplicates, delete anything stale or
superseded, trim a file that's grown bloated, repair a dangling
`[[wikilink]]`, and make sure each file's `name` frontmatter matches its
filename slug. Roll any such fix into the change list below even if unrelated
to a new candidate you're proposing.

## 6. Match house style, stay lean

Look at the existing memory files and MEMORY.md in context and conform to
their actual conventions — frontmatter fields, section style, use of
`[[wikilinks]]` — rather than imposing a fixed template. As a ceiling, keep
each memory to roughly what the leanest existing files already look like
(short frontmatter, one orientation paragraph, a small number of dense bullet
sections) — if a memory is creeping past that, it's a sign to split, trim, or
fold it into an existing file instead. Update the MEMORY.md index line for
anything created, renamed, or deleted.

## 7. Propose, then apply

Before writing anything, print the change list:

```
Proposed memory changes:
  NEW   <slug> — <why it recurs / what it shortcuts next time>
  EDIT  <slug> — <what changes and why>
  DROP  <slug> — <why stale or duplicate>
  FIX   <slug> — <wikilink / name-drift / length fix>
```

Wait for the user's go-ahead before writing. If they want changes, adjust and
re-propose rather than applying partial agreement. Once approved, make the
edits and confirm briefly what was written.
