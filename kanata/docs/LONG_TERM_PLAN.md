# Kanata Long-Term Plan

This document tracks a stable, low-churn path for evolving this layout.

## Guiding Principles

- Prioritize consistency over micro-optimizations during adaptation.
- Avoid changing key meaning before speed/accuracy stabilize.
- Make one meaningful change at a time and measure it.
- Keep Linux and Windows configs behaviorally aligned (except intentional Alt/Mod swap for GlazeWM parity).

## Current Baseline

- Base layer tracks Enthium v14 punctuation order (`;` then `/`).
- Symbol layer is focused on rows 2-4 with low redundancy and coding coverage.
- Nav layer is simplified (rows 1/5 mostly disabled to reduce noise/reach).
- Num layer has `0` on pinky.

Primary files:

- `kanata/.config/kanata/kanata.kbd`
- `windows/work/windows-kanata/kanata.kbd`
- `kanata/docs/Enthium Elegant Keymap - Base.json`
- `kanata/docs/Enthium Elegant Keymap - Symbol.json`
- `kanata/docs/Enthium Elegant Keymap - Nav.json`
- `kanata/docs/Enthium Elegant Keymap - Num.json`

## Phase 1: Lock-In (Now -> 50 WPM)

Goal: Build dependable muscle memory before introducing advanced behaviors.

Do:

- Keep alphas/layers semantics stable.
- Practice daily in real coding + targeted typing practice.
- Track rough weekly metrics:
  - sustained WPM
  - accuracy
  - subjective fatigue (0-10)
  - top 3 friction points noticed during coding

Do not:

- Add magic/adaptive key logic.
- Add broad chord systems for symbols.
- Reorder home-row mods or major layer access patterns.

Exit criteria for Phase 1:

- Sustained 50+ WPM with stable accuracy.
- Friction points are specific/repeatable (not general adaptation noise).

## Phase 2: Targeted Experiments (50+ WPM)

Goal: Validate small, high-confidence improvements with minimal disruption.

Experiment process:

1. Pick exactly one change.
2. Apply to Linux + Windows configs.
3. Validate with `kanata --check` on both files.
4. Use for 5-7 days.
5. Keep/revert based on measurable benefit.

Suggested experiment order:

1. Small num-layer efficiency tweaks (if real numeric workload demands it).
2. One optional magic/adaptive mapping only if it solves a real pain point.
3. Additional mapping only after the first is clearly positive.

Hard rule:

- No stacked experiments (never test multiple semantic changes at once).

## Phase 3: Advanced Features (Only If Needed)

Potential options:

- Magic key/adaptive transforms.
- Symbol chords (limited scope, conflict-aware with HRMs).
- Repeat key revisit (only if repeated-character strain appears).

Gate before enabling:

- Identified bottleneck from real usage logs.
- Clear expected benefit.
- Easy rollback path documented.

## Magic Key Notes (Deferred)

Context gathered from community feedback:

- `H` is a popular candidate due to frequency and combinability.
- `J`/`K` are alternatives with lower letter-frequency interference.
- Some analyzer-identified weak bigrams in Enthium are already physically tolerable via raking/sliding.

Decision policy:

- Do not optimize analyzer metrics alone.
- Only optimize combinations that feel consistently awkward in real typing.

## Community Feedback Archive (Raw + Interpreted)

This section preserves external suggestions verbatim-ish so no context is lost.

### Suggestions received

- Possible alpha thought: `W` and `B` might be swapped (author rationale exists upstream).
- Numpad suggestion: put `0` on pinky or thumb; optional `00` and `000` in same column.
- Numpad side suggestion: put numpad on left hand to allow right-hand mouse use.
- Symbol suggestion: reduce symbol-layer usage with pair chords.
  - Example idea: `A+E => (` and `A+I => )`, `O+U => [`, with shifted pair reuse for `<` / `{` style mapping.
- Repeat-key suggestion:
  - put repeat on `;`
  - use `H` as a helper in repeat/adaptive flow for `E`/`O`
  - claim: repeats improve smoothness by reducing repeated same-finger taps.
- Adaptive/magic suggestions:
  - `U => E` (via magic key)
  - `M => L` (via magic key)
  - `L => M` (via magic key)
  - `I => NG` (via magic key)

### Follow-up clarifications from same commenter

- They already chord system keys and reported no HRM/chord interference in their setup.
- Their setup detail: HRMs on bottom row, with one overlap, no misfires (for them).
- They specifically argued for `H` as the default magic key because:
  - it can follow many letters
  - it is home-row and frequent
  - they evaluate rare/valid follow sequences as part of magic-key choice
- They called out alternatives: `J` and `K` as other reasonable magic-key candidates.
- They mentioned using Norvig n-gram stats and filtering workflows in Helix to evaluate candidate pairs.

### Current project stance (as of this plan)

- Accepted and implemented:
  - numpad `0` moved to pinky.
- Deferred (not currently adopted):
  - repeat key on `;`
  - magic/adaptive mappings
  - symbol chords
  - left-hand numpad migration
  - alpha `W/B` experimentation
- Reason for deferment:
  - stability-first adaptation until sustained 50+ WPM
  - avoid semantic churn while core muscle memory is still forming

## Documentation Hygiene

When changing any layer:

1. Update Kanata config(s):
   - `kanata/.config/kanata/kanata.kbd`
   - `windows/work/windows-kanata/kanata.kbd`
2. Update matching KLE JSON in `kanata/docs/`.
3. Re-export matching PNG(s).
4. Regenerate `kanata/docs/Enthium Elegant Keymap - All Layers.png` if layer visuals changed.
5. Validate both configs:
   - `kanata --check -c kanata/.config/kanata/kanata.kbd`
   - `kanata --check -c windows/work/windows-kanata/kanata.kbd`

## Quick Review Cadence

- Monthly (or after major usage shift):
  - keep/revert pending experiments
  - verify Linux/Windows parity still intentional
  - confirm docs/images match behavior

## Success Criteria

- Stable comfort and confidence in daily coding.
- Reduced mental overhead (symbols/nav become automatic).
- Measured improvements without layout churn.
- Publicly shareable, maintainable config/docs that stay in sync.
