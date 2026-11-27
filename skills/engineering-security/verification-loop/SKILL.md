---
name: verification-loop
description: "Closed-loop verification for agent work: a task is done only when every falsifiable acceptance criterion (AC-1..n) has evidence from a command or observation run in this session, certified by someone other than the maker. Covers criteria, an evidence ledger, a read-only fresh-context verifier, risk lanes (tiny, normal, full, bug), retry caps, no-progress detection, escalation, proof that a check can fail, and the completion states Implemented, Validated, Partially validated, Blocked. Not for writing tests (`tdd`), diff review (`code-review`) or browser QA (`playwright-qa-orchestrator`). Use when finishing or reviewing non-trivial work, before saying done, fixed or passing, when accepting a subagent report, when designing an agent loop with a verifier, or when a green result looks too easy."
---

# Verification Loop

One idea: **work is done when each acceptance criterion has fresh evidence that someone other than the author checked, not when the author feels finished.** Write the criteria first, run real checks, record the output, let an independent pass confirm it, and stop on a cap instead of spinning. Sources: [references/sources.md](references/sources.md).

Each rule has one owner: where a neighbor skill owns it (section 9), this file points there and adds only criteria, evidence and certification.

---

## 1. When to use, when not

| Situation | Do |
|---|---|
| Any change you are about to call done, fixed or passing | Run at least the **tiny** lane: one observed check, then claim. |
| Non-trivial feature, refactor, migration, config or data change | **normal** or **full** lane. |
| Something broken, failing, slow | **bug** lane (reproduce first). |
| A subagent or session reports success | Unverified until its checks are re-run (section 5). |
| Designing an iterating agent loop | Verifier, cap, budget, no-progress, human exit (section 7). |
| Pure question or discussion with no deliverable | Not this skill. |
| Wording-only edit, nothing runnable | tiny: re-read the diff, say "not executed". |

The lane sets the ceremony: little for a one-line change, full for a risky one.

## 2. The loop in six steps

1. **Criteria and lane (section 6).** Write ACs before editing: falsifiable, observable, one behavior each ([criteria reference](references/acceptance-criteria-and-evidence-ledger.md)).
2. **Make.** Implement the smallest complete change that targets the ACs.
3. **Check.** Run each AC's check after the last edit. Read the output; count, do not skim.
4. **Record.** Write one ledger row per AC: `AC | check command | observed output excerpt | verdict | run time`.
5. **Certify.** A party other than the maker re-runs the checks per the lane (section 5). Fix only FAIL rows, then re-check.
6. **Close.** Stop at the first exit (all PASS, cap, budget, no progress, human) and report a completion state (section 8).

Steps 3-5 repeat within section 7's limits.

## 3. Criteria

An AC is `AC-<n>: <subject> <does/returns/shows> <exact result> under <condition>. Check: <command or observation>.`

- **Falsifiable:** an observation that would prove it false exists. Reject "works", "is fast", "looks right".
- **Observable:** a command, response, diff, screenshot or log line shows it.
- **One behavior each.** Split "and".
- **Owned:** traces to the request or spec; one AC comes from the user's outcome.
- No runnable check: mark it `UNVERIFIED`; never swap in a weaker proxy silently.

Examples, ledger schema, hygiene: [references/acceptance-criteria-and-evidence-ledger.md](references/acceptance-criteria-and-evidence-ledger.md).

## 4. Evidence rules (evidence before claims)

| Rule | Detail |
|---|---|
| E1 Fresh | Evidence comes from a command or observation run **in this session after the last relevant edit**. Old output, memory and "should work" are not evidence. |
| E2 Read | Read the output and exit code; compare counts to expectation ("0 tests ran" is not a pass). |
| E3 Quote | Copy signal lines only (counts, status, first failing assertion), unedited; secrets become `<redacted>`. |
| E4 Separate | Label `observed:` (printed) apart from `inferred:` (your conclusion). |
| E5 Proportionate | A proxy is not the property: build or typecheck does not prove behavior; a unit test does not prove the UI. Use the check that exercises the AC. |
| E6 Runtime | A user-visible change gets observed running: run the real flow and read the result. For UI use `playwright-qa-orchestrator`. |
| E7 Wording | No "done", "fixed", "passing" before the ledger row exists. Wording follows the verdict. |

No evidence means the sentence is "not verified: <reason>", a legitimate report line.

## 5. Verifier independence (maker-checker)

The agent that produced the work must not be the one that certifies it. Independence levels, the verifier brief template and the verifier's tier are in [references/verifier-independence-and-lanes.md](references/verifier-independence-and-lanes.md). The core rules:

- **L0 (maker says it works) never counts.**
- **L1:** a separate maker pass after a clean start that re-runs every check and quotes fresh output. For tiny and low-risk normal work.
- **L2:** a different session or subagent in fresh context, **read-only on the source**, given the ACs, the change location and the commands, not your conclusions. It re-runs the checks, adds its own where yours could pass vacuously, and returns the table. Default for full, bug and non-trivial normal work.
- **L3:** L2 on a different tier or family plus a human decision, for destructive, security or financial effects.
- The maker never edits the verifier's table. If the verifier changed any file, its verdict is void.
- Ask for evidence per AC and gaps that affect correctness, not style opinions.
- Tier, effort and the brief skeleton come from `model-effort-routing`; do not pick them here.

## 6. Lanes (ceremony by risk)

Pick by the **worst single dimension** (reversibility, blast radius, who sees it, data or money touched). Unsure: take the heavier. Upgrade when new risk shows; never downgrade to finish faster.

| Lane | Use for | ACs | Checks | Certification | Observation |
|---|---|---|---|---|---|
| **tiny** | typo, comment, docs wording, trivial config | one implicit line | cheapest relevant check or diff read | L1 | skip |
| **normal** | one-area feature or fix, easy to reverse | 1-5 written | targeted per AC; full suite once at the end | L1; L2 if risk is above trivial | if user-visible |
| **full** | cross-module, public API, auth, money, data, schema, migration | all written, mapped to the request | normal + integration or end-to-end + checks proven able to fail | L2; L3 if destructive or financial | required |
| **bug** | reported broken, failing or slow | AC-1 = original symptom reproduced, then cause and neighbors | red-green on the repro; regression test red on pre-fix state | L2 on the fix | if the symptom was visible |

Exact ceremony and report shape per lane: [references/verifier-independence-and-lanes.md](references/verifier-independence-and-lanes.md). Changing a check is at least normal: it changes what green means.

## 7. Loop limits

A loop needs a verifier **and** a safety exit. Defaults (starting values): at most 3 fix-and-recheck rounds per failing AC; a task budget (calls, minutes, spend) written before round one and counting the verifier; stop when the same failure signature appears twice, the failing set does not change, or fixes oscillate between ACs.

- After one repeated signature, change the **information** (narrower repro, instrumentation, reading the code path); never retry the same edit.
- Editing only checks, fixtures or timeouts while a code AC fails means no progress.
- Escalate with passing and failing ACs, attempts, evidence and one decision needed.
- Tier escalation: `model-effort-routing`; test failure classes: `playwright-qa-orchestrator`.

Signatures, the loop pseudocode, escalation template and the mapping of exits to states: [references/loop-limits-and-no-progress.md](references/loop-limits-and-no-progress.md).

### Never weaken a check to get green

Never delete, skip or loosen a check to get green (golden rule: `integration-tests`); also no regenerated snapshots, mocking the very behavior an AC is about, stale or cached output, or coverage offered as proof. The only legitimate change to a failing check is a proven check bug, recorded with its reason. Before trusting a new check, show it red for the right reason: revert-the-fix, or mutate then restore and diff against a pristine copy. Methods: [references/anti-cheating-and-weak-checks.md](references/anti-cheating-and-weak-checks.md).

## 8. Completion report

End every non-trivial task with exactly one state, then the evidence:

| State | Means |
|---|---|
| **Implemented** | Code or change written; checks not run, or only checks that cannot go red. |
| **Validated** | Every AC has a PASS row with fresh evidence and the lane's certification is done. |
| **Partially validated** | Some ACs PASS; the others are `UNVERIFIED` with reasons (could not run, budget, needs a human). |
| **Blocked** | A blocker outside your control stops progress; name it and the decision or access needed. |

```
State: Partially validated   Lane: normal   Certification: L1
AC-1 PASS  curl .../orders/42 (user B) -> "404"       14:02
AC-2 PASS  pytest -k test_price_de -> "1 passed"      14:03 (red on pre-fix code)
AC-3 UNVERIFIED  settings reload: no browser available
```

List the checks that ran, those that did not, and any exit that fired. Never write `Validated` over an `UNVERIFIED` row.

## 9. Neighbors (point, do not duplicate)

- `tdd`: owns red-green-refactor for writing tests; this skill certifies the result and proves the test can fail.
- `implement`: owns executing specs and tickets; run this loop at its verify step.
- `code-review`: owns diff review against standards and spec; the L2 verifier checks ACs and evidence.
- `playwright-qa-orchestrator`: owns browser QA, its no-cheating guardrails and failure classes.
- `model-effort-routing`: owns model tier, effort, delegation briefs, escalation tiers, budget guards.
- `skill-orchestrator`: owns start-of-task skill selection; this skill governs how a task ends.
- `clean-code-for-agents`: owns authoring-quality self-review; this skill owns proof of behavior.
- `diagnosing-bugs`: owns the feedback loop and finding the cause; this skill certifies the fix.
- `fundamentals-audit`: owns the audit and pre-fix safety rules; it feeds ACs here.

## Quick Decision Checklist

- [ ] Lane chosen and stated (worst dimension).
- [ ] ACs written before editing, each with a named check or marked `UNVERIFIED`.
- [ ] Every PASS row is from a run in this session after the last relevant edit.
- [ ] Output read, counts compared, secrets redacted, inference labeled.
- [ ] New or changed checks shown failing for the right reason.
- [ ] No check weakened, skipped, mocked away or satisfied by stale output.
- [ ] Someone other than the maker certified at the lane's level; the verifier edited nothing.
- [ ] User-visible behavior observed running.
- [ ] Caps, budget and no-progress exits respected; escalated when one fired.
- [ ] Report has one completion state, the checks run, and what was not verified.

## Deep references

- [Acceptance criteria and evidence ledger](references/acceptance-criteria-and-evidence-ledger.md) — read when writing ACs, filling the ledger, or deciding what counts as evidence.
- [Verifier independence and lanes](references/verifier-independence-and-lanes.md) — read when choosing the lane, briefing a verifier, or certifying delegated work.
- [Loop limits and no-progress](references/loop-limits-and-no-progress.md) — read when a loop repeats, a cap or budget is near, or you must escalate.
- [Anti-cheating and weak checks](references/anti-cheating-and-weak-checks.md) — read when a check passes too easily, before trusting a new test, or when tempted to edit a failing check.
- [Trigger evals](references/trigger-evals.md) — read when tuning the description or checking that this skill, not a neighbor, should fire.
- [Sources](references/sources.md) — read for the origin and retrieval status of a claim.
