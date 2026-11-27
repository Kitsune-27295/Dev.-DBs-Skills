# Analyst Brief Template

Sources: https://sre.google/sre-book/managing-incidents/ · https://docs.pagerduty.com/ops-guides/incident-response-guide/incident-commander · Last verified 2026-11-24

## Why a written brief at all

A background agent has none of your session: not the files you opened, not the three things you already ruled out, not the unwritten rule that production is off limits. In human incidents the same gap shows up when someone joins late, which is why the SRE chapter on managing incidents puts so much weight on a live, shared incident document and on explicit handoffs: the new person must be able to act from the page, not from hallway context. The brief is that page, compressed to one screen. It also functions as the commander's statement of what the helper may and may not do, which the same chapter treats as essential (helpers who "freelance" with good intentions have turned outages into worse outages).

## The nine fields

1. **Symptom.** One or two sentences, observable, no cause. "Nightly import exits 0 but loads zero rows since Tuesday" beats "import broken because of the parser".
2. **Evidence.** The exact command, the exact error excerpt, a file and line, a commit, the environment. Remove secrets, tokens and personal data from excerpts before pasting. Mark anything paraphrased as paraphrase.
3. **Expected.** What a healthy run looks like, including how you know (a count, a status code, a prior run).
4. **Tried so far.** A list with the effect of each attempt: "reran with the cache cleared: same", "reverted last commit: same". Failed attempts are the cheapest information in the brief.
5. **Scope guess.** Where you would look first, and "unknown" when true. A guess is useful as long as it is labeled.
6. **Base commit.** The revision the symptom was seen on, plus uncommitted changes if any ("working tree dirty: one file"). Without it, the analyst may study a different version.
7. **Constraints.** What must not break; that the shared working tree is in use and must not be edited; no secrets; no destructive actions; no network calls to production systems; any budget.
8. **Deliverable.** Report as the final message; patch as a diff, not applied; the format of the report; where the lead will save them.
9. **Stop rule.** A time or step budget and the instruction to report "not found, here is what was ruled out" rather than ship a guess.

## A worked example

```
INCIDENT BRIEF
Symptom:       Integration test "orders_roundtrip" fails on CI since commit abc1234; passes locally.
Evidence:      CI log excerpt: "expected 3 rows, got 2" at tests/orders_test:88; fails 4 of 4 reruns; local pass 5 of 5.
Expected:      3 rows, as on the previous green CI run (commit def5678).
Tried so far:  Reran CI (same); pinned the dependency (same); local run with CI env file (still passes).
Scope guess:   Ordering of results or timezone handling; unknown.
Base commit:   abc1234 (clean tree).
Constraints:   Read-only on the main working tree; use an isolated checkout at abc1234 for experiments; no secrets; no production access.
Deliverable:   Final message with the report sections (symptom, root cause with proof, why it escaped, fix as a diff, prevention, blast radius, not verified).
Stop rule:     45 minutes or 25 tool calls; if no proven cause, report ruled-out theories and the next best experiment.
```

## Common mistakes

| Mistake | Effect | Fix |
|---|---|---|
| The brief states a cause ("the parser broke") | The analyst confirms it (anchoring) | State symptom only; put your theory in "Scope guess", labeled |
| No base commit | Analysis of the wrong revision | Always give it; note a dirty tree |
| Whole transcript pasted | Noise; the signal is buried; cost rises | One screen of facts |
| "Fix it" as the deliverable | The analyst edits the shared tree | Deliverable is a proposal and a diff |
| No stop rule | Unbounded spend, a guess presented as a finding | Budget plus permission to say "not found" |
| Secrets in the excerpt | Secrets copied into reports and logs | Redact before sending; tell the analyst to redact in the report |

## Handing over when the analyst needs more

If the report says "not found", read the ruled-out list before writing a second brief; add its findings to "Tried so far" and narrow the scope. Two failed analysts on the same brief is a sign the brief or the reproduction is wrong, not that you need a third.

## How an agent should apply this

- Write the brief from your own notes in under two minutes; fill all nine fields, "unknown" where true.
- State the symptom without a cause; label any theory as a guess.
- Always include the base commit and note uncommitted changes.
- Put "propose only, do not change shared files, do not run destructive commands" in Constraints.
- Redact secrets and personal data before pasting any excerpt.
- Give a stop rule and explicit permission to report "not found".
