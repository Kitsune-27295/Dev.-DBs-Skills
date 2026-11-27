---
name: backup-restore-drill
description: Use to set up or check database backups that really restore - inventory what exists, a daily backup script kept outside the server with a retention rule, a restore test into a separate database that compares row counts, and a short disaster runbook. Use when nobody has ever restored a backup, before a risky change, or when a provider's backups are assumed to work.
---

# Backup that comes back

A backup you have never restored is a hope, not a backup. The lesson's example is the 2017 GitLab database outage, where, by its own postmortem, finding and using the backups "failed completely"; only a six-hour-old snapshot not meant for disaster recovery saved the data. Database rules shared by every database skill: `database-audit`.

## Steps

1. **Inventory what exists today:** the provider's backups or your own, how often they run, where they are stored and **how far back in time** they can return. Done when each fact is written down or marked unknown.
2. **Daily backup script** (`pg_dump -Fc`, the custom format `pg_restore` reads; a plain `.sql` dump restores with `psql`; or the equivalent of the engine in use). The copy goes **outside the server** that holds the database, with the main tables' row counts stored next to it, and the retention rule keeps the last **7 daily** and **4 weekly** copies.
3. **Restore test:** restore the most recent copy into a **separate database** (`pg_restore` for a custom or directory archive) and check that the tables exist and that the **row count** of the main tables matches the counts stored with the dump. Done when the test prints a pass or a named difference.
4. **Runbook for the bad day:** a short step-by-step with how to restore, how long it takes and what you lose (everything since the last copy).

## Rules

- The restore always targets a separate database, **never in production**.
- No database password inside the script: use an environment variable or the provider's secret store.
- Run the restore test on a schedule, not once; a backup can silently stop working.
- Show the plan before creating files. The agent writes the script; the owner schedules it. The agent itself runs nothing against production.
- A managed database's own backups still need step 3: ask what its restore actually does and try it.

Source: the handout of the second database lesson of mano deyvin (prompt "backup that comes back"); the GitLab postmortem is cited there.

## Quick Decision Checklist

- [ ] Have I written down what backups exist, how often, where, and how far back they can return?
- [ ] Does the backup copy live outside the server that holds the database?
- [ ] Are the main tables' row counts stored next to each dump?
- [ ] Does the restore go into a separate database, never into production?
- [ ] Is the database password kept out of the script (environment variable or secret store)?
- [ ] Is the restore test scheduled rather than run once?
- [ ] Have I shown the plan first, leaving scheduling to the owner and running nothing against production?

## Deep references

- [Sources and caveats](references/sources.md) — when you must check which claims were verified and which are the lesson's own
- [GitLab 2017 backup failures](references/gitlab-2017-backup-failures.md) — when you assess which backup mechanisms are real
- [Restore test design](references/restore-test-design.md) — when you write the restore test, runbook or schedule
