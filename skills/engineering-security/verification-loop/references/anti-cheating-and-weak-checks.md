# Anti-Cheating and Weak Checks

Sources: https://en.wikipedia.org/wiki/Mutation_testing · https://en.wikipedia.org/wiki/Test_oracle · https://martinfowler.com/bliki/TestCoverage.html · https://google.github.io/eng-practices/review/reviewer/looking-for.html · Last verified 2026-11-27

## The problem

A green result only means something if the check could have been red. Four public sources frame it from different angles:
- Google's review guidance asks reviewers whether a test would actually fail when the code breaks and whether it could give false positives later.
- Fowler's note on test coverage argues that coverage tells you which code is not exercised, not whether the tests are meaningful, and names tests without assertions as the extreme case that executes code and verifies nothing. He also distrusts targets, which invite gaming.
- Mutation testing makes the question executable: small changes (mutants) are applied to the code; if the tests still pass, the mutant survived, which usually means a gap in the tests. Some mutants are equivalent (no test can distinguish them), so a survivor needs a human or agent look, not an automatic verdict.
- The test-oracle literature states the underlying issue: a test needs a source of the correct answer. Derived oracles (earlier behavior, snapshots) assume the earlier behavior was right; partial oracles check only some properties; implicit oracles (it did not crash) are weak.

An agent under pressure to finish is the most likely author of a check that cannot fail. The rules here keep the check honest.

## Taxonomy of weak or cheated checks

| Pattern | What it looks like | Why it proves nothing |
|---|---|---|
| Vacuous test | no assertion, `assert True`, asserting only that no exception was thrown | passes whatever the code does |
| Weakened assertion | exact value replaced with "not null", "length > 0", broader regex, looser tolerance | passes for wrong output too |
| Deleted or skipped check | test removed, `.skip`, `xfail`, commented out, filtered from the run | the failing signal disappeared |
| Raised limit | timeout, retry count or threshold increased until green | hides slowness or flakiness |
| Expectation edited to match output | snapshot or golden file regenerated after a failure with no review | the oracle now mirrors the bug |
| Mocked-away behavior | the unit under test, or the real boundary, replaced by a stub that returns the expected value | tests the mock |
| Tautology | expected value computed by the same code path or formula under test | cannot disagree with itself |
| Stale output | a result from before the last edit, a cached run, a different branch or environment | does not describe the current code |
| Wrong target | the check runs but not on the changed code (other package, other config, old build) | green is about something else |
| Proxy substitution | "build passes" or "types check" offered as proof of behavior | the property was never exercised |
| Narrowed scope | running only the tests that already passed | the failing ones were never run |

Rule: **never weaken a check to get green.** The only legitimate edit to a failing check is when the check is wrong, proven by evidence (spec, an independent oracle, a reproduction), recorded in the report with the reason. If you cannot prove the check wrong, the code is wrong or the AC is ambiguous: fix the code or escalate. For browser tests the same rule is owned by `playwright-qa-orchestrator` (its INTEG guardrail); this file generalizes it to any check.

## Prove the check can go red

For every new or changed check that certifies an AC, show it failing for the right reason before relying on its green. Choose the cheapest method that applies.

**Method 1: revert-the-fix (regression tests).** Run the new test on the pre-change code: it must fail with the symptom described by the AC. Then restore the change and run it again: it passes. (`tdd` owns the red-green discipline for writing it; this is the certification step.)

**Method 2: mutate, then diff against a pristine copy.** Use when no pre-change state exists or the test covers old behavior.

1. Save a pristine copy of the file(s) you will mutate (copy to a scratch directory, or rely on the version-control diff; the point is a restore source you trust).
2. Apply one small mutation in the code under test that should break the AC: flip a comparison, return a constant, skip the guard, swap an argument, remove the call.
3. Run only the check. Expect FAIL, with a message tied to the AC. Record the failing line in the ledger.
4. Restore from the pristine copy, then **diff the working file against the pristine copy and confirm no differences**. Never "undo by hand" without the diff.
5. Re-run the check: PASS. Record both runs.

If the check stays green under the mutation, it is vacuous or aimed at the wrong target: strengthen it before using it.

```
mutation: if (age >= 18) -> if (age >= 0)      # code under test
run   pytest -k test_adult_gate  -> expected FAIL, got "1 passed"   # check is weak
fix   add case age=17 expecting rejection
run   pytest -k test_adult_gate  -> "1 failed ... expected False"   # red for the right reason
restore + diff clean + rerun   -> "1 passed"
```

**Method 3: independent oracle.** Compute the expected value by a different route (a hand-worked value from the spec, a reference implementation, a metamorphic property such as "a narrower filter returns no more rows") and assert against that, not against the code's own output.

**Method 4: negative control.** Feed the check a deliberately wrong input or environment (wrong user, empty fixture, stopped service) and confirm it reports failure instead of silently passing.

Do not leave a mutation in the tree, do not run mutations against shared or production environments, and do not mutate files you do not own. If a mutation might be destructive, do it in a scratch copy.

## Staleness and wrong-target checks

- Re-run after the last relevant edit; never carry a result across edits or across branches.
- Confirm the check ran the code you changed: look for the new test name in the output, the changed file in the coverage list, the right build target. "0 tests ran" and "1 skipped" are not PASS.
- Read counts, not only the exit code: expected N tests, saw N.
- For nondeterministic checks, repeat to separate flaky from failing; a pass-on-retry is flaky, not green (`playwright-qa-orchestrator` owns the classification for UI tests).

## Mocks, snapshots and generated expectations

Mocking the boundary is legitimate when the boundary is not what the AC is about. It is cheating when the AC is about the boundary (an API contract, a database constraint, a permission rule): then verify against the real thing or a faithful local equivalent, and state which. Snapshots and golden files are derived oracles: regenerate only when the new output is reviewed and the change is intended, and quote the diff of the golden file in the ledger.

## Coverage is not evidence

Use coverage to find unexercised code, not to certify behavior. Fowler's note calls high targets a gaming risk. Report coverage only as "lines the check never touched", never as "the AC is met".

## How an agent should apply this

- Before certifying with a new or edited check, show it red once for the right reason (revert-the-fix or mutate-then-restore), and record both runs.
- After any mutation, diff the file against the pristine copy and re-run the check green; leave the tree exactly as the task needs it.
- Reject, in your own work and in review: deleted, skipped or loosened assertions, raised timeouts, regenerated snapshots without review, expectation edits to match output.
- Confirm the check hit the changed code and counts match expectations; treat "0 ran", "skipped" and cached output as not run.
- If you cannot prove a check wrong, do not touch it: fix the code or escalate under [loop-limits-and-no-progress.md](loop-limits-and-no-progress.md).
- For UI behavior, prove the check in a real browser run via `playwright-qa-orchestrator` instead of asserting on mocked responses.
