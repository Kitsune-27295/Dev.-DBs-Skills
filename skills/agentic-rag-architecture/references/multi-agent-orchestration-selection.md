# Multi-Agent Orchestration: Selection and Safeguards

Sources: https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns · Last verified 2026-11-23

## Contents
- Complexity ladder
- The five patterns: use / avoid
- Comparison table
- Cross-cutting concerns
- How an agent should apply this

## Complexity ladder
Use the lowest level that reliably works: (1) direct model call (classification, summarisation, translation: if prompting solves it, no agent); (2) single agent with tools, often the right enterprise default, easier to debug, set iteration limits against infinite tool loops; (3) multiagent orchestration, justified only when one agent fails due to prompt complexity, tool overload, or separate security boundaries. Multi-agent buys specialisation, scalability, maintainability and per-agent model choice, but adds coordination overhead, latency and failure modes.

## The five patterns
**Sequential** (pipeline, prompt chaining): fixed linear order, next agent chosen by the workflow, not the agent.
- Use: clear stage dependencies, draft-review-polish, transformation pipelines.
- Avoid: parallelisable stages, few stages one agent can do, need for backtracking or dynamic routing, or early failures that cannot be stopped from poisoning later steps.

**Concurrent** (fan-out/fan-in, scatter-gather): agents analyse the same input independently. Aggregation strategies: vote or majority for classification, weighted merge for scores, LLM synthesis to reconcile narratives.
- Use: independent perspectives, ensembles, quorum, latency-sensitive work.
- Avoid: agents must build on each other, quota limits, unsafe shared-state writes, no conflict-resolution rule, aggregation that lowers quality.

**Group chat** (roundtable, council): shared thread managed by a chat manager; agents typically read-only. Maker-checker is the formal turn-based case (maker proposes, checker applies explicit criteria, loop to approval or iteration cap; fallback = human escalation or quality warning).
- Use: consensus, validation, compliance review, human-in-the-loop with an auditable thread.
- Avoid: simple delegation, real-time needs, manager cannot objectively tell when done. Keep to about three agents or fewer.

**Handoff** (triage, routing, transfer): one active agent at a time, full control transfers.
- Use: the right specialist emerges mid-task; signals for "capability limit reached" can be predetermined.
- Avoid: the right agent is obvious from the input (use a plain dispatcher), rule-based routing, bad routing is costly to the user, bounce loops are hard to prevent.

**Magentic** (task-ledger, adaptive planning): a manager builds and revises a ledger of goals and subgoals while specialised agents use tools to change external systems; yields a reviewable plan and audit trail.
- Use: open-ended problems with no known path, plan wanted for human approval (example: low-risk SRE incident remediation).
- Avoid: deterministic paths, no ledger needed, time-sensitive work, likely stalls.

## Comparison
| Pattern | Routing | Main risk |
|---|---|---|
| Sequential | fixed | early error propagates |
| Concurrent | fixed or dynamic selection | contradictory results, resource cost |
| Group chat | manager sets turns | conversation loops |
| Handoff | agents decide | infinite handoff, unpredictable paths |
| Magentic | manager reorders tasks | slow convergence, stalls |

## Cross-cutting concerns
- **Context:** each hop adds reasoning and tool output. Decide per hop between raw context, compacted summary, or a fresh instruction only. Compact between agents.
- **State:** for long or multi-interaction work persist progress, intermediate results and history in a durable store, scoped to the minimum (token cost, privacy).
- **Reliability:** timeouts and retries, graceful degradation, surface errors rather than hide them, validate output before passing it on, circuit breakers, isolate compute and watch shared endpoint rate limits.
- Code-defined agents (SDK) give deterministic routing control; no-code platforms may not.

## How an agent should apply this
- Walk the ladder from the bottom and record why each step up is needed (prompt size, tool count, security boundary).
- Choose by control flow: fixed order = sequential, same input many views = concurrent, quality gate = maker-checker, unknown specialist = handoff, no known plan = magentic.
- Always set iteration caps, a stop criterion and an escalation path.
- Validate each agent's output before it becomes the next one's input.
- Pass summaries, not transcripts, across agent boundaries.
