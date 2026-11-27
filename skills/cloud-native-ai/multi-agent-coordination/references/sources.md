# Sources: Multi-Agent Coordination

Every URL below was re-fetched during the 2026-11-27 rebuild (WebFetch; Firecrawl was unavailable). Earlier authoring pass: 2026-11-24.

| Source | Retrieved status | What it contributed |
|---|---|---|
| [Anthropic, How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) | 200 OK (summarizing fetch tool) | Orchestrator-worker design, effort-scaling rules, failure modes (50 workers for simple queries, endless searching, continuing after enough results), reported 90.2% / 4x / 15x / 80% / up-to-90% figures, plan saved outside context, resume from checkpoints, end-state evaluation, judge rubric, references instead of copies, where multi-agent does not fit |
| [Anthropic, Building effective agents](https://www.anthropic.com/research/building-effective-agents) | 200 OK, dated 2024-12-19 (summarizing fetch tool) | Start-simple advice, stopping conditions, human checkpoints; pattern menu is owned by `model-effort-routing` |
| [Claude Code, Subagents](https://code.claude.com/docs/en/sub-agents) | 200 OK; page is 114,792 characters, the first 100,000 were read, the last 14,792 were not | Own context and delegation message, helper versus main conversation, default nesting of three layers, 20 concurrent subagents, background default, worktree isolation, resume by message, only the summary returns |
| [Claude Code, Agent teams](https://code.claude.com/docs/en/agent-teams) | 200 OK (full text). Page says teams are experimental and disabled by default | Lead, teammates, task list and mailbox, three task states, file-locked claiming, no inherited history, no consent by message, 3 to 5 teammates, 5 to 6 tasks each, file-ownership advice, competing hypotheses, limitations, five-minute cache default |
| [Cognition, Don't build multi-agents](https://cognition.com/blog/dont-build-multi-agents) | 200 OK, dated 2025-06-12 (the earlier cognition.ai address redirected; not re-tested) | Two principles (share full traces; actions carry implicit decisions), failed split example, single-threaded default, compression step |
| [LangChain docs, Multi-agent](https://docs.langchain.com/oss/python/langchain/multi-agent) | 200 OK (summarizing fetch tool) | Patterns (subagents, handoffs, skills, router, custom workflow), when multi-agent helps, one call-count comparison |
| [LangGraph, multi-agent concepts](https://langchain-ai.github.io/langgraph/concepts/multi_agent/) | Returned only a "Redirecting..." stub again; not read | Nothing adopted |
| Third-party skill family for running a group of agents with a board, monitor, narrator and pane summary | Read locally for ideas, no text reused; license not visible | Ideas only: coordinator does not do the work, numbered board with addressing, one nudge to one member, public briefs, ownership before launch |
| Third-party MIT plugin skills for subagent-driven development and parallel dispatch | Read locally for ideas, no text reused; MIT license file visible | Ideas only: fresh member per task, independent review, fix-round caps, ledger of rulings |

## Reading limits

- Anthropic and LangChain pages were summarized by the fetch tool; re-open the original before using a number in a decision record.
- The last 14,792 characters of the subagents page were not read.
- The board format, role table, monitor procedure, ruling format and shutdown protocol are this skill's own design, not published standards.
- No scripts or data files in this skill; none were run.

## Claims not adopted as fact

- "About 15x tokens", "90.2% better" and the 80% variance figure are vendor figures for a research workload and one benchmark; reported as claims, never as general laws.
- Thresholds (3 to 5 members, one verifier per 2 to 4 workers, a monitor tick of a few minutes, about three alerts) are heuristics from product docs or idea sources.
- Cognition's statement about subagent tooling describes mid-2025 and is contradicted by current Claude Code docs.
- Agent-team behavior is a snapshot of an experimental feature and may change.
- Anthropic's remark that most coding tasks have fewer parallelizable parts is a qualitative claim, not measured here.
