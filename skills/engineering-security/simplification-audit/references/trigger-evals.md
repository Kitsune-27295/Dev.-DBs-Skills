# Trigger Evals

Last verified 2026-11-27 (mental check against the description; not a measured run).

## Should trigger (`simplification-audit`)

1. "Find dead code and unused config keys in this repo and tell me what is safe to delete."
2. "Which flags and states in the order service are only there out of habit? Rank removal candidates."
3. "Should we keep the old import path, or can we drop it? Check who uses it."

## Near-miss (belongs to a neighbor)

1. "Should I add an interface here now or wait for a third case?" -> `kiss-yagni-aha`
2. "Migrate all callers off the old API without breaking consumers." -> `parallel-change-expand-contract`
3. "Audit this third-party repository before I depend on it." -> `oss-deep-audit`
