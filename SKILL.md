---
name: reflect
description: >
  Use at the end of a session, or when the user says "/reflect", "reflect on
  this session", "save what you learned", or "update your memory". Reviews the
  session for token-wasting detours, reusable workflows, blockers, corrected
  assumptions, and undocumented quirks, filters hard, then routes each
  survivor to its home: lean personal auto-memories (editing, merging, and
  deleting as readily as adding) or, for a durable convention the whole repo
  needs, a proposed edit that lands via a normal PR — amending a fitting
  existing doc (an @-referenced sub-file, or an AGENTS.md section) when one
  exists, otherwise a lean .claude/memories/ note @-imported from CLAUDE.md,
  never inlined into CLAUDE.md's own body. Proposes a concise change list
  before writing. Works best with Claude Code auto-memory, but the
  project-instructions route also works with it off; needs no other skill.
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

Claude Code's on-disk session transcript is append-only and keeps the
complete history through any number of compactions — it's the ground truth,
and locating it costs nothing but a Glob and a count, not a re-read of its
content.

- Derive this session's project directory: take the current working
  directory and replace every `/` with `-` (e.g. `/Users/you/dev/repo` →
  `-Users-you-dev-repo`), under `~/.claude/projects/`. If that exact
  directory doesn't exist, `Glob` `~/.claude/projects/*/` and use the one
  containing the most recently modified `*.jsonl`.
- `Glob` `*.jsonl` in that directory; the newest by modification time is this
  session's transcript (it's the one being actively written).
- `Grep` that file for `"subtype":"compact_boundary"` and count the matches —
  that count is a recorded fact, not something you infer from skimming the
  transcript yourself. This only counts lines; it doesn't pull transcript
  content into your context.
- **Count is `0`** → the in-context transcript is complete. Take the cheap
  path.
- **Count is `1` or more** → context has already been lossily summarized at
  least once. Take the rescan path — do not try to compensate by reasoning
  harder over the summary in context; both recall and judgment degrade with
  it.
- **The transcript can't be located, or the project directory is ambiguous
  (e.g. more than one plausibly-current session)** → treat as unresolved; see
  the fallback below. Guessing wrong here is worse than admitting you don't
  know, so an ambiguous match degrades to the fallback rather than picking
  one.

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

Spawn one `Agent` pointed at the located on-disk transcript to read the
complete, pre-compaction history from a clean context — it has none of the
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

The transcript couldn't be located or read, but the session was clearly long
enough for context to have been summarized anyway: don't quietly treat the
in-context transcript as reliable. Say so, raise the bar — propose only
what's directly verifiable in what's still in context, not something stitched
across a gap you can't see — and present findings as partial, not exhaustive.

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
  this codebase" — belongs in the repo's shared, version-controlled project
  instructions, not personal memory. Route it in this order:
  1. **Fitting existing section** — an `@`-referenced sub-file `CLAUDE.md`
     already points at, or (in an `AGENTS.md`-only repo) a section of
     `AGENTS.md`, that already covers this topic → Read/Grep it first, then
     amend that section in place rather than duplicate a rule already there.
  2. **No fitting section, `CLAUDE.md`-based repo** (has one, or has neither
     file) → a **project memory**, not the `CLAUDE.md` body: write
     `.claude/memories/<slug>.md`, make sure `.claude/memories/index.md`
     `@`-imports it, and make sure `CLAUDE.md` ends with a single
     `@.claude/memories/index.md` line — create whichever of `CLAUDE.md` /
     `index.md` is missing, but never add the note text to `CLAUDE.md`'s own
     body. Check `index.md` first so a repeat topic edits its existing memory
     file instead of adding a duplicate.
  3. **No fitting section, `AGENTS.md`-only repo** → add a new section to
     `AGENTS.md` directly (`@`-imports are a `CLAUDE.md`-only mechanism, not
     available here).

  Propose the edit per Section 7 — you write it to the working tree, the user
  lands it via a normal PR.
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

This pass also covers any `.claude/memories/*.md` file touched this session —
it's reflect-authored, so the same landfill risk applies there as in
auto-memory. It never applies to a hand-authored `CLAUDE.md`/`AGENTS.md`
section or `@`-referenced sub-file — those are maintainer-owned; reflect
amends a specific section when routing a new candidate there, never prunes
one unprompted.

If auto-memory is off, skip the auto-memory half of this pass — there's no
store to prune — but still prune any `.claude/memories/` files touched.

## 6. Match house style, stay lean

Look at the existing memory files and MEMORY.md in context and conform to
their actual conventions — frontmatter fields, section style, use of
`[[wikilinks]]` — rather than imposing a fixed template. As a ceiling, keep
each memory to roughly what the leanest existing files already look like
(short frontmatter, one orientation paragraph, a small number of dense bullet
sections) — if a memory is creeping past that, it's a sign to split, trim, or
fold it into an existing file instead. Update the MEMORY.md index line for
anything created, renamed, or deleted.

For a project-instructions proposal that amends an existing section (routing
case 1 or 3 in Section 4), match the target file's existing structure —
including its `@`-reference layout if it splits into sub-files. Keep it to
the leanest form the file already uses (a line or a bullet), state the
convention imperatively, and don't restate anything already derivable from
the code, scripts, or an existing rule in that file.

For a project memory (routing case 2 — no fitting section existed), keep it
plain: no auto-memory-style frontmatter — `@`-imported files aren't parsed
for it, so it would just be noise — a short heading naming the topic, and the
concrete convention in a sentence or two, same density as a lean auto-memory
body. `.claude/memories/index.md` is a flat list of one `@`-import line per
memory file (`@.claude/memories/<slug>.md`) under a short heading — add a
line for a new file, never restate its content there. `CLAUDE.md` itself
carries exactly one line, `@.claude/memories/index.md`, appended at the
bottom if not already present — never more than one, and never the memory
text itself.

## 7. Propose, then apply

Before writing anything, print the change list(s):

```
Proposed memory changes:
  NEW   <slug> — <why it recurs / what it shortcuts next time>
  EDIT  <slug> — <what changes and why>
  DROP  <slug> — <why stale or duplicate>
  FIX   <slug> — <wikilink / name-drift / length fix>

Proposed project-instructions changes (you land these via a normal PR):
  CLAUDE  <existing @-ref sub-file, e.g. docs/build.md, or AGENTS.md>
          › <existing heading>
          <verbatim text to add or change>
          why team-durable: <reason everyone working in this repo needs it>

  MEMORY  .claude/memories/<slug>.md  [+ new file]
          <verbatim note text>
          wiring: + .claude/memories/index.md › @.claude/memories/<slug>.md
                  [+ CLAUDE.md › @.claude/memories/index.md, if not already present]
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
