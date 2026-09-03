---
name: commit
description: Write Git commits in Alex's preferred style and commit them. Use when the user invokes /commit or asks to commit staged/current changes.
---

# Commit

Stage-aware committing in Alex's voice. Don't assume the diff has been reviewed. Let the **complexity** of the change decide whether to commit straight away or surface the plan first:

- **Simple / low-risk → commit immediately.** Trivial or mechanical changes, a single obvious logical unit, dependency bumps, config tweaks, small fixes. Draft the message and land it without asking.
- **Complex / non-obvious → present first, then wait.** When the change spans multiple logical units, touches sensitive areas (migrations, data mutation, security, anything hard to reverse), or the right grouping/message is genuinely ambiguous, show your proposed split and message(s) and wait for Alex's go-ahead before committing.

When in doubt, lean toward showing first — a quick confirmation is cheaper than a bad commit. Either way Alex can amend or ask for a rewrite afterward.

## Decide how many commits

Before writing anything, evaluate whether the change is **one logical change or several**, and commit each logical piece in isolation. Alex values clean, separately-reviewable history — don't lump unrelated work into a single commit.

1. Run `git status` and inspect the full diff: `git diff --staged` if anything is staged, otherwise `git diff` (plus untracked files worth including).
2. Group the changes into logical units. A unit is one coherent concern a reviewer would want to read on its own — a feature, a bug fix, a refactor, a dependency bump, a config tweak. Signals that you're looking at *separate* units: unrelated files/subsystems, a fix bundled with an unrelated cleanup, a refactor mixed with a behavior change, churn (formatting/renames) alongside real logic.
3. **One unit → one commit. Multiple units → multiple commits**, each staged and committed in isolation, in an order that reads sensibly (e.g. prerequisite/refactor commits before the feature that builds on them).
4. To isolate a unit, stage exactly its paths (`git add <paths>`); when a single file mixes units, use `git add -p` to stage only the relevant hunks. Verify with `git diff --staged` that each commit contains only its unit before committing.
5. If something is already staged and clearly represents the intended single unit, respect that staging and just commit it.

When you split, briefly tell Alex how you grouped the work and what each commit contains.

## The message

Match the change's weight — where *weight* means how much non-obvious reasoning the change carries, **not** how many files it touches. A 9-file feature whose rationale is one sentence gets a one-sentence body. Write the *why* behind the change; messages should add context, not restate the diff.

**Budget:** subject-only for trivial/mechanical changes. **One short paragraph** for most changes. **Two at the very most**, for genuinely subtle ones. If you're writing a third, you've started explaining the diff instead of the reasoning — cut back.

### Subject
- Imperative mood, lowercase verb lead by default (`add`, `fix`, `remove`, `stop`, `support`, `bump`, `allow`). Capitalizing the first word is fine when it reads better; don't force it.
- No trailing period. Aim for ~50 chars but prioritize clarity over the limit.
- Backtick code identifiers: `` add `language` facet to person search ``.
- Don't use prefixes (e.g. `chore` or `feat`).

### Body (when the change warrants one)
- One paragraph on *why*, and *how it works* only where that isn't evident — the reasoning the diff can't show. A trade-off or deliberate non-decision ("deliberately *not* `none` because…") gets **one sentence**, not its own paragraph.
- **CRITICAL — no line wrapping.** Write each paragraph as a single continuous line. Do **not** hard-wrap or soft-wrap at 72/80 characters. Long lines are correct here even though they look wrong in a terminal preview.
- Newlines are only for: separating subject from body, separating distinct paragraphs (one blank line), and before the trailer. Never insert newlines mid-paragraph.
- Backtick all code identifiers, field names, file paths, and values.

Only when it earns its place:
- A concrete example that sharpens the point (`10 <= 3 is false`, a sample query like `"tim cook apple"`) — at most one per point.
- A fenced code block for something prose can't carry: a failing test's output, a stack trace, a CVE/docs URL, a version-diff link.
- Specific context Alex asked you to include (blog posts, tickets, sibling-repo PR references).

### Cut these
- **The plumbing inventory.** No "wired through the usual layers" paragraph listing registrations, params allowlists, or regenerated specs — the diff shows all of it.
- **Defenses of style choices** (which mixin or base class, naming, file placement) unless the choice was contested or genuinely surprising.
- **A second example making the same point.** One is enough.
- **Anything a reviewer gets off the diff in ten seconds.**

## Committing

**ALWAYS** end with the `Co-authored-by` trailer, including the **model name only**. Strip any context-window suffix (e.g. `(1M context)`) the harness footer would otherwise add. Use whichever model is actually authoring (e.g. `Claude Opus 4.8`).

Pass the message via multiple `-m` flags (one per paragraph/trailer) so each `-m` is one unwrapped line and you never embed manual `\n` wraps:

```sh
git commit \
  -m "add \`language\` facet to person search" \
  -m "Adds a scopeable facet for filtering people by spoken language, optionally narrowed to a \`language_scope\` proficiency level. With no scope it queries \`languages_all\`; with a scope it routes to the matching per-proficiency keyword field." \
  -m "Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

After committing, run `git log -1` (or `git log -n <count>` when you made several) and confirm: no mid-paragraph newlines, no context-window suffix, each message accurate to its commit's diff.

## After history edits

If Alex amends, squashes, or rebases and asks you to revisit a message, rewrite it to match the *final* diff — don't just append. If he describes a plan to reorder/squash, confirm it's actually right rather than blindly agreeing.

## GitHub PRs

When asked to write a PR title and description, follow these principles:

- **Title**: If there is 1 commit, use the subject line of that commit. If there are multiple commits, summarize the overall changes on the branch in a single line.
- **Description**: If there is 1 commit, use the body of that commit. If there are multiple commits, summarize the overall changes, basing the length on the complexity of the diff.
- **Formatting**: Use Markdown, with fenced code blocks for any examples or logs. Avoid hard-wrapping lines; let them flow naturally.

## Examples (real, abbreviated)

Trivial — subject only:

```
only consider an employment as current if it has a start date
```

Bug fix — subject + why-focused body with a concrete example:

```
fix `organization_funding_event_stage` filter for cross-year employments

The `WHERE` clause in `intermediate.search_documents_employments_organization_funding_event_stages` applied `month <= start_month` regardless of year, so a funding event in (e.g.) October 2023 was wrongly excluded from an employment starting March 2024 — `10 <= 3` is false, even though October 2023 precedes March 2024.

Replace the split year/month comparison with a single date comparison: `date_trunc('month', funding_event_date) <= make_date(start_year, COALESCE(start_month, 12), 1)`. Both sides normalize to the first of the month, so `<=` cleanly means "in or before the employment's start month," and a `NULL` `start_month` becomes "any month in `start_year`."
```

Dependency bump — short body with a link:

```
upgrade Brakeman to v4.0.5

https://brakemanscanner.org/blog/2026/06/12/brakeman-8-dot-0-dot-5-released
```

Substantive feature — nine files changed, and still just one paragraph of *why* plus one sentence of trade-off. This is the length to beat, not a floor to build on:

```
add `given_name` and `family_name` facets to person search

Two scalar facets that match only their own field, unlike `name`, which spans `given_name`, `family_name`, and `full_name` — so `family_name: 'Scott'` returns Daniel Scott but not Scott Boatwright. The shared query shape lives in a `Facets::NameField` mixin; each facet just sets `field`.

Prefix matching runs against the analyzed text fields rather than new `as_you_type` subfields, keeping this off the reindex path. The trade-off is no accent folding: `family_name: 'Gonzalez'` won't match `González`.
```
