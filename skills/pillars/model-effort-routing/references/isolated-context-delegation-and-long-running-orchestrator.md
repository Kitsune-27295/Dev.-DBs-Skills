# Isolated-Context Delegation, Two-Stage Review and the Long-Running Orchestrator

Sources: https://www.anthropic.com/engineering/multi-agent-research-system · https://code.claude.com/docs/en/sub-agents · https://www.anthropic.com/engineering/building-effective-agents · Last verified 2026-11-27

Three ideas about running delegated work, each tied to a tier choice. Idea origins: third-party skills read for ideas, no text reused (two MIT-licensed plugin skills on subagent development and parallel dispatch, and an MIT skill for a long-running coordinator); the public pages above were used to verify the underlying claims. Topology, depth and failure modes stay in [multi-agent-topology-and-failure-modes.md](multi-agent-topology-and-failure-modes.md); the pack's multi-agent coordination skill owns coordination protocols; brief templates stay in [delegation-brief-templates.md](delegation-brief-templates.md).

## 1. One isolated context per task

The public subagents docs state that a subagent starts fresh: it sees neither the conversation nor files already read, and only its final summary returns. Anthropic's research-system post adds that vague short briefs caused duplicated work, and that each subagent needs an objective, an output format, tool and source guidance and task boundaries. Consequence for routing: the brief is the whole input, so size the model to the task as the brief frames it, not to the session's history. Build the brief from what the task needs, not by forwarding the session. Use the main conversation instead when work needs back-and-forth or shares a lot of context (docs guidance).

## 2. Independent failures versus shared state

Before launching parallel agents, test the split.

| Question | Yes | No |
| --- | --- | --- |
| Does each problem make sense without the others' findings? | Parallel candidate | Single agent |
| Could fixing one cause fix another (shared root cause)? | Single agent | Parallel candidate |
| Would two agents edit the same files or state? | Sequence them | Parallel candidate |

Name the domains first, give each agent its own scope, then reconcile and run the full check at the end. The research post notes agents are weak at real-time coordination and that tightly shared-context work is a poor fit, and "Building effective agents" says to add complexity only when it measurably helps.

## 3. Two-stage review, then a ledger

Review each delegated result in two passes with separate questions: first spec compliance (did it do what was asked, nothing more, nothing less), then quality (correctness, clarity, tests). Passing stage one is a precondition for stage two, so effort is not wasted polishing the wrong thing. Tier: the reviewer is an analysis-weight job, so give it the stronger tier from the work-weight table; the implementer keeps the build tier. After repeated failed fix rounds, replace the implementer with a more capable tier instead of resuming the same one (an idea from the source skill; its round counts are its author's choice, not a standard).

Keep a ledger of rulings: when a conflict or ambiguity is settled without asking the user, record "decision, reason, cost if wrong". Stop and ask only for irreversible actions, security-sensitive steps, side effects beyond the working area, or a plan too broken to follow.

## 4. Long-running orchestrator with a wiki

For a goal that outlives one context window, a coordinator keeps its own context light by sending all work to subagents and communicating through pointers (notes, commits, wiki pages) rather than pasted text. The research post says the lead saves its plan to memory because context past 200,000 tokens is truncated. The pattern adds a wiki: an index page plus one page per decision or subsystem, sources cited and never edited, updated on ingest, consulted before decisions, and linted periodically. Claims are dated and superseded, not rewritten.

Generalize model names to tiers: the source skill sets a model by work weight (a cheap tier to gather, a build tier to implement, a strong tier to analyse or decide). In this pack that is the tier table in [work-weight-tier-table.md](work-weight-tier-table.md); the concrete alias is resolved from the harness, as the docs' model-field values and resolution order show. The orchestrator itself runs at the planning tier, with a ceiling from [quota-and-cost-guards.md](quota-and-cost-guards.md).

## How an agent should apply this

- Write each brief as if the subagent has seen nothing; pick its tier from the brief.
- Run the independence test before parallelizing; default to one agent when failures may share a cause.
- Review in order: spec compliance, then quality; give the reviewer the analysis tier.
- Record rulings with reason and cost-if-wrong; ask the user only for the four stop cases.
- For multi-session goals, keep dated wiki pages and pointers; avoid present tense about code without a date or commit.
- Count the extra tokens: multi-agent runs cost far more than one agent (vendor claim in the research post), so delegate only when the work justifies it.
