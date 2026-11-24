# Measure Before You Fix

Sources: https://sre.google/sre-book/emergency-response/ · https://sre.google/sre-book/managing-incidents/ · Last verified 2026-11-24 (method also drawn from a third-party skill read for ideas, no text reused; see sources.md)

## The problem

An alert that says "stale", "timed out" or "stuck for N hours" carries a number you can trust and a cause you should not. The reflex response (raise the timeout, split the job, rewrite the wrapper) is a change made on a theory. The SRE guidance on incidents says to prioritize stopping the damage and preserving evidence for the root-cause work; a measurement is the cheapest piece of evidence there is, and a premature change can destroy it (restarting a job clears the state that showed why it stalled).

## The time-boxed measurement

1. **Name the claim.** "Sync for tenant A is 14 hours behind." Write the entity, the metric and the threshold the alert used.
2. **Choose the budget first.** Two minutes for a quick step, ten for a heavier one. The budget stops measurement from turning into an investigation.
3. **Measure the named entity**, not the aggregate. A whole-system run hides which member is slow.
4. **Watch progress, not only the clock.** Choose one or two monotonic counters (rows written, bytes sent, queue length, last log line timestamp) and sample them at the start and end of the window. Elapsed time alone cannot tell slow from stuck.
5. **Record the raw numbers** in your notes: command, start, end, counters.

```
claim:     export job for report X exceeds 30 min budget
budget:    5 min observation
t0:        rows_written=120400  last_log=14:02:11
t0+5min:   rows_written=120400  last_log=14:02:11
reading:   no forward progress -> wedged candidate; check what it waits on
```

versus

```
t0:        rows_written=120400
t0+5min:   rows_written=151900  (about 6300 rows/min)
reading:   progressing; 400k rows remain -> about 40 min; needs more time
```

## Needs more time versus is wedged

| | Needs more time | Is wedged |
|---|---|---|
| Counters | advance | stuck |
| Resource use | busy (CPU, IO, network) | idle or blocked |
| Waits | none long | on a lock, a dead peer, a full disk, a closed pipe |
| Right fix | budget, batching, parallelism, a smaller unit of work | find and clear the blocker; restart if state is disposable |
| Wrong fix | restart (loses progress) | raise the timeout (hangs longer) |

A stall watchdog that keys on forward progress, not elapsed time, is the principled design; if you are asked to design one, that is the shape.

## Check the thresholds, then the alert path

Before declaring the system sick, compare the threshold of the alerting monitor with that of the system's own health check. A monitor may rightly act early (retry, nudge) while the authoritative check only warns much later. The defect appears when the monitor speaks at its act line: it pages repeatedly about a system that measures healthy. Separate two constants, one for acting and one for alerting, and set the alert at the owner's warn line or later. A recurring alert whose numbers sit below the owner's own warn line, on a resource that looks fine when queried, is a sign to suspect the threshold before the system.

## Check that "recovery in flight" is true

Alert text such as "no recovery in progress" or "retrying" is itself a claim. Look for the worker process, the queue entry or the lease. Also read the step's own output: "already up to date" means this step is not your bottleneck.

## Verdict template

```
Alert:      <text, emitting monitor>
Claim:      <entity, metric, threshold>
Measured:   <command> -> <duration or counters>
Budgeted:   <timeout values including call-site overrides>
Thresholds: monitor act line vs owner's warn line -> match | mismatch
Verdict:    needs more time | wedged | false page | genuine regression
Fix:        <change sized to the measured number, or "none; adjust the alert">
```

Only after this block is a fix proposed. A genuine regression moves to `diagnosing-bugs` with the measured number as its first fact; confirming the fix is `verification-loop` (re-run the same measurement).

## Anti-patterns

- Revising a theory twice without a new measurement between revisions.
- Persisting a root cause you have not measured as a rule or a note; a confident wrong diagnosis in a runbook outlives the bug.
- Restarting first "to see if it helps", which clears the evidence.

## How an agent should apply this

- Refuse to propose a timeout, schedule or pipeline change until one time-boxed measurement of the named entity is in hand.
- Record two samples of a monotonic counter; call the result "needs more time" or "wedged" using those, not the clock.
- Compare the alert's threshold with the owning system's own; if it speaks below the owner's warn line, fix the alert.
- Read the alert's own numbers for contradictions before building a theory.
- End with the verdict block and the measured number that sizes the fix.
