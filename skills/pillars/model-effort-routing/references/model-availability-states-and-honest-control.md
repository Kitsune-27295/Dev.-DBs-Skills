# Model Availability States and the Honest Control Boundary

Sources: https://antigravity.google/docs/models.md · https://code.claude.com/docs/en/sub-agents · Last verified 2026-11-27

A router that picks a tier is only as good as its belief about what can actually be run. This file adds three things the core skill does not spell out: a state vocabulary for availability, an evidence order for finding out, and a rule for separating what the agent can enforce from what it can only advise. Idea origin: a third-party built-in skill read for ideas, no text reused; the public pages above were used to verify the mechanics.

## 1. Six availability states

Label each candidate model or tier before routing to it.

| State | Meaning | Routing consequence |
| --- | --- | --- |
| AVAILABLE | Confirmed selectable and usable now | May be chosen |
| AVAILABLE WITH LIMITS | Usable, with a known constraint (fixed effort, smaller context, scheduled removal) | Choose only if the limit does not hurt the task; note it in the brief |
| QUOTA CONSTRAINED | Rate limit or quota pressure was observed | Keep for work that needs it; push easy work down a tier |
| TEMPORARILY UNAVAILABLE | Transient outage or throttling was observed | Retry later or use the fallback ladder; disclose the substitution |
| UNAVAILABLE | Not selectable under the plan or removed | Never chosen; drop from tables |
| UNKNOWN | Cannot be verified | Treated as not available |

Dated example (Antigravity models page, 2026-11-27): Claude 5.5 models need a non-trial paid plan; Claude Sonnet 4.6 and Opus 4.6, Gemini 3.8 Flash, Gemini 4 Argon and GPT-OSS-120b are marked for removal on 2026-11-30; Ultra and Enterprise exclude Claude 4.6. Such a model is AVAILABLE WITH LIMITS until that date, UNAVAILABLE after it.

Rule: UNKNOWN is never AVAILABLE. An untested name from memory, a model listed in an old table, or a name seen only in a blog is UNKNOWN until evidence arrives. Anything with a removal date gets AVAILABLE WITH LIMITS, and the date goes in the note (the public models page lists scheduled removals, which is why static catalogs rot).

## 2. Discovery by evidence, strongest first

1. Live session signals: model notices, runtime errors, deprecation messages, a failed call naming the model.
2. Local tool inspection when the harness has a command that lists models (a models subcommand, a model picker, an effort query).
3. Official vendor docs, read only when the catalog may have changed or an unknown name appears; do not refetch on every task.
4. The skill's own reference tables, as a baseline only. Live signals always override a stale entry.

Lower rungs age faster, so re-verify a tier table when a model-not-found error appears, not on a timer.

## 3. Quota: use it only when observable

Quota numbers count only when the user stated them, an error message carried them, or a tool printed them. Never invent a remaining percentage. Many hosts show usage in a UI the agent cannot read; the public subagents docs also say subagent requests share the main conversation's usage limits, so delegation does not escape a quota.

Without numbers, apply the cheap default (easy and read-only work to the small tier) but never degrade a critical task just to save quota. The safety floors in [escalation-fallback-and-safety-floors.md](escalation-fallback-and-safety-floors.md) still win. Ceilings and consent rules stay owned by [quota-and-cost-guards.md](quota-and-cost-guards.md).

## 4. Enforced control versus advice

Split every routing decision by who can actually carry it out.

| Control | Who holds it | How to word it |
| --- | --- | --- |
| Per-delegation model or tier parameter | The agent | "I set the subagent tier to X" (verifiable in the call) |
| Model field in an agent definition file | The author of that file | Enforced at launch |
| Main conversation model and effort | Usually the user, via a selector or command | "I recommend switching to X"; never "I switched" |
| Account quota and plan | The vendor and user | State only what was shown |

Public docs show the same split: the Claude Code subagent page documents a per-invocation parameter, a definition field, an environment variable and the parent's model as an ordered resolution (detail in `agent-call-rules-and-enforcement-hook.md`), while the Antigravity models page says the conversation model is chosen in a selector and a mid-run change does not alter the current turn. So a recommendation about the primary model is advice, and a switch claimed without evidence is a false report.

## How an agent should apply this

- Tag each tier you intend to use with one of the six states; treat UNKNOWN as unusable and say so.
- When a model name fails, downgrade its state, record the evidence, then use the fallback ladder.
- Quote quota only from something you saw; otherwise say "not observable".
- Phrase primary-model changes as recommendations; claim enforcement only for delegation parameters you actually set.
- Do not duplicate the tier tables or ceilings; link the files named above.
