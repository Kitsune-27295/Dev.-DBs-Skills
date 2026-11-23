# Workflow vs Agent Patterns

Sources: https://www.anthropic.com/research/building-effective-agents · https://resources.anthropic.com/hubfs/Building%20Effective%20AI%20Agents-%20Architecture%20Patterns%20and%20Implementation%20Frameworks.pdf · Last verified 2026-11-23

## Definitions
- **Workflow**: LLMs and tools orchestrated through code paths fixed in advance. Control flow lives in your code.
- **Agent**: the LLM decides its own process and tool use in a loop and keeps control over how the task gets done. Control flow lives in the model.
- Both are "agentic systems". The question is never "agent or not" but "how much control do I hand the model".
- Building block under all of them: the **augmented LLM** (one model with retrieval, tools, memory, able to write its own queries and choose tools).

## The ladder (Anthropic, Dec 2024), cheapest first
| Pattern | Shape | Use when | Avoid when |
|---|---|---|---|
| Single call (+ retrieval, examples) | one prompt | usually enough; optimise this first | task needs fixed multi-step accuracy |
| Prompt chaining | A -> gate -> B -> C | task splits cleanly into fixed subtasks; trade latency for accuracy | only 2-3 trivial stages a single call handles; backtracking needed |
| Routing | classify -> specialised prompt/tool/model | distinct categories, reliable classifier (LLM or classic) | categories blur; classification error is costly |
| Parallelization: sectioning | independent subtasks at once | speed; one concern per call (guardrail beside answer) | subtasks depend on each other |
| Parallelization: voting | same task N times | need confidence (vuln review, moderation thresholds) | no way to aggregate |
| Orchestrator-workers | LLM plans subtasks at runtime, delegates, synthesises | subtasks unpredictable (multi-file code change, multi-source research) | subtasks known upfront (use chaining/sectioning) |
| Evaluator-optimizer | generate -> critique -> revise loop | explicit criteria AND revision demonstrably helps | criteria subjective; first draft already good; real-time |
| Autonomous agent | plan-act-observe loop with ground truth from tools | open-ended, unknown step count, trusted/sandboxed environment | strict audit, tight cost/latency, one-shot perfection required |

Key distinction: orchestrator-workers resembles parallelization but the subtasks are decided at runtime, not predefined.

## Agent loop mechanics
1. Human gives a command or discusses the goal.
2. Agent plans, acts with a tool, reads real results (tool output, test run) as "ground truth".
3. Repeat until done, blocked, or a stop condition fires (iteration cap, checkpoint for human input).
Costs: higher cost, compounding errors; mitigate with sandbox testing and guardrails.

## Anthropic's three principles
1. Keep the design simple. 2. Make planning steps visible. 3. Invest in the agent-computer interface (tool docs, examples, poka-yoke arguments; e.g. requiring absolute paths removed a class of errors).
Frameworks: start with raw API calls; hidden abstraction obscures prompts and invites needless complexity.

## Enterprise guide additions (Anthropic PDF)
- Single agents suit open-ended problems with unknown step count; they are weaker when you need first-try perfection every time, but try adding Skills to one agent before going multi-agent.
- Multi-agent: Anthropic's internal research is quoted as 90.2% better than single-agent on tasks with several independent directions; the same guide says multi-agent uses roughly 10-15x the tokens (vendor figures, not independently verified). Reserve it for high-value work.
- Centralised (supervisor/orchestrator/router) vs decentralised (swarm, group chat, blackboard, event-driven). Subagents are treated as tools by a supervisor. Decentralised gives emergent, less predictable behaviour.
- Sequential workflows: audit trail, deterministic; avoid when iteration or backtracking is required. Parallel: avoid when agents write shared state.
- Hybrids: supervisor + parallel specialists; sequential with dynamic routing; single agent that escalates to multi-agent on edge cases (cost-optimal).
- Dynamic runtime agent creation: described as experimental, no production use known at the time.

## Control questions from the PDF (mapping to pattern)
- High control (regulated, financial, safety) -> single agent or sequential workflow. Moderate -> hierarchical. Low (research, brainstorming) -> collaborative.
- Single domain -> one agent; multi-domain but predictable -> sequential/parallel workflow; open-ended -> multi-agent.

## Failure modes
- Over-building: an orchestrator for a task a chain handles.
- Evaluator with vague criteria ("make it better") yields random edits.
- Agent without iteration cap or sandbox; compounding errors.
- Framework magic hiding the real prompts.

## How an agent should apply this
- Start at the bottom: optimise one call (retrieval, examples) before adding structure.
- If steps are known, write a workflow; if only categories are known, route; if only the goal is known, use an agent with caps.
- Parallelise only independent work; never parallel writers on shared state.
- Add an evaluator only with checkable criteria and a hard round limit.
- Escalate a rung only on measured evidence (eval failures), not intuition.
- Make tool definitions as carefully as prompts; test them with varied inputs.
