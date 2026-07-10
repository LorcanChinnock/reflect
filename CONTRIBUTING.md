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

## Pull requests

- Keep the diff scoped to the change described in the linked issue.
- Update `SKILL.md` and `README.md` together if behavior changes — they
  should never describe different behavior.
- Add a `CHANGELOG.md` entry under `Unreleased`.
