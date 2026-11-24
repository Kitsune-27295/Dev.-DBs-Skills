# GitLab, January 2017: five backup mechanisms, none dependable

Sources: GitLab postmortem https://about.gitlab.com/blog/postmortem-of-database-outage-of-january-31/; GitLab incident report https://about.gitlab.com/2017/02/01/gitlab-dot-com-database-incident/; video "Banco de Dados | Fundamentos para Vibe Coders #EP2" (mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI) chapter 08 28:48-30:37 · Last verified 2026-11-24

## Sequence (as reported)

Spam-driven load disturbed the primary database; the secondary fell behind on replication and had to be rebuilt by hand. While trying to clear the secondary's data directory, an engineer ran the removal on the primary. It was stopped within seconds, but about 300 GB had already shrunk to roughly 4.5 GB. The site was down about 18 hours and about six hours of database changes were lost; Git repositories and wikis were stored separately and survived.

## Why each protection failed

| Mechanism | Failure |
|---|---|
| Daily `pg_dump` to S3 | The bucket was empty: the job used PostgreSQL 9.2 binaries against a 9.6 server and failed; failure emails were rejected because of mail authentication settings, so nobody saw them |
| Azure disk snapshots | Enabled for the NFS servers, not for the database servers |
| LVM snapshots | Daily and meant for staging copies, not disaster recovery; a manual one about six hours earlier is what saved the day |
| Replication | Meant for failover; the secondary was the server being wiped in the rebuild |
| Restore path | Restoring from staging was slow (disks throttled, copy took about 18 hours) |

The postmortem's root causes for the slow recovery include: backup procedures had no owner and were not tested regularly. Its remediation list includes automated testing of backup recovery, monitoring for backups, hourly snapshots, point-in-time recovery, and naming an owner for data durability.

## Lessons relevant to a vibe-coder project

1. Success of the backup job is not proof of a usable backup; the failure was silent. Monitor it and test restores.
2. Replication is not a backup: it copies mistakes and can be disturbed by the same incident.
3. A backup that lives on the same server or account as the data can die with it (the video's rule).
4. Version mismatches between the dump tool and the server are a classic silent failure; check the tool's version against the server.
5. Someone must own durability, or no one does.
6. The video's framing: "if you never restored it, you do not know it works". The postmortem supports the substance.

## Example: check the dump tool version (my own sketch)

```
server_ver=$(psql "$DB" -Atc "show server_version_num")
dump_ver=$(pg_dump --version)       # compare major versions; abort if the dump tool is older
```

## How an agent should apply this

- Inventory every backup mechanism and for each ask: where does it write, who is alerted when it fails, has it been restored.
- Treat replicas and snapshots meant for other purposes as not-backups unless a restore proves otherwise.
- Verify the dump tool version matches the server in the script.
- Cite GitLab as the reported case; do not claim the cause for the owner's system.
- Name an owner and a schedule for the restore test in the runbook.
