# Skill Description and Trigger Design

Sources: https://agentskills.io/specification · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices · https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf · https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md · https://blakecrosley.com/pt-BR/guides/agent-architecture (Portuguese, paraphrased) · Last verified 2026-11-27

The description is the only text the router sees before choosing. Authoring basics (structure, size, bodies) live in `agent-skills-context-engineering`; this page covers description-as-routing-condition, collisions and trigger tests.

## 1. What the sources agree on

- It must say what the skill does and when to use it, with keywords real users say (spec; Anthropic best practices; PDF guide).
- Third person: the text is injected into a system prompt and mixed point of view hurts discovery (best practices). Prefer "Reviews diffs. Use when..." over "I can help...".
- The model picks among possibly 100+ skills from descriptions alone (best practices), by LLM reasoning and not keyword matching (Blake Crosley, paraphrased; consistent with skill-creator).
- Put every "when to use" cue in the description, not in the body: the body is invisible until selection (skill-creator).
- Hard limit 1024 chars (spec; verified facts in [agent-skills-spec-and-progressive-disclosure.md](agent-skills-spec-and-progressive-disclosure.md)). The Crosley guide also reports that Claude Code shares one description budget (about 1% of the context window, 8,000-char fallback); a claim from a blog, check your host.

## 2. Description as a routing condition

Write it as a predicate: capability clause + trigger clause + exclusion clause.

```
Audits SQL schemas for missing constraints and risky types.
Use when reviewing or designing tables, keys or migrations.
Not for query tuning (use query-performance) or backups.
```

Rules of thumb (mine, derived from the sources):
1. First clause names the artifact and verb, so a skim matches it.
2. Trigger clause lists user phrases and file types, not internal jargon (the PDF guide marks "too technical, no user triggers" as bad).
3. Exclusion clause names the neighbor skill by its real name: this is the PDF guide's "negative triggers" fix for over-triggering.
4. Keep an orchestrator's own description narrow: it routes, it does not do the work.

## 3. Under- and over-triggering

| Symptom | Fix | Source |
|---|---|---|
| Skill never loads, users invoke it manually | add keywords, concrete phrasing, file types | PDF guide |
| Loads for unrelated queries | specificity, negative triggers, narrower scope | PDF guide |
| Model skips a clearly relevant skill | skill-creator advises "pushy" wording ("make sure to use whenever..."), because Claude tends to undertrigger | skill-creator |
| Simple one-step task never triggers | expected: the model skips skills for tasks it handles directly | skill-creator |

Tension: "pushy" (skill-creator) and "add negative triggers" (PDF guide) pull opposite ways. Resolve with data: be pushy about the positive domain and strict about the named exclusions. A pack with many overlapping skills should lean strict, since each false trigger costs a body load.

## 4. Collision handling inside a pack

1. Build a table of every pair of skills whose descriptions share nouns (for example two review skills); give each an exclusion naming the other.
2. Make one skill the owner of each noun; others link to it (`ssot-and-dry` principle applied to descriptions).
3. If two descriptions still both match, the routing protocol, not the descriptions, orders them (process before implementation: `SKILL.md` section 2).

## 5. Trigger evals

skill-creator's method: write about 20 queries, 8-10 should-trigger (varied phrasing, no explicit naming, rare uses, cases where it must beat a competitor) and 8-10 should-not-trigger that are near-misses, not obviously unrelated. Run each query several times (it uses 3), split roughly 60% train / 40% held-out, iterate on the description up to 5 times, choose by held-out score to avoid overfitting. The PDF guide's lighter version: 10-20 queries, target about 90% auto-trigger rate (aspirational, "vibes-based" by its own admission). Best practices: at least three evaluations, test with each model size you target.

Example eval file for an orchestrator:

```json
[
 {"query": "plan the migration of our billing tables", "should_trigger": true},
 {"query": "which skills should I use for a security review?", "should_trigger": true},
 {"query": "rename this variable", "should_trigger": false},
 {"query": "explain what a skill is", "should_trigger": false}
]
```

Caveat: skill-creator's optimizer is Claude-specific tooling; the pattern (labeled queries, held-out split) is portable.

## How an agent should apply this

- Rewrite any description lacking a "Use when" clause or written in first or second person; keep it at or below 1024 chars.
- Add an exclusion clause naming the sibling skill for every overlapping pair found in the collision table.
- Write 10+ labeled trigger queries including near-misses before shipping a skill; keep them next to the skill as evidence.
- Test triggering on the lightest model and effort the pack targets: weaker settings skip skills more (see `model-effort-routing` section 4).
- When a skill misfires, change the description and re-run the evals; do not patch with body text the router cannot see.
