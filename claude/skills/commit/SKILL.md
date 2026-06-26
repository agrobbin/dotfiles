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

Match the change's weight: a one-line subject for trivial changes, a subject plus prose body for substantive ones. Write the *why* and the mechanism, not a restatement of the diff.

### Subject
- Imperative mood, lowercase verb lead by default (`add`, `fix`, `remove`, `stop`, `support`, `bump`, `allow`). Capitalizing the first word is fine when it reads better; don't force it.
- No trailing period. Aim for ~50 chars but prioritize clarity over the limit.
- Backtick code identifiers: `` add `language` facet to person search ``.
- Don't use prefixes (e.g. `chore` or `feat`).

### Body (when the change warrants one)
- Prose paragraphs explaining *why* and *how it works* — the reasoning the diff can't show. Call out trade-offs and deliberate non-decisions ("deliberately *not* `none` because…").
- **CRITICAL — no line wrapping.** Write each paragraph as a single continuous line. Do **not** hard-wrap or soft-wrap at 72/80 characters. Long lines are correct here even though they look wrong in a terminal preview.
- Newlines are only for: separating subject from body, separating distinct paragraphs (one blank line), and before the trailer. Never insert newlines mid-paragraph.
- Backtick all code identifiers, field names, file paths, and values.
- Weave in concrete examples where they sharpen the point (`10 <= 3 is false`, a sample query like `"tim cook apple"`).
- Use fenced code blocks for things that genuinely add context: a failing test's output, a stack trace, a CVE/docs URL, a version-diff link.
- Reference any specific context Alex asked you to include (blog posts, tickets, sibling-repo PR references).

## Committing

**ALWAYS** pass `--no-gpg-sign`.

**ALWAYS** end with the `Co-authored-by` trailer, including the **model name only**. Strip any context-window suffix (e.g. `(1M context)`) the harness footer would otherwise add. Use whichever model is actually authoring (e.g. `Claude Opus 4.8`).

Pass the message via multiple `-m` flags (one per paragraph/trailer) so each `-m` is one unwrapped line and you never embed manual `\n` wraps:

```sh
git commit --no-gpg-sign \
  -m "add \`language\` facet to person search" \
  -m "Adds a scopeable facet for filtering people by spoken language, optionally narrowed to a \`language_scope\` proficiency level. With no scope it queries \`languages_all\`; with a scope it routes to the matching per-proficiency keyword field." \
  -m "Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

After committing, run `git log -1` (or `git log -n <count>` when you made several) and confirm: no mid-paragraph newlines, no context-window suffix, each message accurate to its commit's diff.

## After history edits

If Alex amends, squashes, or rebases and asks you to revisit a message, rewrite it to match the *final* diff — don't just append. If he describes a plan to reorder/squash, confirm it's actually right rather than blindly agreeing.

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
