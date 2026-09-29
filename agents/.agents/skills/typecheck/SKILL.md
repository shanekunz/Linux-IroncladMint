---
name: typecheck
description: Run the project's typecheck and fix TypeScript errors at their root cause. Use when the user asks to typecheck, or when type errors block finishing a change.
---

Run the project's typecheck script (`pnpm typecheck`, or the equivalent for the repo's package manager) and fix any TypeScript errors.

1. Run the typecheck first to see all errors.
2. Fix each error at its root cause. Do not paper over it with type assertions or `any`.
3. Read the relevant files first when a fix needs context.
4. Run the typecheck again to confirm no new errors appeared.
5. Summarize what you fixed and why.
