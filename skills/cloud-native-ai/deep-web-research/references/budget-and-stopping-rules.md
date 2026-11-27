# Budget and Stopping Rules

Sources: https://github.com/199-biotechnologies/claude-deep-research-skill · https://github.com/robertnowell/deep-research · https://github.com/Weizhena/Deep-Research-skills · https://www.aihero.dev/skills-research · https://github.com/sanjay3290/ai-skills · https://mcpmarket.com/tools/skills/deep-web-researcher · Last verified 2026-11-27

Every number below is a claim made by the named repository, not a measured fact. Use them as starting values and calibrate on your own runs.

## Depth modes in the wild

| Mode | 199-biotechnologies (claimed) | robertnowell (claimed) |
|---|---|---|
| Quick | 3 phases, about 2-5 min | 2 breadth agents; no depth, no verification |
| Standard | 6 phases, about 5-10 min | 3 breadth, 1-2 depth, no verification |
| Deep / thorough | 8 phases, about 10-20 min | 5 breadth, 2-3 depth, plus verifier agents |
| UltraDeep | 8+ phases, about 20-45 min | none |

199 also claims 5-10 parallel searches plus 2-3 subagents in retrieval, at least 10 sources with 3+ per major claim, and a validation loop capped at 3 cycles. MCP Market's skill picks one of four levels from the query itself (simple fact = quick, comparison = thorough) and lets the user override; it documents no caps. The aihero `/research` skill has no cap at all and relies on narrow questions.

## Stop criteria found
- First-finish threshold (199, claimed): leave retrieval when the first of two conditions holds, for example 15+ sources with average credibility over 60 or 5 minutes in standard mode; remaining searches may finish in the background.
- Graceful degradation (199): fewer than 5 sources after an exhaustive search means stop and report; 5-10 sources means continue but note the limit in the report.
- Failure protocol (robertnowell): three query reformulations without a Tier 1/2 source returns an explicit no-findings result; one replacement agent is allowed, then the gap is accepted and disclosed.
- Repeat failure (199): two failures on the same validation error stops the loop and asks the user.
- Human gate (Weizhena): the user approves each batch before the next launches.

## Diminishing returns (our synthesis, inferred)
Track "new independent facts per round". If a full wave adds no new claim that changes the answer, and no open contradiction remains, stop. Two waves with fewer than about 10% new claims is a reasonable heuristic; it is our inference, not a source claim.

## Cost control
- Cheap model for workers, strong model for the lead only (robertnowell uses Sonnet workers and Haiku verifiers).
- Verify only high-importance claims that rest on one source, not everything.
- Persist results to files so nothing is re-fetched after context compaction.
- Delegating to a vendor API (sanjay3290 repo claims 2-10 min and about $2-5 per run, 250k-900k input tokens) trades control for convenience; announce the cost before running.
- Guard recursion: see Pitfalls in [subagent-waves-and-memory.md](subagent-waves-and-memory.md).

## Budget block
The default caps and the per-mode budgets are in `SKILL.md` section 2; copy that block into the memory file before wave 1 and update the counters.

## How an agent should apply this
- State the mode and caps in the plan before any search; ask only if the cost could be large.
- Default to standard; use quick for one-fact lookups (usually just search, no skill); deep only when a decision depends on it.
- After each wave, record new-claims count and open contradictions; apply the stop rule explicitly.
- When a cap is reached, write the report with a "not covered" list rather than extending silently.
- Label borrowed numbers as claimed and tune them from your own run logs.
