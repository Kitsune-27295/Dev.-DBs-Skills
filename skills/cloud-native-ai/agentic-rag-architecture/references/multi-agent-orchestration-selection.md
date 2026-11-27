# Multi-Agent Orchestration: Selection and Safeguards

Sources: https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns · Last verified 2026-11-27

## Contents
- When to leave one agent
- The five patterns: use / avoid
- Comparison table
- Cross-cutting concerns
- How an agent should apply this

## When to leave one agent
The ladder itself (direct call, single agent, multi-agent) is in `SKILL.md` section 2. Microsoft names three reasons that justify multi-agent: a single agent cannot reliably handle the task because of prompt complexity, tool overload or security requirements. The benefits it lists are specialization, maintainability, per-agent model choice and parallel work; the costs are coordination overhead, latency and failure modes. Page dated 2026-02-12, updated 2026-09-21.

## The five patterns
**Sequential** (pipeline, prompt chaining): fixed linear order, next agent chosen by the workflow, not the agent.
- Use: clear stage dependencies, draft-review-polish, transformation pipelines.
- Avoid: parallelizable stages, few stages one agent can do, need for backtracking or dynamic routing, or early failures that cannot be stopped from poisoning later steps.

**Concurrent** (fan-out/fan-in, scatter-gather): agents analyse the same input independently. Aggregation strategies: vote or majority for classification, weighted merge for scores, LLM synthesis to reconcile narratives.
- Use: independent perspectives, ensembles, quorum, latency-sensitive work.
- Avoid: agents must build on each other, quota limits, unsafe shared-state writes, no conflict-resolution rule, aggregation that lowers quality.

**Group chat** (roundtable, council): shared thread managed by a chat manager; agents typically read-only. Maker-checker is the formal turn-based case (maker proposes, checker applies explicit criteria, loop to approval or iteration cap; fallback = human escalation or quality warning).
- Use: consensus, validation, compliance review, human-in-the-loop with an auditable thread.
- Avoid: simple delegation, real-time needs, manager cannot objectively tell when done. Keep to about three agents or fewer.

**Handoff** (triage, routing, transfer): one active agent at a time, full control transfers.
- Use: the right specialist emerges mid-task; signals for "capability limit reached" can be predetermined.
- Avoid: the right agent is obvious from the input (use a plain dispatcher), rule-based routing, bad routing is costly to the user, bounce loops are hard to prevent.

**Magentic** (task-ledger, adaptive planning): a manager builds and revises a ledger of goals and subgoals while specialized agents use tools to change external systems; yields a reviewable plan and audit trail.
- Use: open-ended problems with no known path, plan wanted for human approval (the page's example is automated incident remediation by an SRE manager agent).
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
- **Security:** least privilege per agent; security trimming must run in every agent, because agents need broad store access but must not return data the user cannot see; apply content guardrails at input, tool calls, tool responses and output.
- Code-defined agents (SDK) give deterministic routing control; no-code platforms may not.
- Pitfalls the page lists: a complex pattern where sequential or concurrent would do, agents without real specialization, hidden multi-hop latency, mutable state shared by concurrent agents, and context windows that grow with every hop.

## How an agent should apply this
- Walk the ladder from the bottom and record why each step up is needed (prompt complexity, tool overload, security boundary).
- Choose by control flow: fixed order = sequential, same input many views = concurrent, quality gate = maker-checker, unknown specialist = handoff, no known plan = magentic.
- Always set iteration caps, a stop criterion and an escalation path.
- Validate each agent's output before it becomes the next one's input.
- Pass summaries, not transcripts, across agent boundaries.
