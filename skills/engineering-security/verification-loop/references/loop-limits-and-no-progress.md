# Loop Limits, No-Progress Detection and Escalation

Sources: https://www.anthropic.com/research/building-effective-agents · https://code.claude.com/docs/en/best-practices · Last verified 2026-11-24

## What the sources say

Anthropic's "Building effective agents" describes the **evaluator-optimizer** workflow: one call produces, another evaluates and feeds back, repeat. It fits when evaluation criteria are clear and iteration measurably helps. The same article says agents should get ground truth from the environment at each step (tool results, code execution) to judge progress, may pause at checkpoints or stop when blocked, and commonly use stopping conditions such as a maximum number of iterations to stay in control; it also recommends testing in sandboxes because autonomy costs more and errors compound. Claude Code's best-practices page adds the practical side: give the agent a pass/fail check and it can keep going alone; the check can be enforced by a Stop hook that sends the agent back to work until the check passes or a block limit is reached; and background loops, goals and subagents keep spending requests while nobody is typing.

A loop with a verifier but no exit other than "the verifier passes" is a trap: a check that cannot pass, or a fix that cannot be found, spins forever. Every loop therefore needs a **verifier plus at least one safety exit**; no-progress detection catches the quiet failures a bare cap misses. (The five-exit table below is this skill's synthesis.)

## The five exits

| Exit | Rule of thumb (starting values, tune per project) |
|---|---|
| Verifier passes | All ACs in scope have PASS rows with fresh evidence. The only "success" exit. |
| Retry cap | At most 3 fix-and-recheck rounds per failing AC; at most 6 rounds for the whole task in normal, 10 in full. |
| Budget | A named ceiling on tool calls, wall-clock minutes and spend, set before the first round; spend of the verifier counts too. |
| No progress | Two consecutive rounds with the same failure signature, or an unchanged set of failing ACs after a change (below). |
| Human | Escalate when a cap, budget or no-progress exit fires, when an AC is ambiguous, or before any irreversible step. |

Whichever exit fires first wins. The numbers are defaults, not measurements: lower them for expensive checks, raise them only with a stated reason and the user's approval for the extra cost.

Tier changes and fallback on repeated substantive failure (one tier up, then a fresh top-tier pass, then stop and ask) are owned by `model-effort-routing`; the 3-attempt cap per failing test and failure classes are owned by `playwright-qa-orchestrator`. Use them as they are; this file only adds the AC-level counters.

## Failure signature and no-progress detection

A **failure signature** is the normalized core of a failure: the failing AC id, the check command, and the first error or assertion line with paths, numbers, timestamps and ids stripped. Keep one per round in the working notes.

Declare **no progress** when any of these is true:
1. Same signature in two consecutive rounds (the change did nothing to the failure).
2. The set of failing ACs is the same as two rounds ago (churn without movement).
3. **Oscillation**: fixing AC-a flips AC-b to FAIL and back (the model of the problem is wrong).
4. The only edits in a round were to checks, fixtures or timeouts, and not to the code under test (a sign of weakening; see [anti-cheating-and-weak-checks.md](anti-cheating-and-weak-checks.md)).
5. The round produced output you could not read (empty logs, truncated output) and you repeated the same command.

An identical third attempt after rule 1 is forbidden. The next move must change the *information*, not the code: reproduce more narrowly, add instrumentation (`diagnosing-bugs` owns the method), read the failing code path, or question the AC.

## The loop with its limits (pseudocode, own)

```
set budget (calls, minutes, spend); set rounds_left = 3 per AC
write ACs; run all checks once -> ledger
while any AC is not PASS:
    if budget exhausted:                       state = Blocked or Partially validated; escalate
    pick the FAILING AC with the clearest signature
    sig = signature(last failure)
    if sig == previous_sig[AC] or oscillating: escalate (no progress)
    one minimal change aimed at the root cause (not at the check)
    re-run that AC's check, then the checks that could regress  -> update ledger
    rounds_left[AC] -= 1
    if rounds_left[AC] == 0 and AC not PASS:  escalate for that AC
final: independent verification pass per the lane (see verifier-independence-and-lanes.md)
```

Cap loops that continue automatically (a goal condition, a Stop hook, a scheduled loop) with an explicit block or iteration limit: those run while nobody watches, which is exactly when a stuck loop burns money.

## When to stop and ask

Stop and put the question to the user when:
- an AC is ambiguous or two ACs conflict;
- the check needs credentials, data or an environment you do not have, or would affect production;
- a fix would require changing the check, the spec or the business expectation (see anti-cheating);
- the failure is environmental (service down, missing seed, expired auth) and not fixable inside the sandbox: repair it if it is yours, otherwise report;
- you have used the budget and the remaining risk is on a decisive AC.

Escalation message (keep it short, one decision):

```
ESCALATED: <task>
Lane: <lane>   Rounds used: <n>   Budget used: <x of y>
Passing: AC-1, AC-3     Failing: AC-2 (signature: <normalized line>)
Tried: <1 line per attempt, what changed in the information>
Evidence: <ledger rows or output excerpts, redacted>
Decision needed: <one question or choice>
```

## Mapping exits to completion states

| Situation when the loop ends | State |
|---|---|
| All ACs PASS with fresh evidence and the lane's verification pass done | Validated |
| Some ACs PASS, the rest `UNVERIFIED` (could not run, out of budget, needs a human) with reasons listed | Partially validated |
| Work written but no check run yet or only checks that cannot go red | Implemented |
| A blocker outside your control (access, missing decision, broken environment) stops progress | Blocked |

If any exit fires, the report names it ("stopped: no progress on AC-2 after 2 identical failures") instead of implying the task finished.

## How an agent should apply this

- Before round one, write the budget and the per-AC retry cap into your notes; stop at the first exit that fires.
- Record a failure signature every round and compare it with the previous one before editing anything.
- After one repeated signature, change what you know (narrow the repro, instrument, read), never retry the same edit.
- Count the verifier's work toward the budget and never extend a cap silently; propose the extension with its cost.
- Escalate with the template above and report `Partially validated` or `Blocked` honestly; a loop that ran out of budget is not a failure to report, hiding it is.
