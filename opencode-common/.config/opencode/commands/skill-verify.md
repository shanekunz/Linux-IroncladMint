---
description: Verify OpenCode skill tracking data quickly
---

Verify the skill tracker using the runtime files in `~/.config/opencode/`.

Instructions:

1. Interpret my request flexibly. I may provide explicit filters like `skill=learning-mode`, or natural language like "check whether learning-mode was tracked in my dotfiles repo"
2. Infer optional `skill` and/or `project` filters from the request when they are clear
3. First read these files if they exist:
   - `~/.config/opencode/skill-tracker-status.json`
   - `~/.config/opencode/skill-usage.json`
   - `~/.config/opencode/skill-usage.audit.jsonl`
4. If the audit file is large or needs filtering, use shell commands like `node`, `bun`, `jq`, or `rg` to inspect it efficiently
5. Explain whether tracking appears healthy based on plugin heartbeat, summary totals, and the latest matching audit record
6. If files are missing, say clearly whether that means the plugin did not load or the skill tool was not observed
7. Keep the answer concise and practical

User filters:

$ARGUMENTS
