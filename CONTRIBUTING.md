# Contributing

Thanks for even considering this. `reflect` is small and opinionated on
purpose, which means contributions matter more here than they would on
something bigger — and also that some well-intentioned PRs are going to get
pushback. Read on before you spend time on one.

## Reporting bugs

Open an [issue](https://github.com/LorcanChinnock/reflect/issues) that says
what you expected `reflect` to do, what it actually did, and — if you can
share it — the part of the session transcript where it went sideways. "It
should have caught this detour and didn't" is a much more useful bug report
than "it's not working," because it tells us exactly which side of the
filter to look at.

## Proposing changes

For anything beyond a typo fix, open an issue before you open a PR. This
project is small enough that a five-minute discussion up front will usually
save you from writing a PR that gets rejected on a values disagreement
rather than a code one.

Here's the value, and it's the one that actually matters: **`reflect` has to
stay lean.** Its entire reason for existing is to keep the memory store from
turning into a landfill nobody wants to load. So a change that makes it write
more, second-guess itself less before writing, or grow its own bespoke
filtering logic is going to get pushed back on by default — even if it's
clean, well-tested, and clearly well-intentioned. If you're weighing two ways
to fix something, send the one that makes the filter *stricter*.

The project-instructions routing — writing into `CLAUDE.md` or `AGENTS.md` —
is not a second inbox for things that didn't quite make the cut for memory.
It's a sort applied *after* the same filter: a lesson has to clear the exact
same recurring-and-non-obvious bar before `reflect` even asks which home it
belongs in. And once it clears that bar, `reflect` still stops at the working
tree — it never stages, commits, pushes, or opens a PR itself. That part
stays a human decision, on purpose.

One thing that keeps coming back as a "quick optimization" and genuinely
isn't one: don't add `context: fork` to `SKILL.md`. `reflect` works entirely
off the session transcript and memory index that are already sitting in
context by the time it runs. A forked subagent starts with neither of those
— it'd have nothing real to reflect on, and would either come back empty or
quietly make something up. It looks like a speed win from the outside; from
the inside it just breaks the skill.

## Pull requests

- Keep the diff scoped to what the linked issue describes.
- If behavior changes, update `SKILL.md` and `README.md` together — they're
  not allowed to describe two different skills.
- Run the evals in `evals/evals.json` before and after your change (see the
  README's "Reliability & evals" section) and paste the result into the PR
  description. If a case that used to pass now fails, you'll need a genuinely
  good reason for it.
- Add a line to `CHANGELOG.md` under `Unreleased`.
