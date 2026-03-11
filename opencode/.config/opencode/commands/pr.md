---
description: Create pull request
---

Create a GitHub PR for the current branch.

Instructions:

1. Check `git status` and `git diff main...HEAD` to understand all changes
2. Look at recent commit messages with `git log main..HEAD --oneline`
3. Create a PR with:
   - **Title**: Clear, concise summary (e.g., "Add printer configuration page" not "Updates")
   - **Description**:
     - What changed and why
     - Any breaking changes or migration notes
     - Testing notes if relevant
4. Use `gh pr create` with a heredoc for the body to preserve formatting
5. Return the PR URL when done
