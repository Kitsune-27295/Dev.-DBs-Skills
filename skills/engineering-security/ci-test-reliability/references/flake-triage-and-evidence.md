# Flake Triage and Evidence

Sources: https://testing.googleblog.com/2020/12/test-flakiness-one-of-main-challenges.html · https://testing.googleblog.com/2017/04/where-do-our-flaky-tests-come-from.html · https://testing.googleblog.com/2016/05/flaky-tests-at-google-and-how-we.html · https://martinfowler.com/articles/nonDeterminism.html · https://docs.pytest.org/en/stable/how-to/tmp_path.html · https://jestjs.io/docs/cli · Last verified 2026-11-27

This file covers classification and proof for a flake. The generic loop (reproduce, minimize, hypothesize, instrument, fix, regression test) belongs to `diagnosing-bugs`; the evidence discipline belongs to `verification-loop`.

## Four places a flake can live

Google's 2020 post groups causes by component:

1. **The tests:** improper initialization or cleanup, wrong assumptions about test data or system state (the clock, for example), dependence on application timing, dependence on test order.
2. **The test-running framework:** too few resources for the system under test to start, tests scheduled so they collide, insufficient system resources.
3. **The system under test and its dependencies:** race conditions, uninitialized variables, slow or unresponsive services, memory leaks, oversubscription, services and tests changing at different paces. Hermetic environments (everything needed is inside) are less likely to flake.
4. **OS and hardware:** network instability, disk errors, resources consumed by unrelated tasks.

A commenter on that post makes a useful triage point (a reader's view, not Google policy): whether the failure is a real product failure matters most, because ignoring a real one lets a bug escape while the other three mostly cost time and compute.

## What the data says about where to look first

Google's 2017 post studied its corpus: flakiness rises with test size (reported 0.5% of small, 1.6% of medium, 14% of large tests flaky over a week), and RAM use and binary size correlate strongly with flakiness (r2 of 0.76 to 0.82 in the buckets reported). Tool choice matters (WebDriver and emulator tests were flakier) but size predicted more than tool. Practical reading for an agent: a flaky large or heavy test usually has more moving parts to isolate, so first ask whether a smaller test can carry the same assertion (`testing-pyramid-and-shapes`); results are from one company's corpus and are a prior, not a law.

Fowler's list of recurring causes: lack of isolation, asynchronous behavior, remote services, time, resource leaks. His resource-leak trick: shrink a pool to size one and make it throw when empty, so the first test after a leak fails and points at the culprit; the same "increase constraints so bugs surface" idea applies to a constant random seed.

## Triage procedure (own synthesis)

1. **Record the failure signature:** test id, OS cell, worker count and shard, order, seed, first-attempt result, error text, time of day.
2. **Compare first-attempt results across runs.** Flaky means both outcomes on the same commit. If always red on one cell, it is deterministic: an OS or config difference.
3. **Reproduce under the CI shape.** Same worker count, shard, OS, isolation setting and seed. Use `--runInBand` or an equivalent single-process mode only as a contrast run (it also changes timing and isolation).
4. **Bisect the interaction.** Run the file alone, with its previous neighbors, then with the full set; run the same test many times in a loop; randomize order if the tool supports it (`node:test --test-randomize` prints a seed and `--test-random-seed` replays it; the docs mark both Stability 1.0, early development, since v26.1.0).
5. **Classify** with the four components above and Fowler's five causes; write one sentence naming the shared resource, uncontrolled input or unsynchronized wait.
6. **Fix the cause** with the matching rule (allocation, restore, control, synchronization, teardown).
7. **Prove it** (below), then remove any retry or quarantine added during the investigation.

## Evidence that a flake fix is real

| Claim | Evidence |
|---|---|
| Race is fixed | A barrier forces the overlap and the test fails before the fix, passes after |
| Resource collision is fixed | Two independent test processes run concurrently and both pass; before the fix one collides |
| Global leak is fixed | A canary test run after the polluter fails before the fix and passes after; the global equals its original value |
| Teardown is complete | After the test, the port is free, the child is gone, the directory is removed (observed from outside) |
| Wait is correct | The test passes with the readiness signal artificially delayed |
| OS-specific fix | The previously failing OS cell is green, first attempt |

A stress loop (many repetitions) supports the claim but does not replace a deterministic regression: it can only show the absence of failures in the sample. A negative control for a new guard (temporarily introduce the rejected case and watch it fail) shows the guard can fail at all.

## Reporting template

```
Flake: <test id> on <OS/cell>
Signature: <error, first-attempt rate over N runs>
Cause class: <test|runner|SUT|OS> / <isolation|async|remote|time|leak>
Shared resource or unsynchronized wait: <one sentence>
Fix: <change> (no retry, no timeout increase) | reason if one is kept
Evidence: <commands run, before/after results, concurrent-process run>
Not verified: <cells or conditions not run>
```

## How an agent should apply this

- Start with the failure signature and the failing cell, not with a guess.
- Reproduce with CI-shaped parallelism before editing; use serial runs only as a contrast.
- Classify by component and by Fowler's cause list, then write the one-sentence cause before changing code.
- Pair each fix with the matching evidence row and say what was not verified.
- Remove temporary retries, quarantines and loops once the deterministic proof exists.
