# Destructive-Action Gate in Practice

Sources: https://about.gitlab.com/blog/postmortem-of-database-outage-of-january-31/ · https://sre.google/sre-book/emergency-response/ · Last verified 2026-11-27

## What the gate is for

A gate is a deliberate pause between "the agent decided" and "the system changed", placed only where the change cannot be cheaply undone. It exists because three things tend to be false at the moment of a destructive command, even when the person typing it is skilled: the target is what you think it is, a recovery path exists, and the scope is what you meant. The 2017 database outage written up by GitLab is a compact case of all three: a data directory was removed on the wrong server (target), none of the backup and replication mechanisms in place gave a quick, usable restore (recovery path), and the only copy that worked was hours old (scope of loss). The people involved were working a long incident late at night, which is exactly when a pause is worth the most and is least likely to happen unprompted.

## The card, field by field

| Field | What a good entry looks like | What a bad entry looks like |
|---|---|---|
| Action | The exact command, with flags | "clean up old data" |
| Target | Host, environment, database or path, plus the command that proved it (hostname, connection string without the secret, `pwd`, a count) | "the staging box" |
| Scope | Count, size, oldest and newest item, and how the list was produced | "some files" |
| Backup | "Nightly dump, last restore test 2026-11-02, restored in 40 min" or "never tested" | "we have backups" |
| Other copy | A named source and the cost to re-fetch it | "it is in the cloud" |
| What is lost | Data and the capability that goes with it ("billing exports for Q3") | "nothing important" |
| Blast radius | What breaks if the target is wrong or the filter is too wide | omitted |
| Rollback | Steps, owner, time | "restore from backup" with no owner or time |
| Safer option | A narrower or reversible alternative | omitted |

The point of "verified how" is that the card cannot be filled in from memory. If a field cannot be filled, that is the finding: report it and do not proceed.

## Recoverability is a measured property

Three tiers, in order of how much you can trust them:

1. A restore from this backup was performed and checked (row counts, a sample query, an application smoke test) within a recent window. Put the date on the card.
2. The backup job reports success. Weak evidence: in the GitLab case the daily dump job ran for a long time while the storage bucket stayed empty, because it was calling a client binary of the wrong version and the error notification was itself rejected by the mail layer. A green job and a usable file are different facts.
3. "It should be there": a replica, a snapshot taken for another purpose, a provider default. Treat as unverified. A replica copies deletions. A snapshot taken for staging may be the only recent copy and still be the wrong shape for recovery.

If the best available tier is 2 or 3, say so on the card and propose taking and checking a fresh copy before the action. Setting that up is `backup-restore-drill`.

## What a yes covers

The yes authorizes the card, not the topic. Write the action into the card exactly as it will be executed, and compare your next command to it before running. Typical drift to refuse and re-card: the glob grew from `logs/2025-*` to `logs/*`; the environment changed from staging to production; a loop now includes a second database; the command gained `--purge` or `--force`.

Pressure phrases to treat as no yes at all: "just do it", "whatever is needed", a thumbs-up on an earlier, narrower message, and approval given by a different person than the one who owns the data.

## Soft deletes and purges

Soft delete (a flag, a trash folder, a retention window) turns an irreversible act into a reversible one, so it is the preferred form after the yes. Two traps:

- A bulk soft delete can still be expensive to reverse. Restoring ten thousand rows one at a time, with relationships and counters, may take longer than the outage you were trying to avoid. Gate bulk soft deletes too, with a lighter card.
- A purge is the point of no return for the soft-delete safety net. Treat each purge as its own gated action. Purge one item at a time, confirm it is gone, and stop the batch at the first refusal or unexpected result. A purge batch that was interrupted stays interrupted until the human says to continue; report what finished.

## Logging after the fact

One short entry per executed destructive action: timestamp, what, how many, where, who said yes (role or message reference, not a secret), and the recovery path. Keep row contents and credentials out of the log. The log is for the next person who asks "where did it go?" and for the postmortem if something was wrong (`blameless-postmortem`).

## How an agent should apply this

- Inspect first, then draft the card from facts; leave a field blank rather than guess.
- Put "never tested" on any backup whose restore you have not seen, and offer to verify it first.
- Compare the final command to the card before running; any widening is a new card.
- After a yes, prefer move, rename or soft delete; run one item, check, then the batch, serially.
- Treat purge and force operations as separate gated actions even when the parent action was approved.
