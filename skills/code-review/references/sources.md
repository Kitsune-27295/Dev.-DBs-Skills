# Sources — Code Review (Two-Axis)

- Upstream base: [mattpocock/skills — `skills/engineering/code-review/SKILL.md`](https://github.com/mattpocock/skills/blob/main/skills/engineering/code-review/SKILL.md) (MIT License, Copyright (c) 2026 Matt Pocock; retrieved 2026-11-22, incorporating fresh-context subagent isolation from PR #1341).
- **Lapidação / integration (`Dev.-DBs-Skills`):**
  - Connected Fowler's 12 code smells directly to the deeper rules in `pragmatic-solid-and-ssot`, `defensive-domain-modeling`, `vertical-slice-architecture`, `layered-refactor`, `yagni-evolutionary-architecture`, and `codebase-design`.
  - Added conditional Standards-axis cross-checks for diffs touching auth, money, DB queries, or webhooks (`security-audit`, `fundamentals-audit`, `database-audit`).
  - Preserved sequential isolated-pass fallback note for harnesses without parallel subagent spawning.
- (added 2026-11-24) Second-opinion reference: a third-party MIT skill (cross-modal-review) read for ideas, no text reused; calibrated against Google's public reviewer guide (https://google.github.io/eng-practices/review/reviewer/, standard.html and looking-for.html; all 200 OK via curl, tags stripped, first part of each read). The two-axis method is unchanged.
- (added 2026-11-24) The cost multiplier ("roughly double") is our own estimate, not measured.
