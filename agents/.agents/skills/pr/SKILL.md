---
name: pr
description: Create a GitHub pull request for the current branch with a clear title and description. Use when the user asks to open, create, or raise a PR.
---

Create a GitHub PR for the current branch.

1. Check `git status` and `git diff main...HEAD` to understand all changes. Use the repo's default branch if it is not `main`.
2. Look at recent commit messages with `git log main..HEAD --oneline`.
3. Write the PR:
   - **Title**: a clear, concise summary (e.g., "Add printer configuration page", not "Updates").
   - **Description**: what changed and why, any breaking changes or migration notes, and testing notes when relevant.
4. If branch readiness is unclear, do a quick readiness pass first: missing verification, docs drift, rollout notes, or merge blockers.
5. Run `gh pr create` with a heredoc body to preserve formatting.
6. Return the PR URL.
