# When Multi-Agent Pays Off

Sources: https://www.anthropic.com/engineering/multi-agent-research-system · https://cognition.com/blog/dont-build-multi-agents · https://www.anthropic.com/research/building-effective-agents · https://docs.langchain.com/oss/python/langchain/multi-agent · https://code.claude.com/docs/en/sub-agents · https://code.claude.com/docs/en/agent-teams · Last verified 2026-11-24

## Two published positions, and why both can be right

**For multi-agent (Anthropic, research system).** A lead agent plans, saves its plan outside its context, and spawns parallel workers that search independently and return condensed findings; a final pass attributes sources. Reported results (vendor figures, internal evaluation): the multi-agent setup beat a single strong agent by about 90% on their research eval; agents use roughly 4x the tokens of chat and multi-agent systems roughly 15x; on a browsing benchmark token usage alone explained about 80% of the variance. Time on complex queries dropped by up to 90% through parallel tool use and parallel workers. The write-up also lists where it does **not** fit: tasks where all agents need the same context, tasks with many dependencies between agents, most coding work (few parallelizable parts), real-time coordination, and low-value tasks that cannot justify the cost.

**Against by default (Cognition, "Don't build multi-agents").** Two principles: share context (full traces, not just messages) and remember that actions carry implicit decisions. Parallel workers each make decisions on assumptions the others cannot see, so results conflict (the post's example: one worker builds a background in one visual style, another builds a character in a different one). Handing over only the original task is not enough, and agents cannot yet negotiate disagreements the way people resolve a merge conflict. Its default is one linear agent, with a dedicated compression step for very long tasks. Caveat: the post is dated mid-2025 and describes the subagent tooling of that time as narrow-question helpers; current product docs describe richer subagents and teams, so treat that part as a dated observation.

**Reconciliation (this skill's inference, not a source claim).** The two agree on the mechanism. Work that is **read-heavy, breadth-first and decomposable** (search, review lenses, independent hypotheses) tolerates parallel workers because outputs are summaries that a lead merges. Work that is **write-heavy with shared design decisions** (one feature across coupled files) does not, because every member's output embeds decisions the others must match. So: parallelize reading and independent writing; serialize or pre-decide shared decisions.

## Patterns, from simplest

| Pattern | Use when | Note |
|---|---|---|
| Single call / chain | Task decomposes into fixed steps | Cheapest; try first |
| Sectioning | Independent subtasks run concurrently (per file, per aspect) | Needs disjoint outputs |
| Voting | Same task several times for confidence (several review prompts) | Costs N times; needs an aggregation rule |
| Orchestrator-workers | Subtasks cannot be predicted in advance (multi-file change) | Coordinator decides slices at runtime |
| Evaluator-optimizer | Clear criteria and feedback that provably improves output | Cap the loop |
| Peer team with messaging | Members must share findings and challenge each other | Highest overhead; experimental in at least one product |

Anthropic's agent-design guidance adds: start with the simplest solution, add complexity only when it measurably helps, and be wary of frameworks that hide prompts. LangChain's pattern comparison (subagents, handoffs, skills, router) notes that a single agent with good tools is often enough, and that multi-agent helps mainly for context management, separately maintained components or parallel subtasks; in its example, subagents cost one extra call on a one-shot request but ran in parallel on multi-domain requests.

## Sizing rules reported by sources

- Anthropic embedded effort rules in prompts because early versions over-spawned (dozens of workers for simple queries): one worker with a handful of tool calls for a simple lookup; a few workers for a comparison; many only for broad research. Treat the exact figures as that system's, not yours.
- Claude Code team docs advise starting with three to five teammates, tasks sized to a self-contained deliverable (a function, a test file, a review), about five or six tasks per teammate, and starting with research and review before parallel implementation. They also state that same-file edits and sequential work favor one session or subagents.
- Delegated helpers (subagents) return a summary to the caller; many detailed reports can still fill the caller's context, so ask for verdicts, not transcripts. Nesting is bounded by default in that product (a few levels), which is a useful reminder to cap depth in any design.

## Anti-patterns

- Fan-out sized by enthusiasm instead of independent pieces.
- Splitting coupled work and hoping the members agree on interfaces.
- Using a team where a delegated helper returning a verdict would do.
- Treating the board as a chat room.

## How an agent should apply this

- Run the four gates in `SKILL.md` section 1 before spawning anything; record the answers in the plan.
- Classify the task read-heavy or write-heavy; for write-heavy, write the shared decisions first or stay single-threaded.
- Prefer the lightest pattern that fits: helper with verdict, then sectioning, then a team.
- Start with 3-5 members and add only when a named independent piece has no owner.
- Treat the 15x, 90% and similar figures as vendor claims for their workloads; measure your own run's tokens.
