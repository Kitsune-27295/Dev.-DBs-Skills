# Context Engineering Applied to Instruction Files

Sources: https://www.anthropic.com/research/effective-context-engineering-for-ai-agents (Anthropic Engineering, published 2025-09-29) · https://code.claude.com/docs/en/best-practices · https://code.claude.com/docs/en/memory · https://github.com/TechSpokes/agency-specifications-files-agents-md (secondary, ordering idea only) · Last verified 2026-11-27

Boundary: general context-engineering theory is owned by `agent-skills-context-engineering` (section 2) and model/effort and cost routing by `model-effort-routing`. This file only places instruction-file content; every mechanism it names is owned by the file linked in the table, and the rule ids are in [rule-registry.md](rule-registry.md).

## 1. What the Anthropic article contributes here

The article's theory (attention budget and context rot, right altitude, just-in-time retrieval, compaction, note-taking, sub-agents) is not restated; read `agent-skills-context-engineering`. Instruction-file facts it supports: it names CLAUDE.md as the example of the small upfront load in a hybrid strategy (verified), and it gives no line count for instruction files. The 200-line target comes from the Claude Code docs (see [claude-md-official-guidance-and-limits.md](claude-md-official-guidance-and-limits.md), SIZE-01).

## 2. Which mechanism carries which load

| Load pattern | Mechanism | Owner of the details |
|---|---|---|
| Always loaded, tiny | root CLAUDE.md | [claude-md-official-guidance-and-limits.md](claude-md-official-guidance-and-limits.md) section 3 |
| Just in time by location | subdirectory CLAUDE.md | [memory-hierarchy-imports-and-rules.md](memory-hierarchy-imports-and-rules.md) section 1 |
| Just in time by file type | `.claude/rules/` with `paths` | memory-hierarchy-imports-and-rules.md section 3 |
| Just in time by task | skills (only name and description are always present) | [agent-skills-spec-and-progressive-disclosure.md](agent-skills-spec-and-progressive-disclosure.md) section 6 |
| Pointer instead of content | a path or command in place of pasted text (imports still load fully) | memory-hierarchy-imports-and-rules.md section 2 |
| Surviving compaction | durable rules in a file, not in chat | memory-hierarchy-imports-and-rules.md section 5 |
| Notes and clean windows | auto memory, subagents | memory-hierarchy-imports-and-rules.md section 4 |

## 3. Placement beyond the include/exclude list

What to include and exclude is owned by claude-md-official-guidance-and-limits.md section 2 (INC-01). Two placement points are added here:

1. Stale or one-off facts are deleted, not parked; maintainer notes go in block HTML comments, which cost no tokens (stripping rule: memory-hierarchy-imports-and-rules.md section 2).
2. An absolute rule placed in a hook or deny rule costs no context at all (the enforcement rule is ENF-01, same guidance file, section 4), so it also frees always-loaded space.

Derivable content (layouts, dependency lists, architecture summaries) is what the docs' `/doctor` check trims.

## 4. Ordering and prominence

- Structure with headers and bullets; dense paragraphs are harder to follow, and contradictions can be resolved arbitrarily, so state each rule once (docs).
- Idea from TechSpokes (unproven, no benchmarks): hard constraints first as a flat list, background last. Cheap and reasonable; treat it as a convention, not an official rule.
- Position and emphasis do not set priority: recency is owned by memory-hierarchy-imports-and-rules.md section 1 (PREC-01) and emphasis by the guidance file section 5 (EMP-01).

## 5. Anti-patterns

- Pasting the README into CLAUDE.md or importing it wholesale.
- Rules phrased as vague virtue ("write clean code").
- Telling the model to keep going, loop, or not be lazy: the docs say this tends to cause over-work on current models.
- The same rule in CLAUDE.md, a rules file and a skill: one owner per rule (method: `ssot-and-dry`; registry of this pack: [rule-registry.md](rule-registry.md)).

Example of the cheap pointer pattern:

```markdown
# Verify
- Typecheck: pnpm tsc --noEmit
- Release procedure: use the /release skill
- API rules: see .claude/rules/api.md (loads automatically)
```

## How an agent should apply this

- Before adding a line to an always-loaded file, ask: is it needed on every task, and not derivable from the code? If not, place it by the table in section 2.
- Replace pasted content with a path or command.
- Write one statement per rule, grouped under headers, hard constraints first.
- Defer theory to `agent-skills-context-engineering` and cost or effort decisions to `model-effort-routing`.
