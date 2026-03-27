---
description: Inspect detailed OpenCode skill audit history
---

Inspect the detailed skill audit log at `~/.config/opencode/skill-usage.audit.jsonl`.

Instructions:

1. Interpret my request flexibly. I may provide explicit filters like `skill=learning-mode since=7d`, or natural language like "show me the last few learning-mode calls from this week in dotfiles"
2. Infer filters such as `skill`, `project`, `since`, `limit`, and `summary` from the request when they are clear
3. Read `~/.config/opencode/skill-usage.audit.jsonl`; if needed also read `~/.config/opencode/skill-usage.json` for aggregate context
4. Use shell commands like `node`, `bun`, `jq`, or `rg` when filtering or summarizing the audit log is easier than reading the full file directly
5. Return the most useful findings, highlighting recent matching invocations or summary counts
6. Mention the exact filters used so I can repeat the query later

User filters:

$ARGUMENTS
