# Work-Weight Tier Table

Sources: Local operating practice (private notes, summarized; not a public URL) · Last verified 2026-11-23

A tiering policy maps the *weight of the work* to a model and an effort level, so that cost and capability move together. The policy runs as a single data file (a "policy" JSON) that says which model and effort each kind of work gets, and which skill or agent belongs to which kind. Editing one tier changes every member at once.

## The five tiers

| Tier | Work it covers | Model | Effort | Rationale |
|---|---|---|---|---|
| `gather` | fetch, search, read-only lookup, counting | lightest (haiku class) | high | Cheap per token. Vendor prompting guidance for the lightest model suggests `high` suits strict instruction following; at `low` it is likelier to skip a search or stop early. |
| `build` | generate, implement, edit, set up, write, diagnose with tools | mid (sonnet class) | high | `high` is the API default for the mid model and fits long agentic tasks; at `medium` it more often stops to check with the user before finishing. |
| `reason` | analysis, comprehension, review, design, security, root cause | strongest (opus class) | high | One step above the session default on purpose: these are the heavy-judgment tasks where a wrong answer costs more than the tokens. Higher levels (`xhigh`, `max`) only for a measured gain. |
| `orchestrate` | plan and coordinate other agents, long runs with little supervision | top-tier planner (fable class) | high | Vendor guidance says start at `high`; the model is reported to work well as planner of other models. About twice the price of the strong tier, so keep the list short. |
| `style` | not a task: an output style that must not switch the session | inherit | no line | Switching model or effort for a presentation style would be wrong. |

Pairs of model and effort come from vendor guides plus the policy author's session defaults; they were **not evaluated on the local task mix**. Two choices sit above session defaults (`medium`) and cost more thinking per turn: `reason` at `high` (a choice, not a guide default) and `build` at `high` (buys fewer early stops on long agentic skills, but short skills pay too). If turns slow down without a gain, drop `build` back to `medium`.

## Illustrative prices

Per million tokens, input/output; illustrative, dated 2026-11, check current pricing: light $0.10/$0.50, mid $2/$10, strong $4/$20, planner $8/$40. The spread (up to roughly 80x between the lightest input and the top output price) is the reason weight-based routing matters.

## Policy file shape (generic sketch)

```json
{
  "version": 2,
  "tiers": {
    "gather":      {"model": "light",   "effort": "high", "work": "fetch, search, read-only lookup"},
    "build":       {"model": "mid",     "effort": "high", "work": "generate, implement, edit"},
    "reason":      {"model": "strong",  "effort": "high", "work": "analysis, review, design"},
    "orchestrate": {"model": "planner", "effort": "high", "work": "coordinate agents"},
    "style":       {"model": "inherit",                   "work": "output style only"}
  },
  "skills": {"gather": ["web-search"], "build": ["tdd"], "reason": ["code-review"], "orchestrate": [], "style": ["terse-output"]}
}
```

## Maintaining the mapping with a tool

A small script reads the policy and rewrites the `model:` and `effort:` header lines of every skill:
- `--check`: exit non-zero on a header that differs from its tier, an **unclassified** skill, or an unreadable file.
- `--apply`: fix headers, backing up whatever it overwrites; a tier without `effort` removes an existing `effort:` line.
- Moving a skill = moving its name between tier lists, then `--apply`. A new skill shows as unclassified until listed.
- Re-run `--apply` after any reinstall or rewrite of a skill, because the header lines are lost.
- Skip synced copies, trash and staging folders on purpose.

## Decision rules

- Classify by what the work *does*, not by its name: anything called "reviewer", "auditor" or "critic" is `reason`.
- Research skills stay in `gather`; their cost is controlled by caps, not by a stronger model (see agent-call-rules-and-enforcement-hook).
- Put a skill in `orchestrate` only if it coordinates other agents or runs larger than one session; analysis stays in `reason`.
- Check that every effort level exists on every model used before adding a tier.

## How an agent should apply this

- Place each skill or agent in exactly one tier by its dominant work; if unsure between `build` and `reason`, ask whether a wrong output is cheap to fix.
- Edit the tier, not individual files, when changing a model or effort; then run the check.
- Treat model/effort pairs as hypotheses; revisit when turns are slow or quality drops.
- Quote prices only with a date and a "check current pricing" caveat.
