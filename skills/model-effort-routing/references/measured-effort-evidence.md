# Measured vs Claimed: What the Evidence Actually Supports

Sources: https://github.com/owid/skills/blob/main/FAQ.md · https://github.com/pedrohcgs/claude-code-my-workflow/blob/main/.claude/rules/model-routing.md · https://github.com/imbad0202/academic-research-skills (README, shared/model_tiering.md) · https://github.com/vishalsachdev/claude-skills (allocate-agent-models/SKILL.md) · https://github.com/masskrdjn/claudeskills · https://github.com/softspark/ai-toolkit/blob/main/app/skills/model-routing-patterns/SKILL.md · Last verified 2026-11-23

Purpose: separate the few observations that are measured from the many routing numbers that are opinion, so a routing skill does not hard-code folklore.

## 1. The one concrete measurement: low effort suppresses skill use (owid/skills FAQ)

What the FAQ says (read in full): skills are invoked through a tool call, and lowering reasoning effort makes agents make fewer tool calls, so an effort setting turned down for cost can stop skills being used at all. The authors report measuring this on Claude Code "while testing how reliably the skill gets picked up": at `--effort low`, five questions that reliably reach for a skill at normal effort were answered directly with no skill consulted. Nothing about the skills changed, only the effort.

Limits you must keep when citing it:

- Sample is five questions on one skill (OWID data lookup) on Claude Code. It is an anecdote with a clear mechanism, not a benchmark. No effort levels other than low versus "normal" are reported; no model name or version is given in the FAQ; no counts at `medium`.
- The authors explicitly say they have **only measured Claude Code**. Codex has an analogous `model_reasoning_effort` setting (`low` to `ultra`, depending on model); the FAQ presents that as a "plausible first thing to check", not a known cause.
- Recommended response in the FAQ: if an agent ignores skills, raise effort and retry before blaming the skill; asking for the skill by name bypasses routing and distinguishes "skill missing" from "skill not selected". The FAQ also says agents skip skills for tasks they can do unaided, by design, so vague or trivial prompts may not trigger even at high effort.

Implication for routing (my inference): an effort floor is a correctness setting for any workflow that depends on skill or tool invocation, not only a cost dial. Pin effort at a level where the skill reliably fires, and test activation after lowering it. masskrdjn reaches a compatible point from vendor docs: lower effort consolidates tool calls (cheaper, but different behavior), and Haiku `low` may skip checks or stop early on long prompts.

## 2. Claims by repo, graded

| Claim | Source | Grade |
|---|---|---|
| Low effort turned five skill-using questions into direct answers (Claude Code) | owid FAQ | Measured by authors, tiny n, one setup |
| Opus `medium` matches or beats the previous Opus generation at `high`; always-on thinking; effort is the only depth control | pedrohcgs, citing Anthropic's own evals | Vendor claim relayed by a third party; verify in vendor docs |
| A 70/20/10 tier split (Haiku/Sonnet/Opus) | pedrohcgs | Author opinion; the repo even retracts an earlier citation that did not support it |
| 50-80% cost reduction on routed skills, no quality loss on mechanical tier | pedrohcgs | Unsupported claim |
| Advisor-checkpoint setup reached ~90% of frontier-solo quality at ~34% tokens | ARS citing an external write-up | Secondary claim on ML-tuning tasks; ARS itself warns it may not transfer to prose |
| Stronger models' value concentrates at mid-task re-ranking and verification rather than upfront planning | ARS (same source) | Secondary claim; used to justify lifting only judgment gates |
| Same-tier challenger and auditor share blind spots | pedrohcgs | Reasoning; no data |
| Fable is 2x Opus price and runs longer turns; Fable starts at `high` | Getty; masskrdjn says 2.5x | Repos disagree on the multiple (2x vs 2.5x); check current price page |
| Sonnet 5.5 effort levels are recalibrated vs Sonnet 5; re-sweep evals rather than carrying a setting over | masskrdjn citing vendor prompting guide | Vendor guidance via third party |
| Fable is the right move when evals at higher Opus effort still fall short | pedrohcgs citing Anthropic guidance | Vendor guidance via third party |
| Local policies (Sol/Terra/Luna allocation, failure counts) | Vishal | Explicitly unvalidated starting policy; OpenAI scope only |

Gaps worth recording: none of the Claude-focused repos publishes a per-tier or per-effort quality benchmark of its own. ARS says its prompt-level tiering changes are "unmeasured". masskrdjn ships a transcript analysis script (tokens, durations, dollar cost by model, effort and role) but states the gain from its `runner` role is "not demonstrated" until complete runs compare it against root cost.

## 3. How the better repos handle uncertainty

- Vishal: establish an accuracy reference on the strongest model for a new task class, then down-route only when a cheaper candidate meets the acceptance bar on representative local tasks; evidence is per task class (inventory success does not validate security review). Evaluate the exact model-and-effort pair; do not infer equivalence from higher effort on a smaller model. Re-evaluate after model, tool, prompt or distribution changes. Public benchmarks are secondary.
- softspark: set acceptance criteria before changing the route; log model ID, effort, policy version, attempts, latency, cache reads/writes and billable tokens; evaluate per task type and language with held-out examples; no fixed thresholds or ratios as universal rules.
- masskrdjn: an economic comparison needs at least two complete runs.
- ARS: tier is lineup position, not a capability ranking; a lower tier can beat the frontier tier on some tasks.

## How an agent should apply this

- Cite only what is graded "measured" as fact, and say how small the sample was; label every percentage split or savings figure as a claim by its author.
- When setting effort low for cost, verify that skills and tools still fire; treat an unexplained "agent ignores the skill" as an effort problem first, and use the skill name to test.
- Before down-routing a task class, run a small representative eval on the exact model and effort pair and keep a dated record.
- Re-check model tiers, prices and effort defaults against vendor docs at use time; the repos' numbers are dated snapshots and disagree with each other.
- Prefer measured per-task data over any repo's table; where none exists, start conservative (higher tier or effort for high-consequence work) and relax only with evidence.
