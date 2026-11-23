# Tier Tables Compared: Who Routes What, and Where They Disagree

Sources: https://github.com/Getty/skills/blob/main/claude/model-routing/SKILL.md · https://github.com/pedrohcgs/claude-code-my-workflow/blob/main/.claude/rules/model-routing.md · https://github.com/masskrdjn/claudeskills (.claude/skills/quota-orchestrator/SKILL.md, .claude/settings.json) · https://github.com/DeL-TaiseiOzaki/claude-code-orchestra/blob/main/.claude/skills/team-execute/SKILL.md · https://github.com/softspark/ai-toolkit/blob/main/app/skills/model-routing-patterns/SKILL.md · https://github.com/imbad0202/academic-research-skills (shared/model_tiering.md) · Last verified 2026-11-23

All of these are community repositories. Every table below is the repo author's opinion or local starting policy unless stated; none of the tier assignments is a vendor recommendation. Model names and prices are as each repo dated them (late 2026) and go stale; re-check against the vendor model docs.

## 1. What each repo routes (side by side)

| Repo | Routing axis | Default | Mechanical | Judgment / review | Top tier |
|---|---|---|---|---|---|
| Getty/skills `model-routing` | Hardest single dimension of the task (spec clarity, judgment depth, cost of error, verifiability, context breadth, novelty) | Omit `model:` and inherit | Fast (Haiku): extraction, formatting, renames with a pattern, rubric classification | Strong (Opus): architecture, security review, debugging without reproducer, verification of high-stakes work | Frontier (Fable): long-horizon autonomous work, several dimensions maxed, or a failed Opus attempt |
| pedrohcgs `model-routing.md` | Cognitive demand per agent, fixed in frontmatter | `inherit` only for unprofiled or tier-spanning agents | Haiku tier (claimed ~70% of calls) | Sonnet tier for review/critique (~20%) | Opus tier for gates where a false PASS is expensive (~10%); Fable deliberately not used for the fleet |
| masskrdjn `quota-orchestrator` | Role (root, scout, researcher, runner, builder, architect) | Root on Opus `xhigh`, delegates selectively | `runner` on Haiku `medium` (execute and report only) | `builder` Sonnet `high`; `scout`/`researcher` Sonnet `medium` | `architect` Opus `xhigh`; Fable only on confirmed access, as a second call |
| claude-code-orchestra `team-execute` | Workstream risk | Sonnet teammates (implementers, tester, reviewers) | Stays on Sonnet if plan and acceptance criteria are clear, even for many files | Opus only for ambiguous architecture, subtle security/concurrency/data/perf risk, or failed attempts | Opus (no Fable) |
| softspark `model-routing-patterns` | Measured quality, latency and cost under user-approved policy | Whatever the native client selected; explicit user choice wins | Not tiered by rule | Opus `high` orchestrator, Sonnet `high` bounded implementation, Opus `xhigh` for hard debugging | Refuses universal ratios; says "do not declare a model best for every workload" |
| academic-research-skills `ARS_MODEL_TIERING` | Agent type (judgment vs execution) plus an opt-in switch | Unset means every agent inherits the session model | `economy` mode: execution agents drop one tier, floor Opus-class | Judgment agents stay on session model; `quality-boost` lifts them to the frontier only at integrity gates and final review | Frontier tier at checkpoints only |

## 2. The disagreements worth knowing

1. **Routing by what? ** Getty and orchestra explicitly reject routing by size or file count (a 2000-record extraction is fast-tier; a three-line auth diff is strong-tier). masskrdjn agrees ("file count does not set the level"). pedrohcgs routes by named agent role, which is static and coarser, and accepts that a role spanning tiers is a smell (split the agent). Getty makes the same point as a rule: a role whose load spans tiers is two roles.
2. **Where Fable goes.** Getty makes Fable a regular fourth tier for work whose worst dimension tops the rubric. pedrohcgs refuses to route any fleet agent to it (cost multiple of Opus, priced for long-horizon work, no measured gain) and keeps it for interactive hard sessions. masskrdjn allows it only as an explicit, user-consented escalation. ARS reserves it for gate checks. Net: nobody makes it a default; the disagreement is whether it is a normal tier or an exception.
3. **Default: inherit or pin?** Getty: omit and inherit; override only for a rubric reason; `claude -p` children inherit nothing, so pass `--model`. pedrohcgs: pin per agent after profiling, inherit only while unprofiled. masskrdjn: pin role in agent profile plus `modelSettings` in settings. softspark: never rewrite agent frontmatter to force a cheaper worker. ARS: never edit agent files; resolve a relative tier at dispatch time and never hard-pin model IDs in repo files.
4. **Review tier.** pedrohcgs: reviewers on Sonnet, only the false-PASS-sensitive gates on Opus. Getty: reviewer/security/release lanes strong. orchestra: reviewers Sonnet unless the dominant risk is subtle. Direct conflict on the default; the shared principle is "tier of the checker must match cost of a missed defect".
5. **Haiku for execution.** masskrdjn puts only a bounded runner (3 correction cycles, 2 environment retries) on Haiku and explicitly keeps scouts and researchers off it because their facts are trusted unchecked. pedrohcgs claims 70% of work belongs there. Treat the 70/20/10 split as the author's opinion; masskrdjn's reasoning (cheap tier is safe only when the role is bounded and its output is verified) is the more conservative rule.
6. **Haiku default effort.** masskrdjn/pedrohcgs/softspark all cite `medium` as the Haiku 5.5 default and `low` as a cost pin for mechanical work; masskrdjn warns `low` can skip checks or stop early on long prompts and requires executed checks from the runner.

## 3. Effort tables compared

| Repo | Effort stance |
|---|---|
| Getty | Second dial. Tune effort before tier for lighter work of the same kind. Fable starts at `high`; go above only where gain is measured. |
| pedrohcgs | "Effort is the first cost lever, tier the second." Mechanical `low`; Sonnet review `high`; Opus false-PASS gates `high` (one above default `medium`); other Opus agents `medium`; skills pin `high` only for verification gates; `xhigh` for hardest runs; `max` only after `xhigh` verified insufficient; `maxEffortLevel` as a ceiling. |
| masskrdjn | Per-role fixed: root `xhigh`, builder `high`, scout/researcher `medium`, runner `medium`, architect `xhigh`. Builder stops at `high`; `xhigh` only with a complete measurement run. Also sets `effortLevel` and per-model `modelSettings` in `settings.json`. |
| softspark | Keep the configured agent/skill effort; effort changes only through an approved experiment that records thinking/output tokens and quality at equal task budget. Notes top-level effort changes can invalidate prompt caches. |
| ARS | No effort axis; tier-only. |
| Vishal (OpenAI scope) | Effort chosen independent of model: low for exact searches, medium for evaluated work, high for new/destructive/weak-oracle, xhigh for exceptional ambiguity; never read "bigger effort on smaller model" as equivalence. |

Observation (mine): all Claude-oriented repos converge on "raise effort before tier"; they diverge on the starting point for judgment gates (`medium` vs `high` vs `xhigh`), which is exactly the unmeasured part.

## How an agent should apply this

- Pick the tier from the worst single dimension (cost of error, verifiability, ambiguity), never from size or file count.
- Keep `model: inherit` for unprofiled or tier-spanning work; pin a model only with a stated reason, and split a role whose load spans tiers.
- Lower or raise effort first; change tier only when the same effort on the same tier still fails.
- Do not copy another repo's percentages or per-agent table; they are authors' opinions tied to their workload.
- Reserve the top tier for explicit, announced escalations, not defaults.
