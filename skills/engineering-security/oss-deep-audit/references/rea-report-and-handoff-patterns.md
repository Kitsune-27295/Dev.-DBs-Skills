# REA report and handoff patterns

Sources: public REA repository (https://github.com/morluto/rea): main skill `.agents/skills/reverse-engineer-anything/SKILL.md` and `references/evidence-workflows.md`, `references/desktop-build.md`, `references/environments.md`; audit skills `.agents/skills/rea-tool-design/`, `rea-ci-tests-audit/`, `rea-analysis-optimization/`, `rea-changelog-update/`; `docs/development/tool-design.md`, `docs/development/testing.md`, `docs/development/reconstruction-readiness.md`, `docs/release-exposure.md`, `docs/ci-analysis.md`, `CONTRIBUTING.md`, `website/evidence/` notes; local REA skill install (private; summarized) · Last verified 2026-11-24

Paraphrased from REA text; "(inference)" marks my adaptation to source audits.

## 1. Report shapes REA uses

**Investigation close (main skill).** Explain findings in plain language, tie each to returned evidence, separate observed behavior from design choices, release the engine, and keep or export evidence if it must survive the session. Retention is bounded and in memory; durable persistence is an explicit export or checkpoint, not automatic.

**Audit finding classes (tool-design and CI-audit skills).** Classify each item as one of: reproduced defect, supported limitation (intentional), design opportunity, unverified hypothesis (or unavailable evidence). Each confirmed issue carries exact revision, smallest reproduction, consequence, proposed correction and validation limits. Report working alternatives as well as problems. Do not treat missing parity with another tool as a bug.

**Checklist report (release-exposure audit).** Fixed check IDs, a status per check (exposed, not observed, unknown, not assessed), the observation behind each status, fixed remediation text, and a coverage section naming inapplicable checks and omitted members. No pass verdict and no letter grade: unknown and not-assessed counts stay beside the findings. Checks that cannot apply are omitted and listed once, so every check is named exactly once.

**Desktop-build final report.** A long bulleted close-out: bundle path, each task with prompt and checks, why each check proves the change and fails the near miss, each witness stage and verdict, the seed's contents, scrubbed and unscrubbed files (unscrubbed ones need review before sharing), limitations, measured difficulty, build time, and the questions that were asked. It ends with a hard rule never to publish or share the artifact itself.

**Optimization/CI outcome.** Bottleneck, owning change, preserved semantics, executed checks, before/after measurements, remaining limits. A measured decision to leave things alone is a legitimate result. Performance claims state workload and measurements, not a bare percentage; cold vs warm runs are separated; unmeasured costs are named.

**Changelog provenance.** Prose for users, plus a generated inventory that accounts for every discovered change, committed next to the notes. Unknown identities stay unknown; no guessed handles; bots excluded from credit; the summary links to the complete inventory instead of pasting it.

**Case-study evidence notes (website/evidence).** Pinned SHAs and digests, how counts were collected (all pages of history, timestamp basis), what the claim does and does not measure, attribution of historical work to its original projects, and explicit "future experiment" labels for unrun comparisons.

## 2. Checkpoints and resumability

- **Baseline first.** Pin the revision (and workflow revision), toolchain, host and exact command before analysis; an old run is evidence only for the revision it ran on. Use an isolated worktree/checkout for changes; keep notes and raw output outside the tracked tree.
- **Evidence references outlive a step, not a session.** Pass IDs, not copies; export a bundle before closing; import it later to restore IDs and the unknown history; a missing ID is recovered by import or inline evidence, never by guessing or by rerunning the producer.
- **Summary then pages.** Each large result has a parent record plus views with offsets and next-offset cursors; paging reuses completed work. Cursors over mutable state carry a revision and fail if stale instead of shifting rows.
- **Partial results are kept.** A canceled or failed operation retains completed valid partial evidence and the original failure; retry only when the error says it is safe and idempotent.
- **Closure history.** A ledger of required obligations has a fixed universe; each decrease in the open count names the distinct obligations verified; a statement of "ready" requires zero required open; "unknown" may hide a count of zero because limitations can block independently.
- **Stop rules.** Stop after a bounded number of attempts (the desktop-build flow stops after three witnesses and reports what still fails); stop when the benefit is speculative; stop and ask only for things the agent cannot decide (license acceptance, credentials, consent), and record the defaults taken when asking is impossible.
- **Final checklist pass.** Re-read the original question list and label each answered / partial / unresolved.

## 3. Verification and adversarial checks

- Prefer a real public workflow, then a production-boundary check, then a producer golden; a simulated provider tests the integration boundary only.
- Prove a protection by perturbing the behavior in an isolated copy and watching the gate fail; a test that only restates its mock is not coverage.
- Use an independent oracle (known fixture facts or a format-aware reader); another projection of the same tool is not independent.
- Witness pattern: run the check at four stages (fails on seed, passes after the edit, fails on a plausible near miss, fails again after reset). Checks that pass the near miss are too loose; checks that fail a correct edit are brittle.
- A scripted sequence of calls shows only that sequence works; whether an agent would choose it is a separate evaluation.
- Never report an unrun check as passing; list unexecuted recovery steps explicitly.

## 4. Handoff hygiene

- Hand off with: target and revision, question list with status, evidence IDs or file:line references, open gaps with what resolves them, limits of coverage, and the effects any follow-up would have (execution, network, writes).
- Prefer exact selectors and IDs over descriptions; preserve the caller's selector spelling and the observed reason when a lookup failed.
- State session-scoped caveats once and reference them afterwards instead of repeating them per finding.
- Declare effects truthfully (a private temporary copy is still a write).
- Human readiness stays with the human: automation prepares notes and PR text but does not declare ready, merge, tag or publish; PR bodies summarize checks run, observed results and meaningful gaps.

## 5. Example: audit report skeleton (inference)

```
Target: <repo>@<full sha> (tag v1.4.2), scope: src/, package manifests, CI; excluded: vendored/, generated/
Questions: Q1 install scripts? Q2 network egress? Q3 claim C-07? ... status: answered / partial / unresolved
Findings: F-01 [reproduced|limitation|opportunity|unverified] evidence E-.. confidence .. coverage ..
Evidence table: E-id | claim | path:line @sha | type | limitation
Gaps: G-id | question | what would resolve | status/rev
Coverage: read N files / skipped M (list), lenses run, not run
Effects not exercised: no code executed, no network used
Next steps: bounded, with the authority each needs
```

## How an agent should apply this

- End every audit with the same skeleton: pinned target, question status, classified findings, evidence table, gaps, coverage, effects not exercised.
- Never include a pass/fail grade; report unknown and not-assessed counts next to findings.
- Write checkpoints (question list, evidence IDs, gaps) to a file outside the audited tree so a new session can resume without re-reading everything.
- Mark the last pass explicitly: re-read the question list and label each item before saying the audit is complete.
- Leave publication, issue filing and disclosure to the user; offer drafts and attach the evidence table.
