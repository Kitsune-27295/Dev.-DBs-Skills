# Trigger Evals: agent-cost-report

Last verified 2026-11-27. Check the description against these before editing it.

## Should trigger

1. "How much did my Claude Code sessions cost last week? I only have the local transcripts." -> `agent-cost-report`
2. "My estimate from the logs is $40 but the console shows $52; help me reconcile." -> `agent-cost-report`
3. "Write a small script that prices cache reads and 1-hour cache writes from the JSONL usage fields." -> `agent-cost-report`

## Near misses (another skill owns it)

1. "Which model and effort should my subagents use to cut cost?" -> `model-effort-routing`
2. "My CLAUDE.md is huge; how do I shrink what loads each session?" -> `agent-skills-context-engineering`
3. "Design a cache layer for my API's database reads." -> `caching-strategies`
