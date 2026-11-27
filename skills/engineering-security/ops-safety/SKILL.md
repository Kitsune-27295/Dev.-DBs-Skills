---
name: ops-safety
description: "Two operational disciplines for agents. (1) A destructive-action gate: before rm, drop, truncate, purge, force-push, bulk delete or any production write, stop and show a recoverability card (what is lost, is there a verified backup and restore path, blast radius, rollback) and wait for an explicit human yes; a written convention is not enforcement. (2) Measure before you fix: for slow, stale, stuck or timed-out alerts, time-box one measurement before changing any timeout or code, and tell needs more time apart from is wedged. Not for installing hooks that block git commands (`git-guardrails-claude-code`) or proving backups restore (`backup-restore-drill`). Use when about to run a destructive or irreversible command, touch production data, or answer a freshness, timeout or stuck-job alert."
---

# Ops Safety: Gate Destruction, Measure Before Fixing

One idea: an operation you cannot undo needs a human decision made with the facts on the table, and an alert about time needs a stopwatch before it gets a fix. Both are cheap to do first and expensive to skip. The incidents behind them (a wiped production data directory with no usable quick restore; fleets of machines sent to disk erasure by an automation that read an empty filter as "everything") are in [references/sources.md](references/sources.md).

Boundary: this skill is the decision gate and the first measurement. Setting up and testing backups belongs to `backup-restore-drill`; blocking git commands mechanically belongs to `git-guardrails-claude-code`; force-push mechanics belong to `git-atomic-commits`; who can reach which table belongs to `database-exposure`; schema changes and environment separation belong to `migrations-and-environments`; proving the fix worked belongs to `verification-loop`; root-causing a real defect belongs to `diagnosing-bugs`.

---

## 1. Be honest about what this is

This skill is a convention: text an agent reads and chooses to follow. It does not stop a command. If the skill is not loaded, or the agent ignores it, the command runs.

| Layer | What it can do | Where it lives |
|---|---|---|
| This skill | Make the careful path the default; produce the card and the yes | Agent instructions |
| Permission rules | Ask or deny a command class before it runs | The agent harness settings |
| Hooks | Inspect a command and refuse it, with a reason | Harness hooks (see `git-guardrails-claude-code`) |
| Platform controls | Make the damage small or reversible: separate credentials, read-only roles, backups, snapshots, object versioning, delete protection | Database, cloud account, repository settings |

Say this in the first sentence of any gate message when the stakes are high. If a destructive action matters enough to gate, ask whether the next layer down should enforce it. Detail: [references/enforcement-and-wrong-target-guards.md](references/enforcement-and-wrong-target-guards.md).

---

## 2. When the gate fires

Stop before running any of these, and do not run them in the same turn as the card.

| Class | Examples |
|---|---|
| Filesystem | `rm -rf` on a directory with data; deleting or overwriting more than about ten files; bulk in-place edits; "cleanup" or "free up space" on data directories |
| Database | `DROP`, `TRUNCATE`, `DELETE` or `UPDATE` without a narrow `WHERE`; dropping an index, table or collection; any write to a production database; running a migration against production |
| Version control | Force-push, `reset --hard` over unpushed work, deleting a remote branch or tag, history rewrite on a shared branch |
| Cloud and infrastructure | Deleting a volume, bucket, snapshot, backup or environment; resizing or replacing a stateful instance; rotating or deleting a credential in use |
| Automation | Any loop or script that applies one of the above across many targets, or whose target list comes from a query that could come back empty or too wide |
| "Soft" deletes | A bulk soft delete, and above all the purge that makes it permanent |

There is no category of data that is disposable by default. Caches, logs and build output have each been someone's only copy. Disposability is a property of the specific target, shown by inspecting it (what reads it, whether it is regenerable and at what cost), never of its category.

---

## 3. The recoverability card

Inspect the real target first (listing, count, size, what references it, version-control history, which host and environment you are on). Then show this and end the turn:

```
DESTRUCTIVE ACTION - confirmation required
Action:      <exact command or operation>
Target:      <host / environment / database / path / ids>   (verified how: <command run>)
Scope:       <count of items, size, oldest and newest item>
Reason:      <why it is needed now>

Recoverability
  Backup:    <none | exists> - last verified restore: <date and method, or "never tested">
  Other copy:<version history / snapshot / replica / re-fetchable from <source> (cost, time)>
  Verdict:   <recoverable | partly | NOT recoverable>
What is lost: <data and capabilities that disappear; what depends on them>
Blast radius: <who and what is affected if the target is wrong or the scope is wider than intended>
Rollback:  <exact steps, who runs them, how long they take; or "none">
Safer option: <narrower scope, dry run, rename or move instead of delete, snapshot first>
Proceed? Reply "yes" to run exactly the action above.
```

Rules for the card:

- "A backup exists" is a claim, not a fact, until a restore from it has been seen to work. A backup nobody has restored goes on the card as "never tested". See `backup-restore-drill`.
- A replica is not a backup: it replicates the deletion.
- Name what you could not verify. "I could not confirm which host this shell is on" is a line on the card, and it blocks the yes.
- Offer a safer option every time (dry run, narrower filter, move to a holding location, snapshot first).

---

## 4. What counts as a yes

- Only an explicit, specific yes to this card counts. "ok", "sure", "sounds good", or silence do not.
- A yes covers exactly the action on the card. A wider scope, a different target or a changed command needs a new card.
- A request for a nearby goal is not consent ("clean the repo" is not a yes to dropping database rows; "free some disk" is not a yes to deleting a data directory).
- A flag such as `--force`, `--yes` or `--confirm-destructive` confirms that the agent is sure. It is not the human's consent. Present the card anyway.
- A "no", a question or a "wait" stops everything. Answer, then show the card again if still relevant.
- Time pressure and "the disk is full right now" do not waive the gate. They make the card shorter, not optional.

---

## 5. After the yes

1. Re-check that the target is the one on the card (host, environment, path) immediately before running. State and shells change between turns.
2. Prefer reversible forms: move to a holding area with an expiry, rename, soft delete, or snapshot first. Delete for real in a later step.
3. Run narrow first: a dry run, or one item, then confirm the effect before the batch. Run batches serially, stop at the first surprise, and never retry a half-failed destructive batch blindly.
4. Write a short log entry: what, how many, where, when, recovery path. Do not paste secrets or row contents.
5. Verify the outcome with a fresh read (`verification-loop`) and say what was deleted and what was not.

For force-push use `--force-with-lease` with an explicit expected value, never plain `--force`; see `git-atomic-commits`. A lease protects against overwriting commits you have not seen. It does not make the push reversible.

---

## 6. Measure before you fix

Alerts that make a temporal claim (stale, timed out, stuck, N hours behind, slow) invite an instant structural fix: raise the timeout, split the step, rewrite the wrapper. Take one measurement first. It is almost always cheaper than the fix and often kills the theory.

1. **Read the alert's own numbers.** They often contradict the theory (no lock held means it is not lock contention). The number is reliable; the cause attached to it is a guess.
2. **Time-box one measurement** of the specific thing the alert names, not the aggregate. Pick the budget before you start (for example two minutes), run the smallest unit that could be slow, with a clock and with progress visible (rows, bytes, queue depth, log lines).
3. **Compare measured to budgeted.** Find every timeout on the path, including per-call overrides that make the default irrelevant.
4. **Compare the alert's threshold with the authoritative one.** An alert that speaks at the line where a monitor acts, rather than at the line where the owning system warns, pages forever about a healthy system.
5. **Decide the verdict, in one of four words:**

| Verdict | Evidence | Fix direction |
|---|---|---|
| Needs more time | Forward progress while you watch (counters move, the work finishes inside a longer budget) | Raise the budget, or make the work smaller or incremental |
| Is wedged | No forward progress across the time-box; same counter, same log line, idle CPU or blocked wait | Find the blocker (lock, dead peer, full disk, deadlock); more time makes it worse |
| False page | Step finishes quickly and the resource is healthy when queried | Fix the threshold or the alert, not the system |
| Genuine regression | Measured slow against a known baseline | Hand over to `diagnosing-bugs` with the number |

"Needs more time" and "is wedged" have opposite fixes. A bigger timeout on a wedged step only hangs longer; a restart on a slow-but-progressing step throws away work. Progress, not elapsed time, separates them.

6. Only now design the fix, sized against the measured number, and prove it with a before and after measurement (`verification-loop`).

Red flags that you are theorizing: a root cause but no measured duration; a rewrite proposed before the step ran once; two revised theories with no new measurement between them; "no recovery in flight" taken at face value without checking that a worker is actually running. Detail and worked shapes: [references/measure-before-you-fix.md](references/measure-before-you-fix.md).

---

## 7. Anti-patterns

- Treating a backup, a replica or "it is in version control" as recoverable without checking the specific path.
- Running a destructive command on the host you assume you are on, without proving it.
- A cleanup script whose target list is computed at run time and never checked for empty or too-wide results. An empty filter that means "everything" is a classic fleet-wide incident.
- Counting a flag, a CI approval or "the user asked for cleanup" as the human's yes.
- Raising a timeout to fix a stall; rewriting a pipeline on an unmeasured theory.
- Writing the lesson down as a rule and calling the risk closed. A rule an agent can skip is not a control.

---

## Quick Decision Checklist

- [ ] Is the action destructive, irreversible, or a production write? If yes, no execution this turn.
- [ ] Did I verify the target (host, environment, scope) with a command, not an assumption?
- [ ] Does the card state backup status as "last restore verified" or "never tested"?
- [ ] Did I name what I could not verify, and offer a safer option?
- [ ] Did I get a specific yes that covers exactly this action?
- [ ] After the yes: re-checked target, ran narrow first, logged, verified with a fresh read?
- [ ] For high stakes: did I say this is a convention and point to the hook or permission that would enforce it?
- [ ] For a time alert: one time-boxed measurement of the named entity before any fix? Verdict in one of four words?

## Deep references

- [Destructive-action gate in practice](references/destructive-action-gate.md) — the card field by field, what a yes covers, soft deletes and purges, logging.
- [Enforcement and wrong-target guards](references/enforcement-and-wrong-target-guards.md) — convention versus enforcement, hooks and permissions, automation sanity checks, lessons from a production data-loss postmortem.
- [Measure before you fix](references/measure-before-you-fix.md) — the time-boxed measurement, progress versus elapsed time, threshold mismatch, verdict template.
- [Trigger evals](references/trigger-evals.md) — three should-trigger and three near-miss prompts.
- [Sources](references/sources.md) — URLs read, status, claims not adopted.
