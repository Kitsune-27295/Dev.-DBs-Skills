# Quota-Aware Subagent Orchestration (subagent-orchestrator)

Sources: https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/subagent-orchestrator/SKILL.md (read via raw.githubusercontent.com variant; the github.com blob URL 503'd in the page-fetch step for related pages) · https://github.com/sickn33/agentic-awesome-skills · Last verified 2026-11-23

The skill (community, v1.0.0, added 2026-05-21, tagged risk `critical`) is planning guidance only. It states it is not a scheduler, model router or quota monitor and enforces nothing.

## When it applies

Use for work spanning 3+ files/components, parallel agents, prior mid-task quota exhaustion, or plan+build combos. Skip for single-file edits, single bug fixes, scripts under ~50 lines, questions, plan-only requests.

## Six phases

1. Decompose: announce, then write a Mission Brief: goal, agent count, quota strategy (FLASH / SONNET / MIXED), expected cost (LOW/MEDIUM/HIGH), and per agent ID, role, exact scope, model, input, output, dependencies. Proceed without asking only if the user already authorized parallel work in that scope; new scope, cost or external writes need approval.
2. Quota routing: over 20 files or 500+ new lines: cheap tier for all agents, strong tier only for final review. Otherwise creative UI / complex logic / API design: mid tier builder, cheap for the rest. Else cheap everywhere.
3. Context isolation: each agent gets a packet (files to read, files to write, excluded files, only the relevant instruction-file section). Never the whole codebase; exclude lockfiles/build output unless needed.
4. Parallel execution in rounds: independent agents first, dependents next, integration last. Between rounds collect outputs and spot-check scope adherence, import/export conflicts, leftover TODO placeholders; re-run only the failing agent.
5. Error recovery: never re-run the whole mission; one cheap repair agent scoped to the broken files with the error as context; validate before continuing.
6. Integration check: imports resolve, no duplicate names, no hardcoded env values, no stray debug logs, consistent types; run real build/tests and distinguish inspection from execution.

## Tier rules (as the skill states them)

| Tier | Rule |
|---|---|
| Top reasoning model (Opus) | never in subagents |
| Mid (Sonnet) | at most one subagent per mission |
| Cheap (Flash) | default for all subagents |
| Browser subagent | at most one per mission; do not assume a separate quota pool |

Quota-impact estimates per event: spawn/indexing LOW; file IO and terminal MEDIUM; browser HIGH; thinking mode VERY HIGH. Near the verified limit: pause and ask, shift remaining agents to cheap tier, drop avoidable browser work (not required validation).

## Guardrails worth copying

- Partition write ownership; use isolated worktrees when needed.
- Integration checks bind to the real combined diff; spot checks do not prove correctness.
- Read-only reviewers must not repair files unless reassigned.
- Percentages in examples are illustrative, never report them as measured.
- Use only host-exposed delegation tools and user-authorized models; model availability, cost and quota separation are not established by the doc.
- Do not auto-alter global agent setup.

## Trade-offs and failure modes

- "Never Opus in subagents" is a quota policy for Antigravity-style shared pools, not a universal quality rule; on Claude Code the right tier depends on judgment weight (inference).
- Spot checks of three items are cheap but shallow; they catch placeholders, not logic faults.
- Fan-out multiplies context cost; packets must be tight or the saving disappears (inference).

Example brief (own sketch):
```
goal: add export endpoint + UI button
agents: A(api, flash, writes api/*), B(ui, sonnet, writes ui/*), C(review, read-only)
round1: A,B  round2: C  integration: run tests
```

## How an agent should apply this

- Write the brief first and show it; get approval before spawning beyond authorized scope.
- Default subagents to the cheapest tier; escalate one agent only for design-heavy work.
- Give each agent a file-scoped packet and unique write ownership.
- Gate each round with checks; repair narrowly, never restart.
- State clearly which checks were executed versus inspected.
