# Skill Admission, Contract Checklist and Baseline-First Authoring

Sources: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices · https://github.com/anthropics/skills (skills/skill-creator) · https://github.com/obra/superpowers (MIT, writing-skills) · Last verified 2026-11-24

## Contents
- Admission questions
- Skill-contract checklist
- Baseline-first method
- Evals and description tuning
- How an agent should apply this

## Admission questions
A skill's description is resident in every session; its body costs tokens when loaded. Before writing, answer five questions. These are this skill's synthesis, grounded in the best-practices guide ("only add context Claude doesn't already have"; build evaluations before extensive documentation).

1. **Which task fails without it?** Name it and show the failure (see baseline below). "Would be nice" is a no.
2. **What do existing instructions already cover?** If a project file, rule or existing skill does about 80%, extend it; extension adds no new resident description.
3. **Is the trigger evaluable?** Write three phrases that should fire it and one that should not. If you cannot, it is a note, not a skill.
4. **Is it product-specific?** Product procedures belong in that product's docs or instruction file; skills should be reusable across tasks.
5. **What is the resident cost?** Count the description's tokens times the sessions that carry it. A broad description that steals routing from a neighbor costs more than a missing skill.

Choose the kind by who decides: a path-scoped standard is a rule; a stepwise procedure triggered by a request is a skill; isolated-context work returning a summary is a subagent; something that must fire on a tool event deterministically is a hook (enforced, not advisory). Delete a capability no task needs.

## Skill-contract checklist
Review a skill as an execution contract, tracing how an agent enters, loads, delegates and verifies (a lens adapted from third-party review practice; ideas only).

| Stage | Ask |
|---|---|
| **Input** | Does the description say what it does and when, in third person, with task keywords? Are required inputs and assumptions (installed tools, network) stated? |
| **Loading** | Is the body the workflow only, with variants one hop away in named references? Is it under the line limit? (limits owned by `skill-orchestrator` and the spec) |
| **Delegation** | Is each subagent justified by scope or context isolation, with model and effort chosen per call (`model-effort-routing`)? Does the lead own the final result? |
| **Validation** | Is there a check on the same surface the skill claims (script, test, rubric)? Is a missing check reported as unverified? |

Findings rank: invalid or missing resources (an agent can follow and fail) first; wasted context or duplicated ownership next; style last.

## Baseline-first method
The best-practices guide prescribes evaluation-driven development: run the task without the skill and note specific failures, write three scenarios for those gaps, measure the baseline, write minimal instructions, iterate against the baseline. The MIT-licensed `writing-skills` skill in the superpowers plugin frames the same idea as test-driven development for documentation (credit: Jesse Vincent; method restated here in new words):

1. **RED:** run pressure scenarios with no skill; record exactly how the agent fails or rationalizes.
2. **GREEN:** write the smallest skill that closes those gaps; rerun and confirm compliance.
3. **REFACTOR:** pressure-test with new loopholes (time pressure, conflicting goals); plug each and rerun.

Do not create a skill for what automation can enforce (a validator beats prose) or for one-off solutions.

## Evals and description tuning
The `skill-creator` skill in the public Anthropic skills repository (checked present on 2026-11-24, with `agents`, `scripts`, `eval-viewer`, `references`) runs each test prompt twice in the same turn, with the skill and against a baseline (no skill for a new skill, a snapshot of the old version when improving), then compares and iterates. It also has a separate description-optimization step because skills tend to undertrigger. Treat its details as upstream behavior; read them there.

## How an agent should apply this
- Run the five admission questions first; stop at the first honest "no".
- Capture the baseline failure before writing; keep the skill to those gaps.
- Walk the four contract stages and report findings by severity.
- For an edit to an existing skill, compare against a snapshot of the old version.
- Test with the models you will actually route to (the guide suggests Haiku, Sonnet and Opus).
