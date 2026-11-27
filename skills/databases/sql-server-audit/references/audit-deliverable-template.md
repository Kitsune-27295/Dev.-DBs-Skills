# Audit Deliverable Template (skill content, part of the sql-server-audit skill)

Sources: https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/back-up-and-restore-of-sql-server-databases · https://learn.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-checkdb-transact-sql · https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit · https://ola.hallengren.com/sql-server-backup.html · Last verified 2026-11-24

This file is reference text of the `sql-server-audit` skill: the shape an agent gives its deliverable when it runs an audit. The reader is an owner who must decide, so it leads with the verdict, ranks by risk, separates facts from assumptions and holds no statement the evidence ledger cannot back. The template is this skill's own design; the content rules about backups and repair come from the cited vendor pages.

## 1. Deliverable skeleton

```
# SQL Server audit - <instance alias>, <date>

## 1. Verdict (5 lines max)
Overall: <one sentence a manager can act on>
Top risks: F1 <title> (CRITICAL), F2 <title> (HIGH), F3 <title> (HIGH)
Healthy (do not touch): <3-5 items>
Decisions needed from the owner: <numbered questions>

## 2. Scope and context
Instance, version and edition, platform, uptime (sqlStartTime), AG role.
Databases in scope and tier. RPO/RTO per tier: <given | assumed>.
Collectors run, with dates and windows. Login used and its privilege level.

## 3. Findings (ordered by severity, then by risk per effort)
F1 ...

## 4. Positive findings

## 5. Coverage gaps
Area | what was not checked | cause | how to close it

## 6. Remediation plan
Now | Next change window | Backlog

## 7. Assumptions and open questions

## Appendix: evidence ledger, proposed change scripts
```

## 2. One finding

```
### F3 - Log backups missing for a database in full recovery   [HIGH | verified]
Area: backups and recovery            Evidence: E14, E15 (backup_status, window: now)
What we saw: database X is in full recovery; the last log backup is 9 days old.
Why it matters: realistic data-loss window is 9 days against an RPO of 60 min
  (assumed, see section 7); the log also keeps growing.
Compensating control: none found.
Recommendation: schedule log backups at an interval that meets the RPO and confirm
  a full backup exists as the chain base.
Proposed change: Appendix P3 (PROPOSED CHANGE, not executed).
Risk: low (adds I/O every interval); needs backup space of about <n> per day.
Rollback: disable the job.
Verify: new log backup rows appear in history at the interval; log reuse wait
  clears.
Applies to: all supported versions.
```

Rules for a finding:

- One issue per finding; related symptoms go under one finding with several evidence ids.
- Title states the problem, not the object name.
- The "why it matters" sentence ties to impact on the business or an owner fact. If you cannot, it is probably LOW or INFO.
- The recommendation says what and when; the proposed change block holds the script (shape in `evidence-and-safety-rules.md` section 8).
- Severity and confidence in the title line so a scan shows both.
- If the evidence is a counter, name the window in "What we saw".

## 3. Verdict wording

| Situation | Wording |
|---|---|
| Critical findings exist | "Not safe to continue unchanged: <the one thing>." |
| No critical, several high | "Operating, with material risks: <top two>." |
| Only medium and low | "Sound foundation; hygiene items below." |
| Large coverage gaps | "Partial audit: areas <x, y> not assessed; see section 5." Never a clean verdict with big gaps. |

## 4. Remediation plan rules

- **Order by risk removed per effort**, not by area. A one-hour log-backup schedule beats a week-long index project.
- **Three buckets.** Now (CRITICAL, and cheap HIGH), next change window (HIGH, and MEDIUM with dependencies), backlog (LOW, INFO, improvements that need measuring first).
- **One change per step**, each with an owner role, a prerequisite, a rollback and a verification. No bundles.
- **Protect first.** Any step that can lose data is preceded by a backup that has been proven to restore (use `backup-restore-drill`) or by a step that creates one.
- **Repair is never step one.** When integrity errors exist, step one is to preserve the last good backups and plan a restore; the vendor page calls the data-loss repair level an emergency last resort and says restore is the primary method.
- **Measure what you change.** For performance items give the metric to compare before and after (a Query Store comparison, a wait delta over equal windows).
- **Dependencies visible.** If step 4 needs step 2, write it.
- **Time and risk honest.** Give an effort estimate in hours or days and the maintenance window needed; mark estimates as estimates.

Example plan lines:

```
NOW
1. F1 Schedule log backups for database X (est. 1 h, no outage, rollback: disable job)
2. F2 Back up the encryption certificate and key to separate storage (est. 1 h)
NEXT WINDOW
3. F5 Set an upper limit for max server memory (est. 15 min, effective at once;
   rollback: set the previous value; verify: memory counters over 24 h)
BACKLOG
4. F9 Replace shared application login with a per-application login mapped to a role
```

## 5. Tool outputs in the deliverable

- Cite a tool's output as evidence, with name, version and window; do not paste whole result sets.
- If the First Responder Kit or a maintenance solution produced the data, rate the items yourself; a tool's priority number is not a severity.
- When the recommendation is "run maintenance X", prefer the command preview mode of the maintenance solution so the owner reviews what would run.

## 6. Handoffs

| Finding type | Hand to |
|---|---|
| Restore never proven | `backup-restore-drill` |
| Exposure, grants, keys | `database-exposure` |
| Slow query design | `query-performance` |
| Constraints, types, orphans | `schema-and-constraints` |
| Generic safety around the fix | `fundamentals-audit` |

## How an agent should apply this

- Start the deliverable file with the skeleton on the first collector run and fill it as evidence arrives.
- Write the verdict last, but put it first.
- Check each finding has all fields before moving on; a missing rollback or verification means the proposed change is not ready.
- Include positives and gaps every time, even when short.
- Ask the owner the open questions at the top, not in an appendix.
