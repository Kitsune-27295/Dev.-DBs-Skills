# Designing the restore test and the runbook

Sources: handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe section "Backup that comes back"; PostgreSQL pg_dump https://www.postgresql.org/docs/current/app-pgdump.html; PostgreSQL pg_restore https://www.postgresql.org/docs/current/app-pgrestore.html; GitLab postmortem https://about.gitlab.com/blog/postmortem-of-database-outage-of-january-31/ (remediation list) · Last verified 2026-11-27

## What the lesson asks for

- A daily `pg_dump` copy kept outside the server, with the last 7 daily and 4 weekly copies (handout rule).
- An automatic test that restores the latest copy into a separate database and checks the tables exist and the row counts of the main tables match production.
- A short runbook: how to restore, how long it takes, what you lose.
- No password inside the script; restore never targets production.

## Facts about the tools (docs read 2026-11-27)

- Custom (`-Fc`) and directory (`-Fd`) archives are restored with `pg_restore`; plain-text dumps run through `psql`. `pg_restore` also reads tar and detects the format itself.
- `pg_restore -d dbname` restores into that database; without `-d` it only writes a SQL script.
- `--create` creates the database from the name stored in the archive (the `-d` database is used only to issue the create), and `--clean` with it drops and recreates that name. Use these only on a throwaway server; on the production server they point at production.
- `pg_dump` takes a consistent snapshot without blocking readers or writers; only the directory format supports parallel dumps (`-j`), which opens extra connections.
- Dump output loads into newer servers; loading into an older one is not guaranteed.

## Test anatomy

```
1 dump:     pg_dump -Fc "$PROD_RO_URL" > backup-$(date +%F).dump ; record counts of key tables in counts.txt
2 ship:     copy to storage outside the database server/account
3 restore:  createdb restore_check ; pg_restore -d restore_check backup-....dump
4 compare:  select count(*) per key table; diff against counts.txt   # counts taken at dump time
5 report:   pass, or a named difference; alert on failure; drop restore_check
```
Row counts are a weak check (inference): add one business-level query (latest order date, a sum) when possible. Counts taken at dump time avoid false alarms from live writes.

## Recovery numbers to put in the runbook

- **RPO** (what you lose): everything since the last copy; with a daily dump, up to a day.
- **RTO** (how long): measure the restore time in the drill and write the real number. GitLab's copy path took about 18 hours; measuring beats guessing.
- Provider-managed backups: ask how far back they restore and try a restore.

## Scheduling and ownership

A single test proves nothing about next month. Schedule the drill and alert on failure (GitLab's list includes backup monitoring and automated recovery tests). The agent writes the scripts; the owner schedules and runs them; the agent runs nothing against production.

## How an agent should apply this

- Write the backup and restore scripts and the runbook; keep passwords out of them.
- Make the restore target an obviously separate database and refuse to run if the connection string matches production.
- Store key row counts next to each dump and compare after restore.
- Record the measured restore time in the runbook.
- Recommend a schedule and failure alert; leave scheduling to the owner.
