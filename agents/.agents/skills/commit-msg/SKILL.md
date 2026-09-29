---
name: commit-msg
description: Write a single short lowercase commit message covering all uncommitted changes. Use when the user asks for a commit message.
---

Review all uncommitted changes carefully, then write one short commit message.

## Review process

1. Run `git status` to get the full picture.
2. Run `git diff --stat` to see all changed files and line counts.
3. Run `git diff` to read the actual changes; review large diffs in chunks.
4. Run `git ls-files --others --exclude-standard` to see new untracked files, and read them to understand what they add.

Understand the full scope of changes before writing the message.

## Rules for the commit message

- All lowercase.
- No period at the end.
- Cover all changes, not just some.
- Use a conventional commit prefix when it fits (`fix:`, `feat:`, `refactor:`, `chore:`, `docs:`).
- If changes span multiple concerns, summarize the primary theme.
- Output only the commit message, nothing else.
