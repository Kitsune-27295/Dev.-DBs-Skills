# Three-Layer Orchestration Architecture

Sources: https://agentskills.io/specification · https://raw.githubusercontent.com/obra/superpowers/main/skills/using-superpowers/SKILL.md · https://github.com/coleam00/cole-medin-knowledge-base/blob/main/concepts/progressive-disclosure.md · https://blakecrosley.com/pt-BR/guides/agent-architecture · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices · https://strapi.io/blog/what-are-agent-skills-and-how-to-use-them · Last verified 2026-11-24

How the pieces fit: skills are only found if something points at them, and only chosen well if rules order them. Three layers do this at different costs. Design below is my synthesis; the sources supply the ingredients and are cited where used.

## 1. The layers

| Layer | What | Cost | Strength |
|---|---|---|---|
| 1 Global instructions | always-loaded files (user, project) naming the protocol in a few lines and holding hard rules | every turn | always present, but must stay tiny (4 KB budget in `model-effort-routing` section 7) |
| 2 Discovery index | the `name` + `description` of every installed skill (spec stage 1, about 100 tokens each by spec) | every session, all skills | the host builds it; quality is set by descriptions |
| 3 Protocol meta-skill | `skill-orchestrator` body: classification, selection, ordering, conflicts | only when loaded | detail without permanent cost |

Layers fail differently: layer 1 bloats, layer 2 collides, layer 3 may never load. Crosley (paraphrased) adds a fourth, deterministic element, hooks, for rules that must run regardless of model behavior; use one only where the host supports it. Own inference: the portable pack cannot assume hooks, so layer 3 must work from its description alone.

## 2. Ownership (one rule, one owner)

| Rule | Owner |
|---|---|
| "Consult the orchestrator for non-trivial tasks" | layer 1, one line, pointing at the skill |
| Which skills exist and what they do | layer 2 descriptions |
| How to choose, order, stop | layer 3 only |
| Model and effort | `model-effort-routing` |
| Description writing | `skill-description-and-trigger-design.md` |

Layer 1 never repeats layer 3 text.

## 3. Design notes on the protocol

The protocol itself (classify, instruction check, candidates, select, order, load, announce, stop, honesty, subagent exemption) is owned by `SKILL.md` section 2 (PROTO-01 to PROTO-03) and the conflict order by section 7 (CONF-01). This section keeps only the reasoning that is not stated there. All of it is my design rationale, not source fact.

- Instruction check before candidates: skills are third-party text, while user and project instructions come from the operator; the priority order matches the one the `using-superpowers` skill states (see [meta-skill-routing-patterns-compared.md](meta-skill-routing-patterns-compared.md)).
- Select 1-3: a fourth skill usually means the task should be split, and each load costs a body.
- Order process, then implementation, then review: a skill that sets constraints must be read before the one that executes. Add `model-effort-routing` only when choosing models, effort or delegation.
- Load bodies one at a time, in order, reading `references/` only when a step needs them: this keeps just-in-time loading real.
- Do not route again after the first choice unless scope changes: re-routing loops cost more than a slightly wrong first pick.
- Say "no skill applies" when true: it prevents forced matches and makes a low-effort skip visible.
- A dispatched worker follows its brief: running the protocol inside every subagent multiplies cost for no gain.

## 4. Budgets and stop conditions

- Discovery budget (BUD-01): estimate index size as skills x about 100 tokens (spec figure); a 1024-char description can reach roughly 250 tokens (my estimate), so 80 skills can exceed 8,000 tokens. Measure the real total. The Crosley guide cites a shared host budget near 1% of context. A pack past about 20-50 enabled skills degrades (Anthropic PDF guide troubleshooting); prune or use selective enablement.
- Load cap: see PROTO-02 in `SKILL.md`; each body stays under the 500-line target.
- Stop conditions (STOP-01): a skill's own done-check passes; the user changes scope; two failed routings (no improvement after a second choice) mean ask the user.
- Never use the router to delay a trivial answer.

## 5. Example trace

```
Task: "Design a retry layer for our payment worker."
Classify: non-trivial, money, design.
Candidates: circuit-breaker-retry-telemetry, idempotency-fix, model-effort-routing(no)
Order: design skill -> idempotency check
Announce: Using circuit-breaker-retry-telemetry, idempotency-fix.
Stop: checks in those skills pass.
```

## How an agent should apply this

- Keep layer 1 to a pointer plus hard rules; put the procedure in the orchestrator body.
- Keep descriptions distinct enough that scanning layer 2 yields 1-3 candidates.
- Follow the protocol in `SKILL.md` for non-trivial work; this file adds rationale and budgets only.
- Re-measure the index size whenever skills are added; prune before adding a competing skill.
