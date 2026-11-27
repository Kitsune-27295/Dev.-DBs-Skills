# Trigger Evals

Last verified 2026-11-27. Starting points for a description check, not a measured result.

## Should trigger (this skill)
1. "Our support bot answers from one FAQ index. Do we need an agent with retrieval tools or is plain RAG enough?"
2. "Review this design: the agent calls 40 REST endpoints as tools and loops until it likes its answer."
3. "How do I keep users from seeing documents they lack access to in our RAG search, and how do I evaluate retrieval quality?"

## Near-misses (other skill)
1. "Which model tier and effort should each subagent use, and how do I write the delegation brief?" -> `model-effort-routing`
2. "Split this refactor across four parallel agents with a coordinator and a stall monitor." -> `multi-agent-coordination`
3. "Record the lesson we learned so the next session does not repeat it." -> `agent-session-memory`
