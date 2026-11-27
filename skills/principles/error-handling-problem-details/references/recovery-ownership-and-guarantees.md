# Recovery Ownership, Exception Guarantees and Visible Reporting

Sources: https://en.wikipedia.org/wiki/Exception_safety · http://www.gotw.ca/gotw/059.htm · https://erlang.org/download/armstrong_thesis_2003.pdf · https://www.erlang.org/doc/system/sup_princ.html · https://en.wikipedia.org/wiki/Design_by_contract · Last verified 2026-11-27

Ideas drawn from a third-party skill read for ideas only, with no text reused, and checked against the originals below. Meyer's contract paper was reachable only as a scanned PDF, so the contract points rest on the Design by Contract overview, not on Meyer's text.

## 1. Every failure needs an owner of recovery

Catching an error limits how far it propagates; it does not undo what the failed operation already did. Only the owner of the affected state can decide what is safe afterwards. For each failure path, state in the owning API's documentation:
- who handles it, and who reports it (often different parties);
- what is contained and what is not;
- what holds afterwards: invariants valid, and the effect absent, partial, committed or unknown;
- who cleans up.

If nobody can answer "who owns this state", do not continue as if nothing happened. Choose one of three exits: recover in the owner, stop the dependent work, or escalate to a supervisor that discards the damaged state and restarts it.

Armstrong's thesis (section 4.3.1, re-read 2026-11-27) frames this as the "let some other process fix the error" philosophy: an error is what the programmer did not anticipate, so the failing unit stops and a supervisor, which holds the restart policy, decides what to do. The Erlang supervision docs show the mechanics: a supervisor starts, monitors and restarts children, with a restart strategy (default one_for_one) and a restart intensity and period (defaults 1 and 5 seconds) so a crash loop ends instead of spinning. Translate the idea, not the runtime: in other stacks a worker pool manager, job queue or process orchestrator plays the supervisor.

## 2. Exception-safety guarantees (state them)

The levels named on the Wikipedia article (the Abrahams and Sutter attributions come from the GotW page, which could not be re-fetched on 2026-11-27), apply to any operation that can fail midway:

| Guarantee | Meaning after a failure |
|---|---|
| no-throw | the operation cannot fail |
| strong (commit or rollback) | state is unchanged |
| basic | invariants hold and nothing leaks, but state may have changed |
| none | no promise; treat the object as unusable |

Rules of thumb (own synthesis): prefer strong for small in-memory updates (build a copy, then swap); settle for basic when copying is too costly, and say so; a function that writes several external systems has at best "unknown" for some of them, and must report that outcome. Never claim a rollback or a safe retry that the guarantee does not support. Meyer's contract view complements this: a failure is a broken contract (precondition, postcondition or invariant), so document which clause failed.

## 3. Logging is not recovery

Writing a log line and carrying on is a decision to continue with possibly invalid state. A log entry is evidence for people; it neither restores an invariant nor informs the caller. Acceptable uses: logging at the owner that also recovers or reports; logging once with a correlation id where the error is finally handled. Reject: `catch (e) { log(e) }` followed by normal flow, and log-and-rethrow at every layer (duplicate noise).

## 4. Typed failures, not parsed messages

Expected failures carry a declared type or code, a stable discriminant, and the details handling needs (which field, which resource). Preserve the cause chain; keep machine identity separate from display text; never branch on message text. Unexpected defects (an impossible `switch` branch, a violated invariant) stay plain exceptions: containment must never convert them into success. This aligns with the problem-details `type` and a total error-to-response mapping in the parent skill.

## 5. Visible, honest reporting

A final report states what operation failed, the impact, the system's disposition (stopped, degraded, retrying, state discarded) and a safe next action. When state is untrusted or an outcome is unknown, say so; persistent invalid state needs persistent visibility (a banner or status, not one log line). Keep sensitive internals out of user-facing text and localize through the app's own locale mechanism. The error reporter itself needs an independent fallback, because the failing component may be the one that reports.

Retries need safe repetition (idempotency), a cancellation path and a named owner; finite work gets a budget, long-lived supervision gets a lifecycle and observable degradation.

```text
try: charge(order)
except Timeout:                       # outcome unknown, not "failed"
    mark(order, "payment_unknown")    # persistent, visible state
    schedule_reconcile(order)         # owner of recovery
    return report(unknown=True, next="we will confirm shortly")
```

## How an agent should apply this
- For each catch block, name the recovery owner; if absent, stop, discard or escalate instead of logging and continuing.
- Write the guarantee (none, basic, strong, no-throw) next to any multi-step mutation and verify the state after failure in tests, not merely that an exception was caught.
- Replace message parsing with typed failures; keep defects distinct from expected failures.
- Report unknown outcomes as unknown; never present success, rollback or safe retry without the guarantee.
- Pair with the parent skill's RFC 9457 mapping and leak rules for the HTTP boundary.
