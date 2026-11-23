# Delegation Brief Templates

Sources: https://github.com/masskrdjn/claudeskills (quota-orchestrator SKILL.md) · https://github.com/vishalsachdev/claude-skills (allocate-agent-models/SKILL.md) · https://github.com/softspark/ai-toolkit/blob/main/app/skills/model-routing-patterns/SKILL.md · https://github.com/DeL-TaiseiOzaki/claude-code-orchestra/blob/main/.claude/skills/team-execute/SKILL.md · https://github.com/skills-directory/skill-codex (plugins/skill-codex/skills/codex/SKILL.md) · https://github.com/Getty/skills/blob/main/claude/model-routing/SKILL.md · Last verified 2026-11-23

A routing decision is only as good as the brief the cheaper worker receives. Below are the elements these repos require, merged into reusable shapes. The templates are my synthesis; each element is attributed to its origin.

## 1. What every brief must contain

Union of the lists from masskrdjn, Vishal and softspark:

| Element | Origin | Why |
|---|---|---|
| Objective and acceptance criteria (the user's, not the delegator's paraphrase) | masskrdjn, Vishal | Worker cannot close decisions it cannot see |
| Scope: files, ownership set, permissions, what must not be touched | masskrdjn, orchestra, Vishal | Prevents overwrite and authority creep |
| Established facts with source or evidence excerpt | masskrdjn | Avoids re-discovery |
| Hypotheses, unknowns and the open question, kept apart from facts | masskrdjn | A business assumption stays an assumption |
| Commands already run and results, file and environment state | masskrdjn | Do not repeat unchanged environment discovery |
| Expected output form and limits of the mission | masskrdjn | Proportionate answer, no ceremonial report |
| Failure or uncertainty path ("if unsure, report back, never guess") | Getty | Cheap lane must surface doubt upward |
| Evidence required for completion (quoted verify output, exit code) | orchestra, Vishal | Self-report is not acceptance |
| Retry and loop bounds | masskrdjn | Stops runaway cost |

Each child starts from clean context, so the message must stand alone; do not forward the whole history for a mechanical task (masskrdjn). The advisor envelope target is about 60 lines, with decisive evidence never cut to fit.

## 2. Template: worker (builder / implementer)

```
Task: <one bounded assignment>
Goal and acceptance: <user's criteria, verbatim where possible>
Owns: <paths>   Must not touch: <paths>
Facts (sourced): ...
Unknowns / assumptions (do not treat as facts): ...
Already verified: <commands, results, env state>
Limits: <3 attempts; same error twice = stop and report>
Done when: <verify command run, exit code quoted>
If the work shows <ambiguity / cross-module invariant / security-concurrency risk>:
  stop, report the concrete evidence, do not push on.
Report first line: name | model_requested | effort_requested
```

Elements: orchestra's rules (ownership, run the verify script, quote the overall result, stop and report on escalation conditions) and masskrdjn's header line. The header is declarative and project-specific, not proof of the executing model; the worker should state an effective model or effort only with runtime metadata and its provenance.

## 3. Template: verifier / reviewer

```
Review inputs: requirements + the change + raw evidence (logs, diff).
Do NOT include: the implementer's conclusions or confidence.
Fresh session. Read-only unless told otherwise.
Output: findings with location and evidence; pass/fail with the checks that were
actually executed; unknowns listed, not smoothed over.
```

Vishal: independent, fresh, requirements plus raw evidence, risk-appropriate tier even if implementation was cheap. orchestra: reviewers on one tier by default, specialized perspectives (security, quality, tests) in parallel, lead synthesizes; a clean review of an empty change list is meaningless, so check that the diff scope is non-empty before spawning reviewers.

## 4. Template: advisor (expensive, read-only)

```
Question: <open, with alternatives>
Context envelope (~60 lines): goal, acceptance, excerpts, facts, assumptions,
unknowns, results so far. No full logs.
Constraints: no execution, no writes, no delegation; you may reject the framing.
Deliver: a decision with conditions, interfaces or invariants, alternatives and
risks, measurements still needed (~80 lines if sufficient; no patch).
```

From masskrdjn: the advisor handles only conceptual or architectural arbitration, never exploration, tests, logs, retries, mechanical edits, environment problems or the user's intent. The root runs any missing measurements and reconsults only if they change the decision. The synthesis keeps the expert's reservations; new root decisions are marked as the root's own.

## 5. Template: worker announcement (before launch)

Vishal's seven-line record, useful as an audit trail:

```
Task / Evidence (evaluated class or new) / Allocation (model ID, effort) /
Basis (policy factor or measured eval) / Safety floor / Fallback / Authority
```

Afterwards record environment failures separately from substantive ones and whether fresh independent verification passed.

## 6. Delegating to an external CLI worker (Codex example)

skill-codex (OpenAI Codex CLI, so only structurally relevant to Claude routing): asks the user once for model AND reasoning effort in a single prompt (default top model at `high`); picks the least privileged sandbox (`read-only` by default, escalate only for edits or network); asks before high-impact flags; stderr suppressed to hide thinking tokens; stdin must be explicitly closed or the process hangs with no output; no intermediate output, so run synchronously or set timeout by effort; resumed sessions inherit model, effort and sandbox and must not get config flags unless the user asked. Treat the external model "as a colleague, not an authority": verify its claims, especially model names, library versions and API changes, since its knowledge cutoff differs. softspark adds for the Claude Code supervisor: pass task, working directory, owned paths, evidence, acceptance criteria and verification commands; request read-only explicitly for audits; a background job ID is not completion; empty output or failed startup is a failure to resolve, not success; inspect partial changes before redispatching a failed write; the forwarding wrapper only forwards.

## Disagreement

masskrdjn forbids a delegated child from re-triaging or re-delegating (root-only skill), while orchestra's team design lets teammates message one another about interface changes. Both keep lead synthesis and verification with the coordinator.

## How an agent should apply this

- Write a standalone brief with objective, acceptance, scope, sourced facts, separated unknowns and an exit condition; never forward the full history.
- Give the worker an explicit "stop and report" path and loop bounds.
- Brief reviewers with evidence only, never the implementer's conclusions.
- Require quoted verification output as the completion proof, and re-run key checks yourself.
- Keep expensive advisors read-only, budgeted, and fed a compact envelope.
