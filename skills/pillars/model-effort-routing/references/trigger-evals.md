# Trigger Evals (model-effort-routing)

Sources: this skill's description and boundaries; no external source · Last verified 2026-11-27

Prompts used to test the description. Expected skill in the right column; a prompt that routes elsewhere must not load this skill.

## Should trigger

| Prompt | Expected |
|---|---|
| "Which model and effort should a subagent get if it only greps the repo and counts usages of a function?" | `model-effort-routing` |
| "Our Opus reviews burn too many tokens. How do I cut spend without weakening the security review?" | `model-effort-routing` |
| "Should I turn on Code Mode to cut round trips, and does it change how my tool-call rules work?" | `model-effort-routing` (Code Mode reference); hook design goes to `git-guardrails-claude-code` |

## Near misses (belong to a neighbor)

| Prompt | Expected |
|---|---|
| "Add retries with a circuit breaker around our Claude API client." | `circuit-breaker-retry-telemetry` |
| "How should I chunk and rank documents so an agent retrieves the right passage?" | `agentic-rag-architecture` |
| "Which skills and instruction files should load for this task, and in what order?" | `skill-orchestrator` |

Run each prompt about three times per host; a pass is a trigger rate above 0.5 for the should-trigger rows and below it for the near misses.
