# Subagent Waves and External Memory

Sources: https://github.com/robertnowell/deep-research · https://github.com/Weizhena/Deep-Research-skills · https://github.com/199-biotechnologies/claude-deep-research-skill · https://mcpmarket.com/tools/skills/deep-web-researcher · https://www.aihero.dev/skills-research · Last verified 2026-11-24

## Decompose first
Split the question into 3-5 angles, each a distinct facet (robertnowell): current state, history, competing approaches, practical use, known pitfalls. 199 suggests 5-10 search angles, adding date-filtered, academic, statistical and critical ones. Weizhena builds an outline of items and fields, and the user can confirm it before spending effort. Show the plan (angles, agent count) before launching.

## Wave plan
1. Wave 1 breadth: one worker per angle, launched together in one message.
2. Lead review: gap analysis as in Step 6 of [deep-research-algorithm-replicated.md](deep-research-algorithm-replicated.md) (robertnowell also lists promising leads and shallow areas).
3. Wave 2 depth: 1-3 targeted workers, each with a specific gap such as "verify claim Z in a primary source" or "find the opposing view".
4. Optional verification wave: tiny single-claim checkers.
5. Stop by the rule in budget-and-stopping-rules.md. MCP Market's skill describes the same loop: review, find missing or conflicting facts, targeted follow-ups.
Weizhena adds batching: launch N items, wait, get approval, continue; skip items already finished so a crashed run resumes.

## Worker brief
The brief template lives in `SKILL.md` section 3 (it is the one home for the no-delegation line, the ledger-rows return and `NO_USEFUL_FINDINGS`). Why structured returns: 199 asks workers for claim, exact quote, URL, title and confidence per item, which avoids fatigue when merging.

## External Markdown memory
Keep state in files, not in chat: a plan section, a wave log, a sources table, the claim ledger, open questions. Benefits: survives compaction, lets a fresh agent resume, and keeps worker output out of the main context (the aihero skill's whole point). Use temporary files and delete or archive after the report (MCP Market uses temporary orchestration files). Suggested layout (own):
```
research/<slug>/plan.md   waves.md   sources.md   claims.md   report.md
```
Give each worker its own file or section to avoid write collisions, and let the lead merge.

## Merge and dedupe
- Organize by theme, never by agent ("Agent 1 said"), as robertnowell prescribes.
- Dedupe by canonical URL as in [research-tool-contract.md](research-tool-contract.md), merge identical claims, and note independent repeats as corroboration.
- Same fact from sources citing one origin counts once.
- Do not mention workers that found nothing, except as disclosed failed angles.

## Pitfalls
Recursive delegation (workers spawning workers) is a documented bug in the aihero `/research` skill; add an explicit no-delegation line. Over-parallelism wastes tokens; Weizhena's own docs are inconsistent about whether deep phase is parallel or sequential, so check before relying on it. Synthesis should stay in the lead's context, which holds the user's intent.

## How an agent should apply this
- Write the plan and caps to the memory file before wave 1.
- Send all wave-1 workers in one message with the `SKILL.md` brief.
- After each wave, update the ledger and open-questions list; spawn wave 2 only for named gaps.
- Merge by theme, dedupe by origin, then run the verification pass.
- Tell workers not to delegate, and keep the final writing in the lead.
