# Contributing

Thanks for considering a contribution to `reflect`.

## Reporting bugs

Open an [issue](https://github.com/LorcanChinnock/reflect/issues) describing
what you expected the skill to do, what it actually did, and (if you can
share it) the relevant part of the session transcript.

## Proposing changes

Open an issue before a pull request for anything beyond a typo fix — this is
a small, opinionated skill, and a quick discussion saves a rewritten PR.

The one rule that matters: **`reflect` must stay lean.** Its entire purpose is
to keep the memory store from becoming a landfill. A change that makes the
skill write more, ask fewer questions before writing, or grow its own
filtering logic works against that purpose and will get pushed back on, even
if the change is well-intentioned. Prefer edits that make the filter
*stricter* over ones that make it more permissive.

Routing a survivor to the project-instructions file is a sort applied *after*
the filter, not a second inbox — a lesson must clear the same bar before it's
routed anywhere, and that file must never become a way to write more than the
filter already allows. `reflect` proposes and, at most, writes the working
tree; it never stages, commits, pushes, or opens the PR itself.

Never add `context: fork` to `SKILL.md`. `reflect` works by reading the
session transcript and memory index already in context — a forked subagent
starts with neither and would silently produce empty or fabricated results.
This has come up before as an "optimization" idea; it isn't one.

## Pull requests

- Keep the diff scoped to the change described in the linked issue.
- Update `SKILL.md` and `README.md` together if behavior changes — they
  should never describe different behavior.
- Run the evals in `evals/evals.json` before and after your change (see
  README's "Reliability & evals") and include the result in the PR
  description. A change that regresses a passing case needs a strong reason.
- Add a `CHANGELOG.md` entry under `Unreleased`.
