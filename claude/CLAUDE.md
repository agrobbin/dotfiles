## General development practices

- **PREFER** existing patterns and abstractions over introducing new approaches. Check if the codebase already has a solution before proposing a new one (e.g., check for existing helper methods, established patterns).
- **ALWAYS** present a brief plan and wait for confirmation *before* starting implementation. Do not make design decisions autonomously — especially around architecture, data mutation strategy (key removal vs. nullification), or migration ordering.
- **ALWAYS** consider the names of local variables, methods, and classes just as critically as the actual functionality. Naming is key to comprehension, so abbreviated names (e.g. `u` vs `user`, `r` vs. `record`) are generally a bad idea.

## Shell / Bash

- **NEVER** restate the working directory in a Bash command — no leading `cd /path/to/repo &&`, no `git -C /path/to/repo`, no `make -C`, `npm --prefix`, etc. The working directory already persists between calls and is set to the repo root. Run commands directly against relative or repo-root-relative paths (e.g. `git status`, not `git -C /path/to/repo status`; `bin/rails test`, not `cd /path/to/repo && bin/rails test`). Only pass an explicit directory when the target genuinely differs from the working directory (e.g. operating on a separate worktree or submodule).

## Ruby / Rails

- **PREFER** isolating presentational logic from domain model logic. Models should provide the core data, while other classes then use that model.
- **PREFER** approaching problems based on the nouns and verbs that are involved. Nouns are often models / classes, while verbs are the ways those models interact with one another. Predicate methods allow you to ask questions of those nouns.

## Testing

- **ALWAYS** verify that new assertions are actually present when adding or modifying tests. Every new behavior needs at least 1 test. Do not just add code — confirm the assertions exist.

## Git

- **ALWAYS** use `--no-gpg-sign` when creating commits.
- **NEVER** add extraneous newlines to commit messages solely to satisfy the 72-character line length convention. **ONLY** use them when appropriate for context separation.
- **ALWAYS** wrap code snippets in backticks, including in the summary and description sections of commit messages.
- **ALWAYS** include the `Co-authored-by` trailer, attributing some of the work to Claude. Include the model name in the trailer, without any context length details (e.g. `Claude Opus 4.8`).
- **ALWAYS** double-check commit message formatting before executing.
- **PREFER** writing commit messages with prose rather than simply repeating the code changes. Still use code blocks when important for explaining complex bug fixes or providing critical context.
- **NEVER** attempt to use the `gh` CLI to create PRs. I want to do that myself and won't give you a token.
