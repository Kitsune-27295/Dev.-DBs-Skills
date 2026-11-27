# GitLab, January 2017: backup mechanisms that did not work

Sources: GitLab postmortem https://about.gitlab.com/blog/postmortem-of-database-outage-of-january-31/; GitLab incident report https://about.gitlab.com/2017/02/01/gitlab-dot-com-database-incident/; PostgreSQL pg_dump https://www.postgresql.org/docs/current/app-pgdump.html · Last verified 2026-11-27

## Sequence (as reported)

Spam-driven load disturbed the primary database; replication lagged and failed, and the secondary needed a manual rebuild. While clearing the secondary's data directory, an engineer ran the removal on the primary. The live incident report says about 300 GB shrank to roughly 4.5 GB and the removal was stopped at 23:27 UTC. The site was down about 18 hours; the data-loss window is 17:20 to about 23:30 UTC. Git repositories and wikis were stored separately and survived. Lost: at least 5,000 projects, 5,000 comments and roughly 700 user accounts.

## Why each protection failed (the postmortem's four recovery procedures)

| Mechanism | Failure |
|---|---|
| Daily `pg_dump` to S3 | The bucket was empty: the job ran 9.2 binaries against a 9.6 server and failed; failure emails were rejected because DMARC was not enabled, so nobody saw them |
| LVM snapshots | One daily for staging, not disaster recovery; the available ones were about 24 and about 6 hours old. The six-hour one was used, but copying it over slow disks took about 18 hours |
| Azure disk snapshots | Enabled for the NFS servers, not for the database servers |
| Replication (hot standby) | Meant for failover; it broke when WAL segments were removed before the secondary received them, and the secondary was then wiped for the rebuild |

WAL archiving was also not in use. The postmortem lists four numbered procedures; the common "five mechanisms" count is not confirmed by the page read, so do not repeat it.

The postmortem's remediation list includes Prometheus monitoring for backups, point-in-time recovery with continuous archiving, hourly LVM snapshots, Azure snapshots of the database servers, automated testing of backup recovery, clearer host labels in the shell prompt, and an owner for data durability.

## Lessons relevant to a small project

1. A backup job that exits quietly is not proof of a usable backup; the failure was silent. Monitor it and test restores.
2. Replication is not a backup: it copies mistakes and can be disturbed by the same incident.
3. A backup on the same server or account as the data can die with it (the lesson's rule).
4. `pg_dump` can dump older servers (the docs say back to 9.2) but refuses a server newer than itself, which matches the GitLab failure; check versions.
5. Someone must own durability, or no one does.
6. "If you never restored it, you do not know it works": the postmortem supports the substance.

## Example: check the dump tool version (own sketch)

```
server_ver=$(psql "$DB" -Atc "show server_version_num")
dump_ver=$(pg_dump --version)       # compare major versions; abort if the dump tool is older
```

## How an agent should apply this

- Inventory every backup mechanism and for each ask: where does it write, who is alerted when it fails, has it been restored.
- Treat replicas and snapshots meant for other purposes as not-backups unless a restore proves otherwise.
- Verify the dump tool version is not older than the server in the script.
- Cite GitLab as the reported case; do not claim the cause for the owner's system.
- Name an owner and a schedule for the restore test in the runbook.
