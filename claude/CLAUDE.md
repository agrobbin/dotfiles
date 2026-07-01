## General development practices

- **PREFER** existing patterns and abstractions over introducing new approaches. Check if the codebase already has a solution before proposing a new one (e.g., check for existing helper methods, established patterns).
- **ALWAYS** present a brief plan and wait for confirmation *before* starting implementation. Do not make design decisions autonomously — especially around architecture, data mutation strategy (key removal vs. nullification), or migration ordering.
- **ALWAYS** consider the names of local variables, methods, and classes just as critically as the actual functionality. Naming is key to comprehension, so abbreviated names (e.g. `u` vs `user`, `r` vs. `record`) are generally a bad idea. Reach for expressive names — including extracting a well-named method or introducing a named intermediate (e.g. a predicate method or descriptive local) — to make intent obvious from the code itself.
- **PREFER** self-explanatory code over comments. Before writing a comment, first try to make the code explain itself through better naming or extraction. **NEVER** write comments that merely restate what the code already says (e.g. `# increment the counter` above `counter += 1`), narrate a sequence of steps (`# Step 1: ...`, `# Now we ...`), or mark where/how code was changed — that context belongs in the commit message.
- **ONLY** write a comment when it explains *why* rather than *what*: context the code genuinely cannot express, such as a non-obvious rationale, a workaround for an external bug, a deliberate edge-case decision, or a link to relevant documentation/tickets.

## Shell / Bash

- **PREFER** the built-in file-editing tool over shell-based rewrites (`perl -i`, `sed -i`, `awk`). Editing tools give exact-match safety, a reviewable diff, and avoid shell-escaping pitfalls. **ONLY** reach for shell rewrites for genuine mechanical sweeps across many files (e.g. a repo-wide rename), which is almost never the case.
- **NEVER** restate the working directory in a Bash command — no leading `cd /path/to/repo &&`, no `git -C /path/to/repo`, no `make -C`, `npm --prefix`, etc. The working directory already persists between calls and is set to the repo root. Run commands directly against relative or repo-root-relative paths (e.g. `git status`, not `git -C /path/to/repo status`; `bin/rails test`, not `cd /path/to/repo && bin/rails test`). Only pass an explicit directory when the target genuinely differs from the working directory (e.g. operating on a separate worktree or submodule).
- **NEVER** chain independent commands into one Bash call with `;`/`&&`/`|` just to save round-trips. The permission matcher evaluates each segment separately and prompts unless *every* segment matches an allow rule, so bundling makes calls un-allowlistable and couples unrelated permissions. Run read-only inspection commands as separate calls — each maps to a reusable prefix rule. **ONLY** combine when there's a genuine data dependency (a real pipe like `git show … | grep …`).
- **NEVER** add decorative `echo "=== ... ==="` headers to label command output for myself — that framing belongs in the reply text, and the extra segment just needs its own permission.
- **ALWAYS** write temporary files (scripts, intermediate output, scratch data) to the session scratchpad directory — **NEVER** `/tmp` or other system temp dirs.

## Ruby / Rails

- **PREFER** isolating presentational logic from domain model logic. Models should provide the core data, while other classes then use that model.
- **PREFER** approaching problems based on the nouns and verbs that are involved. Nouns are often models / classes, while verbs are the ways those models interact with one another. Predicate methods allow you to ask questions of those nouns.

## Testing

- **ALWAYS** verify that new assertions are actually present when adding or modifying tests. Every new behavior needs at least 1 test. Do not just add code — confirm the assertions exist.

## Git

- **ALWAYS** use the `/commit` skill to create commits and write commit messages.
- **ALWAYS** use `--no-gpg-sign` when creating commits.
- **NEVER** attempt to use the `gh` CLI to create PRs. I want to do that myself and won't give you a token.
