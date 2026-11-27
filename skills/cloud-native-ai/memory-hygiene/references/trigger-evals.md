# Trigger Evals: memory-hygiene

Last verified 2026-11-27. Check the description against these before editing it.

## Should trigger

1. "Audit my agent's notes: half of them mention paths from before we renamed the repo." -> `memory-hygiene`
2. "The agent confidently used a config path from memory and it was wrong; make sure that stops." -> `memory-hygiene`
3. "Set up a monthly check that marks old memory entries as verified, stale or contradicted." -> `memory-hygiene`

## Near misses (another skill owns it)

1. "What should the agent write to memory at the end of this session?" -> `agent-session-memory`
2. "Which rules belong in CLAUDE.md versus a hook?" -> `skill-orchestrator`
3. "Record why we chose Postgres over MongoDB." -> `adr-architecture`
