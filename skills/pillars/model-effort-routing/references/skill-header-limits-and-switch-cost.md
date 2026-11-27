# Skill Header Limits and Model-Switch Cost

Sources: https://code.claude.com/docs/en/skills · https://code.claude.com/docs/en/model-config · https://code.claude.com/docs/en/changelog · https://platform.claude.com/docs/en/about-claude/pricing · local operating practice (private notes, summarized; not a public URL) · Last verified 2026-11-27

A skill can carry `model:` and `effort:` lines in its header, which is the cheapest way to tier a skill by weight (see work-weight-tier-table). The lines are useful but weaker than they look. Five limits, with their origin:

| # | Limit | Consequence |
|---|---|---|
| 1 | `model:` applies only to the turn in which the **user** runs the skill with `/name`; when Claude invokes the skill itself, the session keeps its model. `effort:` applies for the rest of the current turn either way, then reverts. Since changelog 2.1.330, a skill that sets `model` (other than `context: fork`) leaves subagents, forks, compaction and `/recap` on the session model | A user-typed light-tier skill *lowers* the model for the rest of that turn, a strong one *raises* it and its cost; a model-invoked skill changes only effort. |
| 2 | In auto mode, a model the mode does not support is ignored | The session keeps its current model; the header's model line silently does nothing. |
| 3 | An effort environment variable outranks a skill's `effort:` | If the variable is set, tier efforts are overridden. Unknown whether per-model settings in the settings file apply after a skill switches model; an explicit `effort:` line makes the result independent of that. |
| 4 | A model switch is not free | Prompt caches are scoped to a model, and thinking blocks are only read by the model family that wrote them. Switching on a large context re-reads that context once at the new model's **uncached** input price, and the new model starts without the old one's thinking. |
| 5 | `context: fork` runs the skill in its own subagent | Sets the forked subagent's model/effort instead of the main turn's, which avoids limits 1 and 4. |

Points 1, 2, 3 and 5 were re-read in the vendor's skills and model-config documentation on 2026-11-27 (point 1 was corrected: the older text said both lines last the rest of the turn); point 4 comes from the vendor's API reference and price table (not re-read). **None was measured locally.**

## Quantifying switch cost (illustrative, 2026-11, check current pricing)

Input prices per million tokens (pricing page, 2026-11-27): Haiku 5.5 $0.10 (prompts up to 100k; $0.50 above), Sonnet 5.5 $2, Opus 5.5 $4, Fable 5.2 $8. Cache hits cost 0.05x base on Opus 5.5 and Sonnet 5.5, 0.025x on Fable 5.2 and 0.1x on Haiku 5.5; the figures below are the uncached worst case. Example with 200k tokens of context:

```
down to light : 0.2M x $0.10 = $0.02  (negligible)
mid -> strong : 0.2M x $4    = $0.80 uncached re-read, once
strong -> planner: 0.2M x $8 = $1.60
```
Between mid, strong and planner tiers the one-off cost can exceed the saving on a short turn. Cached input is cheaper than the uncached figure, but the cache cannot be reused across models.

## Decision rules

- **Switch down to the light tier freely** (cheap re-read), but remember a user-typed light skill lowers the rest of the turn too.
- **Do not switch between mid/strong/planner mid-conversation for a short task**; do the work on the current model or push it into a subagent.
- **Prefer a subagent with an explicit `model` on the call** (or a forked skill) when the work is bounded and its result can be summarized back: the lead's context is not re-read by a different model.
- **Do not rely on the header in auto mode** or when the effort variable is set; verify with the launch report instead.
- Re-apply headers after a skill is reinstalled (the lines are lost).
- Stronger planner tier: reserve for skills that coordinate agents; Fable 5.2 list price is double Opus 5.5 ($8/$40 vs $4/$20).

## Failure modes

- Assuming a `gather` skill "only affects itself": when the user types it, it lowers the model for everything after it in that turn.
- Setting the effort variable globally and wondering why tier efforts have no effect.
- Counting the savings of a switch without counting the uncached re-read.

## How an agent should apply this

- Use header tiers for self-contained skills invoked at the start of a turn; use per-call model on subagents for mid-turn work.
- Before invoking a heavier-tier skill mid-turn on a large context, estimate the uncached re-read cost.
- Check the effort environment variable and auto-mode status when a tier seems to have no effect.
- Label unmeasured claims as such in any report; do not present documented behavior as locally verified.
