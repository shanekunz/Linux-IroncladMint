---
name: jira-implement
description: Implement a Jira task end to end using the Atlassian and GitHub MCP servers, delivering a PR into the current Sprint branch. Use when the user gives a Jira issue key or URL to implement.
---

Pull down all context for the Jira task the user named (feature or bug) using the Atlassian MCP server, then implement or solve it.

- If you cannot implement or solve it with high confidence, still leave highly insightful comments so the user can finish it more easily.
- When you make changes, use the GitHub MCP server to create a branch off the latest `Sprint-*` branch, apply your changes there, and open a PR back into that Sprint branch as the deliverable for review.
- The user may provide additional context for specific tasks.
