## General development practices

- **PREFER** existing patterns and abstractions over introducing new approaches. Check if the codebase already has a solution before proposing a new one (e.g., check for existing helper methods, established patterns).
- **ALWAYS** present a brief plan and wait for confirmation *before* starting implementation. Do not make design decisions autonomously — especially around architecture, data mutation strategy (key removal vs. nullification), or migration ordering.
- **ALWAYS** consider the names of local variables, methods, and classes just as critically as the actual functionality. Naming is key to comprehension, so abbreviated names (e.g. `u` vs `user`, `r` vs. `record`) are generally a bad idea.

## Ruby / Rails

- **PREFER** isolating presentational logic from domain model logic. Models should provide the core data, while other classes then use that model.
- **PREFER** approaching problems based on the nouns and verbs that are involved. Nouns are often models / classes, while verbs are the ways those models interact with one another. Predicate methods allow you to ask questions of those nouns.

## Testing

- **ALWAYS** verify that new assertions are actually present when adding or modifying tests. Every new behavior needs at least 1 test. Do not just add code — confirm the assertions exist.

## Git

- **ALWAYS** use `--no-gpg-sign` when creating commits
- **NEVER** add newlines to commit messages solely to satisfy the 80-character line length convention. **ONLY** use them when appropriate for context separation.
- **ALWAYS** wrap code snippets in backticks, including in the summary and description sections of commit messages.
- **ALWAYS** include the `Co-authored-by` trailer, attributing some of the work to Claude. Include the model name in the trailer, without any context length details (e.g. `Claude Opus 4.6`).
- **ALWAYS** double-check commit message formatting before executing.
