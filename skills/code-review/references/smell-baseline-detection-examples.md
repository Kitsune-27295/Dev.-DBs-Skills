# Smell Baseline: Detection Patterns and Review Mechanics
Sources: https://github.com/mattpocock/skills/blob/main/skills/engineering/code-review/SKILL.md · Last verified 2026-11-23

The upstream skill reviews a diff on two deliberately separate axes (Standards, Spec) using fresh-context sub-agents, and adds a fixed baseline of twelve Fowler smells (from Refactoring, ch. 3) to the Standards axis. SKILL.md lists the smells and fixes. This file adds how to spot them in a diff and how to avoid common review mistakes. Detection patterns and examples are the author's own inference from the upstream definitions.

## Binding rules from the upstream page
1. A documented repo standard overrides the baseline; suppress a smell the repo endorses.
2. Every smell is a labeled heuristic ("possible Feature Envy"), never a hard violation.
3. Skip what tooling already enforces (linters, formatters, type checkers).
4. Pin the fixed point first (`git rev-parse`, non-empty `git diff <ref>...HEAD`) so failures happen before sub-agents spawn.
5. Do not merge or rerank the two axes; report counts and the worst issue per axis.

## What each smell looks like inside a diff
| Smell | Diff signal (inference) |
|---|---|
| Duplicated Code | two added hunks with the same shape, different identifiers |
| Shotgun Surgery | one concept touched in 6+ files with tiny edits each |
| Divergent Change | one file's hunks serve unrelated reasons (billing plus formatting) |
| Repeated Switches | a `switch (x.kind)` added in a second place for the same `kind` |
| Data Clumps | `(street, city, zip)` added to three signatures |
| Primitive Obsession | `string email`, `number cents` passed through domain code unparsed |
| Speculative Generality | new interface with one implementer; unused parameter; hook with no caller |
| Middle Man | new class whose methods only forward to one collaborator |
| Message Chains | `order.customer().address().country().code()` added |

Mysterious Name, Feature Envy and Refused Bequest need surrounding code, not just the hunk; read the file before flagging.

## Example: repeated switch
```ts
// hunk 1
function price(p: Plan) { switch (p.kind) { case "pro": return 20; case "team": return 50; } }
// hunk 2 (another file)
function seats(p: Plan) { switch (p.kind) { case "pro": return 1; case "team": return 10; } }
```
Report: "possible Repeated Switches on Plan.kind (price, seats): consider one lookup map or per-kind objects." Phrase it as a judgment call and quote both hunks.

## Failure modes
- Presenting a smell as a violation, which breaks the always-a-judgment-call rule.
- Flagging smells the repo explicitly endorses.
- Sub-agents that inherit the builder's context share its blind spots; start each with a fresh context, and paste the smell list into the brief because the sub-agent cannot see it otherwise.
- Merging the axes into one ranked list, hiding that code can follow every standard yet implement the wrong thing (or the reverse).
- Reviewing without a spec: skip the Spec sub-agent and say so in the report.
- Unbounded reports: keep each sub-agent under about 400 words.

## How an agent should apply this
- Resolve and validate the fixed point before any sub-agent call.
- Include the full smell list and the standards-source file list in the Standards brief.
- Read surrounding code before flagging smells that depend on context (Feature Envy, Refused Bequest, Mysterious Name).
- Label baseline findings as possible smells; cite file plus rule for documented-standard breaches.
- End with per-axis finding counts and the worst issue in each axis, with no cross-axis winner.
