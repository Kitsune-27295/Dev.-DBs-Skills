# Multi-Agent Topologies and Failure Modes

Sources: https://thinking.inc/en/blue-ocean/agentic/agent-orchestration-patterns/ · https://resources.anthropic.com/hubfs/Building%20Effective%20AI%20Agents-%20Architecture%20Patterns%20and%20Implementation%20Frameworks.pdf · https://github.com/machinedge/building-effective-agents/blob/main/building-effective-agents.md · Last verified 2026-11-23

thinking.inc is a consultancy blog whose figures come from its own engagements: treat every percentage as a **claim**. The Anthropic enterprise PDF (https://resources.anthropic.com/building-effective-ai-agents is only its gated landing page, which lists topics but no guidance) is the primary source for topology definitions.

## Six topologies (thinking.inc)
| Topology | Control | Best for | Characteristic failure |
|---|---|---|---|
| Supervisor | one planner delegates, checks, replans | judgment-based decomposition, varying plans | passive supervisor (adds cost only); micromanaging supervisor (over-decomposes) |
| Sequential pipeline | fixed order, typed handoffs | linear, high-volume, inspectable stages | leaky pipeline (context bloats); rigid pipeline (no input validation) |
| Fan-out / fan-in | dispatcher, parallel specialists, synthesiser | breadth research, multiple perspectives | unbalanced fan-out (slowest stalls); synthesis without criteria |
| Router | classifier forwards | diverse inputs, cost tiering | overthinking router; binary router |
| Hierarchical | tree, 2-3 levels | 8+ specialists, long-running | >3 levels loses information; hollow middle layer |
| Evaluator-optimizer | generate, score, revise | quality-critical, scorable work | infinite loop; vague evaluator |
Hybrids it calls common: router + pipeline (most common enterprise), supervisor + fan-out, pipeline + evaluator, hierarchical + router.

## Mechanics worth copying
- Strict schemas between stages; a shared state object each stage reads/writes its own section of, so restart from any stage works.
- Synthesis by template (fixed sections to fill) beats open-ended "combine these" (claimed qualitative finding).
- Evaluator: 5-8 numeric dimensions, pass thresholds, concrete feedback naming the section and missing evidence, cap about 3 rounds, escalate to a human on cap.
- Supervisor prompt: specialist roster, explicit routing criteria, quality standards, escalation rules.
- Claimed ranges: fan-out 2-5x single-agent cost; evaluator loop 1.5-3x cost and latency; supervisor bottleneck above ~10 parallel agents; migration between patterns 1-2 engineer-weeks if contracts are JSON and agents loosely coupled.

## Decision table (thinking.inc, condensed)
Linear -> pipeline. Diverse inputs -> router first. Planning needed -> supervisor. Independent subtasks -> fan-out. Many capabilities -> hierarchical. Quality-critical -> evaluator. Cost-sensitive variable complexity -> router plus tiered specialists. Real-time -> router and single agent, supervisor only for hard queries. Batch -> any, pipelines and evaluators fit best. Audit needs -> pipeline or supervisor.

## Anthropic PDF cautions
- Context overflow in the orchestrator is the main supervisor risk: use context editing, external memory, summary-returning subagents.
- Collaborative/peer systems: communication cost and emergent, hard-to-predict behaviour; need frameworks for coordination and tracing of delegation patterns.
- Parallel agents must not mutate shared state concurrently.
- Scale effort to query: simple queries should not trigger the full multi-agent machinery.
- Peer-to-peer "swarm slightly outperforms supervisor" is an early benchmark quoted in the guide; treat as preliminary.

## machinedge role split (practitioner synthesis, "not a standard")
Assistant, Analyst, Tasker, Orchestrator (most over-built), Guardian (separate from what it checks). Heuristic: a system prompt over ~500 words spanning several roles should be split.

## Disagreements
Anthropic's PDF: multi-agent far ahead on parallel-direction tasks; machinedge: orchestrators are often over-engineered. Resolve by task shape: breadth with independent directions favours multi-agent; coupled sequential work (e.g. one codebase) favours one agent (inference).

## How an agent should apply this
- Pick topology from the task shape, not from sophistication; default to pipeline or router.
- Define typed handoff schemas and a shared state object before adding agents.
- Give every evaluator a rubric and a round cap; give every fan-out a timeout and a synthesis template.
- Keep delegation depth at two levels unless evidence says otherwise.
- Trace routing, handoffs and coordination overhead from day one.
- Do not let parallel workers write the same files or records.
