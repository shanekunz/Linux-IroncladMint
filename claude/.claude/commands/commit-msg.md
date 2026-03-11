---
description: Generate a short lowercase commit message from uncommitted changes
---

Carefully review ALL uncommitted changes and write a single short commit message.

## Review process

1. Run `git status` to get the full picture
2. Run `git diff --stat` to see all files changed and line counts
3. Run `git diff` to read the actual changes - if large, review in chunks
4. Run `git ls-files --others --exclude-standard` to see new untracked files
5. For new files, read their content to understand what they add

Take time to understand the full scope of changes before writing the message.

## Rules for the commit message

- all lowercase
- no period at the end
- must cover ALL changes, not just some
- use conventional commit prefix if appropriate (fix:, feat:, refactor:, chore:, docs:)
- if changes span multiple concerns, summarize the primary theme
- output ONLY the commit message, nothing else
