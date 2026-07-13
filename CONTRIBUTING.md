# Contributing

Thanks for considering it. `reflect` is small and opinionated on purpose,
which means contributions here matter more than they would on something
bigger — and also that some well-meant PRs are going to get pushback. Worth
reading this before you sink time into one.

## Reporting bugs

Open an [issue](https://github.com/LorcanChinnock/reflect/issues) with what
you expected `reflect` to do, what it actually did, and — if you can share
it — the part of the transcript where it went sideways. "It should have
caught this detour and didn't" is far more actionable than "it's not
working," because it points straight at which side of the filter needs a
look.

## Proposing changes

For anything past a typo fix, open an issue before a PR. The project is
small enough that five minutes of discussion up front usually saves you
from a PR that gets rejected on a values disagreement rather than a code
one.

Here's the value that actually matters: **`reflect` has to stay lean.** Its
whole reason for existing is to stop the memory store from becoming a
landfill nobody wants to load. So a change that makes it write more,
second-guess itself less before writing, or grow its own bespoke filtering
logic is going to get pushed back by default — even if it's clean, tested,
and clearly well-intentioned. When you're choosing between two fixes, send
the one that makes the filter *stricter*.

The project-instructions routing — amending an existing `@`-referenced
sub-file or `AGENTS.md` section, or writing a `.claude/memories/` note when
nothing already fits — isn't a second inbox for things that didn't quite
make the memory cut.
It's a sort applied *after* the same filter: a lesson has to clear the exact
same recurring-and-non-obvious bar before `reflect` even asks which home it
belongs in. And once it clears that bar, `reflect` still stops at the
working tree — it never stages, commits, pushes, or opens a PR itself. That
stays a human decision, on purpose.

One thing that keeps resurfacing as a "quick optimization" and genuinely
isn't: don't add `context: fork` to `SKILL.md`. `reflect` works entirely off
the session transcript and memory index already sitting in context by the
time it runs. A forked subagent starts with neither — it would have nothing
real to reflect on, and would either come back empty or quietly make
something up. It reads like a speed win from the outside; from the inside
it just breaks the skill.

## Pull requests

- Keep the diff scoped to what the linked issue describes.
- If behavior changes, update `SKILL.md` and `README.md` together — they're
  not allowed to describe two different skills.
- Run the evals in `evals/evals.json` before and after your change (see the
  README's "Reliability & evals" section) and paste the result into the PR
  description. If a case that used to pass now fails, you'll need a
  genuinely good reason for it.
- Add a line to `CHANGELOG.md` under `Unreleased`.
