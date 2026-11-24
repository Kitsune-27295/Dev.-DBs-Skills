# Context Stack Audit (Report-Only)

Sources: https://www.anthropic.com/research/effective-context-engineering-for-ai-agents · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices · https://github.com/garrytan/gbrain (MIT, context-audit skill) · Last verified 2026-11-24

## Contents
- What to audit
- Procedure
- Ranking and risk classes
- Report shape with delta
- How an agent should apply this

## What to audit
Audit what this harness loads on every turn: user-global and project instruction files, auto-loaded memory, hook-injected rules, and the metadata of installed skills and tool definitions. On-demand content (skill bodies, references) is not a subject; it is the destination for content that matters to one workflow only. Instruction-file governance itself is owned by `skill-orchestrator`; this file is the measurement-and-report step.

## Procedure
1. **Enumerate** the always-loaded files for this harness; do not assume a fixed list.
2. **Measure.** If the host reports an exact breakdown, use it. Otherwise estimate from bytes with a stated divisor (roughly 2.6 to 3.5 bytes per token for markdown heavy with paths and code, per the cited skill; print your divisor so anyone can recompute).
3. **Read each file fully** and test six dimensions: token efficiency, redundancy, contradictions, skill-worthiness, staleness, clarity.
4. **Classify risk** per finding and **rank** by savings.
5. **Report, do not edit.** Every row needs quoted evidence and the place the fix belongs (for generated files, the template or source, never the generated output). Apply changes in a separate, deliberate step.

## Ranking and risk classes
| Class | Meaning | Typical finding |
|---|---|---|
| Zero | Pure deletion of exact duplicate or dead content | same rule in two files; removed feature still described |
| Low | Compression or extraction with a clear trigger | workflow detail moved into a skill that loads on demand |
| Medium | Could shift edge-case behavior | merging or rewording a safety rule |

Order by tokens recoverable, descending; list contradictions first regardless of size because they cost correctness. Anthropic's context-engineering article supplies the rationale: the smallest high-signal token set, and rules added for observed failures, not speculation.

## Report shape with delta
```text
Audit <date>: stack ~N tokens over K files (basis: exact | bytes/<divisor>)
Delta vs previous report: +/-N tokens; files moved: ...; findings reopened/declined: ...
| # | Save (tok) | Risk | File | Finding | Evidence (quote) | Fix and where it lives |
Contradictions (first): FILE-A says X, FILE-B says Y -> keep one.
Skill-extraction candidates: ...
```
Compute the delta from the previous saved report; do not re-flag findings the owner already declined, and state when no previous report exists. Label estimates as estimates.

## How an agent should apply this
- Keep the audit read-only; hand the owner a ranked list.
- Quote evidence for every row and print the token basis.
- Put contradictions first, then rank by tokens and risk.
- Compare against the previous report and show the delta, or say there is none.
- Send workflow-only content to skills, not into deletion, when the behavior is still wanted.
