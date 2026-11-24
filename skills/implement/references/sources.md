# Sources — Implement

- Upstream base: [mattpocock/skills — `skills/engineering/implement/SKILL.md`](https://github.com/mattpocock/skills/blob/main/skills/engineering/implement/SKILL.md) (MIT License, Copyright (c) 2026 Matt Pocock; retrieved 2026-11-22).
- **Lapidação / integration (`Dev.-DBs-Skills`):**
  - Removed `disable-model-invocation: true` so agents can invoke `implement` autonomously across end-to-end workflows.
  - Integrated `defensive-domain-modeling` and `pragmatic-solid-and-ssot` design invariants during slice implementation.
  - Added targeted guardrails (`never-trust-the-client`, `transaction-fix`, `race-condition-fix`, `idempotency-fix`) when slices handle money, permissions, shared counters, or webhooks.
  - Clarified fresh-context invocation of `tdd` and `code-review` across harnesses.
- **Added 2026-11-24:** `references/orchestrating-a-spec-by-task-graph.md` paraphrases [mattpocock/skills — `skills/engineering/implement-spec/SKILL.md`](https://github.com/mattpocock/skills/blob/main/skills/engineering/implement-spec/SKILL.md) (MIT License, Copyright (c) 2026 Matt Pocock; existence and license verified in the upstream tree and raw LICENSE file, 2026-11-24). The per-subagent weights are local policy, not upstream; tiers are owned by `model-effort-routing`.
