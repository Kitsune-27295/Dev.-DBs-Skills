# Sources — Multi-Agent Coordination

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [Anthropic — How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) | 200 OK (read through a page-to-markdown fetch tool that returns a model-written extract, not raw text) | Orchestrator-worker design, delegation-brief needs, effort-scaling rules, observed failure modes, reported token multipliers, external plan memory, checkpoint resumption, evaluation advice, when multi-agent does not fit |
| [Anthropic — Building effective agents](https://www.anthropic.com/research/building-effective-agents) | 200 OK (same extract caveat) | Workflow patterns (chaining, routing, sectioning, voting, orchestrator-workers, evaluator-optimizer), start-simple advice, stopping conditions, human checkpoints, ground truth at each step |
| [Claude Code — Subagents](https://code.claude.com/docs/en/sub-agents) | 200 OK; the page is about 115k characters and only the first 100k were read, the last 15k were not | Subagent isolation and context, when to use a helper versus the main conversation, foreground and background, worktree isolation, depth limit, resume, scanning of returned results |
| [Claude Code — Agent teams](https://code.claude.com/docs/en/agent-teams) | 200 OK (read in full as raw markdown) | Lead, teammates, task list and mailbox, task states and claiming, no inherited history, no consent by message, team sizing, file-ownership advice, competing-hypotheses pattern, limitations and cost notes. Page marks the feature experimental |
| [Cognition — Don't build multi-agents](https://cognition.ai/blog/dont-build-multi-agents) | 301 to https://cognition.com/blog/dont-build-multi-agents; canonical URL returned 200 OK | Principles "share context" and "actions carry implicit decisions", failure modes of parallel workers, single-threaded default. Dated mid-2025 |
| [LangGraph — multi-agent concepts](https://langchain-ai.github.io/langgraph/concepts/multi_agent/) | Returned only a "Redirecting..." stub; not read | Nothing adopted from this URL |
| [LangChain docs — Multi-agent](https://docs.langchain.com/oss/python/langchain/multi-agent) | 200 OK (extract caveat) | Pattern vocabulary (subagents, handoffs, skills, router), when multi-agent helps, one illustrative call-count and token comparison |
| Third-party skill family for running a group of agents with a board, a stall monitor, a narrator and a pane summary (four skills) | Read locally for ideas, no text reused; license not visible | Ideas only: coordinator does not do the work, numbered board with addressing, one nudge to one member citing sequence numbers, no repeat alerts, dormancy, public briefs, ownership before launch |
| Third-party MIT plugin skills for subagent-driven development and dispatching parallel agents | Read locally for ideas, no text reused; MIT license file visible | Ideas only: fresh member per task, independent review after each task, fix-round caps with escalation, ledger of rulings, independence test before parallel dispatch |

## Reading limits

- Anthropic and LangChain pages were summarized by the fetch tool, so figures are quoted from those summaries; re-open the original before using a number in a decision record.
- The subagents page tail (about 15k characters) was not read.
- The LangGraph concepts URL was not readable; its content was not used.

## Claims not adopted as fact

- "About 15x tokens" and "90% better" are vendor figures for a research workload; reported as claims, never as general laws.
- Specific thresholds (3-5 members, one verifier per 2-4 workers, monitor tick of a few minutes, about three alerts) are heuristics from product docs or the local idea sources, labeled as such in the skill.
- Cognition's statement about the state of subagent tooling is dated to mid-2025 and may no longer hold.
- Anything about agent-team behavior is a snapshot of an experimental feature and may change.
