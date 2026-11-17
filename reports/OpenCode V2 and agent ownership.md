# OpenCode V2 Separates Intelligence From Authority

My take: **V2's interesting bet is that you should be able to change who supplies the intelligence without surrendering who governs the work.** That is more consequential than another model picker, but less accomplished than calling it a reliable autonomous colleague. The distinction matters because generating a plausible change and accepting responsibility for an ongoing job are different engineering problems. V2 puts more explicit machinery around the latter. I find that direction compelling for your setup, not evidence that it already beats Codex or Claude Code. This judgment uses documentation checked on October 15, 2026, not a comparative reliability test.

## The important change is who owns the job

First, the historical correction: V1 already had a client-server architecture, an API, providers, plugins and agents. Its documentation explicitly describes the TUI as a client and supports asynchronous prompts. V2 did not discover extensibility or background execution. ([V1 server documentation](https://opencode.ai/docs/server/))

The narrower change matters more: V2 normally discovers or starts one shared background server per user account. That server owns sessions, configuration, integrations, permissions and tool execution; local clients connect to it. ([V2 service architecture](https://opencode.ai/v2/docs/cli/#background-service))

My interpretation is that this changes the product's center of gravity. The window becomes a way to supervise work rather than the thing around which work is organized. Closing a client and terminating execution become distinct concerns, although this does not establish universal crash recovery.

The philosophical issue is decision authority. Which component remembers your correction, chooses the next action and decides whether permission still applies? That component shapes the practical agent as much as the model does. Separating it from the intelligence supplier gives your procedures somewhere to accumulate without making every model change a workplace migration. This is a stronger ownership boundary, not an unprecedented invention.

## The scarce resource is attention, not output

As a practical judgment, once agents can propose changes faster than you can confidently accept them, additional generation has diminishing value. The bottleneck shifts toward specification, verification and deciding when to intervene. Cheap generation can create expensive obligations: every extra diff needs someone to determine whether it belongs.

V2's durable prompt admission, steering versus queueing, scoped plugin lifecycle and stable tool snapshots address parts of that coordination problem. They distinguish accepting work from completing it, and changing future behavior from mutating an operation already underway. Importantly, the documentation explicitly says prompt hooks are **not an exactly-once side-effect boundary**. These are useful contracts, not proof that arbitrary interrupted actions resume safely. ([V2 plugin contracts](https://opencode.ai/v2/docs/build/plugins/))

That makes the ambitious interpretation fairly concrete: a better runtime should reduce how often the human must reconstruct what happened. More agents are worthwhile only if their verification and integration costs leave a net gain.

We should distrust how productive this feels. METR's February 2026 follow-up found current coding productivity difficult to estimate because of selection effects and concurrent-agent work; it explicitly cautioned against treating its early-2025 slowdown result as current. The lesson is measurement humility, not that agents necessarily help or hurt. ([METR's updated study](https://metr.org/blog/2026-02-24-uplift-update/))

For you, the output unit is an accepted, reproducible change, not a persuasive transcript or a busy herdr dashboard.

## Persistence can preserve the wrong intention

Here is the deepest limitation: **execution continuity is not continuity of intent**. A service can faithfully retain a plan you have rejected. A summary can preserve the main objective while dropping the exception that made the task safe.

V2 documents task-shaped compaction covering objectives, requirements, decisions, completed work, blockers and next moves. It also explicitly calls compaction lossy. Earlier messages remain stored without necessarily reaching the model. Optional native OpenAI checkpoints are opaque and tied to the same provider, model and endpoint; switching models falls back to the original conversation, not a portable encrypted memory. ([V2 compaction and its limits](https://opencode.ai/v2/docs/compaction/))

My inference is that the valuable long-lived agent will resemble a well-run handoff more than a person with perfect recall. It needs to distinguish instructions from suggestions, attempted commands from successful tests, and old permission from present authority. Keeping everything is insufficient if the system cannot identify what supersedes what.

Your repository already supplies part of that discipline: Stow conventions, idempotency requirements and synchronized i3 keybind documentation. A durable task record pointing to actual diffs and test results can matter more than a longer conversation. V2 provides mechanisms for continuity; the documentation does not establish that it reliably preserves those distinctions.

## Neutrality competes with integration, not stupidity

The broader contest is not open tools versus vendors too shortsighted to support tools. Standards can make skills and integrations reusable while leaving the consequential choices with the host. The November 2025 MCP architecture explicitly assigns authorization, context aggregation and connection governance to the host. Standard connectors do not standardize decision authority. ([MCP architecture](https://modelcontextprotocol.io/specification/2025-11-25/architecture))

Nor does useful model choice require believing models are interchangeable. Different suppliers can be preferable for different work while requiring different reasoning, caching and continuity behavior. The point of neutrality is a credible alternative, not pretending those differences disappear.

The strongest counterargument is that integrated vendors can offer better model-harness coordination, fewer operational seams and attractive bundled access. An independent runtime can leave you maintaining adapters and plugins while paying separately for inference. Your skill-tracker migration is a small, tangible example of that maintenance bill.

Access policy also constrains ownership. Anthropic's current policy prohibits third-party applications from intermediating Claude subscription credentials, while allowing platforms to host its unmodified Claude Code binary under specified conditions. ([Anthropic's policy](https://code.claude.com/docs/en/legal-and-compliance)) OpenAI currently documents plan-funded eligible Responses requests for eligible open-source and locally hosted applications, but explicitly excludes access to ChatGPT conversation context. ([OpenAI's documented route](https://developers.openai.com/siwc/token-sharing-open-source.md))

So open code does not guarantee portable economics or memory. My conditional prediction: neutral runtimes remain valuable if they make changing suppliers operationally credible. Supporting the same connectors as everyone else will not, by itself, sustain that advantage.

## For your setup, make ownership earn its keep

I would keep V2 as your customizable, provider-neutral workbench, not promote it to your sole harness. Shared skills and repository-owned procedures already give you leverage across Codex, Claude Code and OpenCode. Preserve that independence rather than relocating everything into OpenCode-specific plugins.

Make V2 earn primary status on real dotfiles tasks: an installer change, synchronized i3 documentation and a plugin fix. Include a client reconnection and a late correction. Prefer it if it consistently reduces active review and recovery time at unchanged acceptance standards, including maintenance costs. Reject the optimistic thesis if it restores stale instructions, repeats side effects, invents test success or merely generates more work to review.

That is why I think V2 is special in direction rather than proven superiority. It makes the execution environment a more explicit object of engineering and ownership. For an i3/dotfiles person, that is an unusually compatible ambition. But wanting to own your tools should not obligate you to spend your evenings repairing them.
