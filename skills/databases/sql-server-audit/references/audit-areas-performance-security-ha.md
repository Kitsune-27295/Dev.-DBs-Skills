# Audit Areas: Indexes, Waits, Security and HA/DR

Sources: https://learn.microsoft.com/en-us/sql/relational-databases/indexes/reorganize-and-rebuild-indexes · https://learn.microsoft.com/en-us/sql/relational-databases/security/sql-server-security-best-practices · https://learn.microsoft.com/en-us/sql/database-engine/availability-groups/windows/overview-of-always-on-availability-groups-sql-server · https://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/ · Last verified 2026-11-24

Same format as [audit-areas-instance-and-recovery.md](audit-areas-instance-and-recovery.md): question, collector in `sql-server-diagnostics`, judgment, usual severity (this skill's own convention). Sections 4-7 are here.

## 4. Indexes and statistics

Collectors: `indexes/missing_indexes.sql`, `indexes/unused_indexes.sql`, `indexes/index_fragmentation.sql` (heavy), `queries/top_queries_*.sql`. Deep reading: `sql-server-diagnostics` `references/index-dmvs-and-reset-semantics.md`; design side: `query-performance`.

- **Missing-index suggestions** are optimizer hints since the last restart, capped and not persisted; they are leads for the top queries, never a to-do list. `heuristic` until a query that matters proves it.
- **Unused indexes** since a recent restart prove nothing; require a full business cycle of uptime before proposing a drop, and keep indexes that enforce uniqueness.
- **Fragmentation.** The vendor page says maintenance decisions should consider several factors in the workload and not be based on fixed fragmentation or page-density thresholds alone, notes that low page density often matters more than fragmentation, and that small indexes rarely benefit. Report fragmentation as INFO or LOW unless a measured query degradation correlates with it.
- **Statistics.** Rebuilds also refresh statistics with a full scan, which is often the real gain; updating statistics is far cheaper. A database with auto-update statistics disabled, or with no statistics maintenance on very large tables, is MEDIUM with `likely` confidence once a bad estimate is shown in a plan.
- **Maintenance jobs.** Check which job runs, with what parameters and when it last succeeded (`jobs/agent_jobs.sql`). A job that fails silently is a finding.

## 5. Waits, blocking, workload

Collectors: `waits/wait_stats.sql`, `io/io_by_file.sql`, `io/io_by_database.sql`, `memory/memory_overview.sql`, `deadlocks/deadlock_summary.sql` (heavy). Deep reading: `sql-server-diagnostics` `references/wait-stats-and-blocking-interpretation.md`.

- Waits always exist; the top non-benign waits indicate where to look, and there is no universal percentage that defines a problem. A wait type names a resource, not a root cause: follow each with one second check (plans for a parallelism wait, memory grants for a grant wait, file latency for page-read waits, the client for a network-output wait).
- Cumulative counters need a window. Use `sqlStartTime`; for a current picture take two snapshots a known time apart and subtract (own recommendation); the vendor page of the wait view says counters reset at restart.
- A persistent problem is `verified` only with a delta window or a second source (file latency, plan, Query Store). Otherwise `likely`.
- Deadlocks and long blocking are HIGH when they recur and affect a business path; MEDIUM when isolated.

## 6. Security

Collectors: `security/sysadmin_members.sql`, `security/sql_login_policy.sql`, `security/linked_servers.sql`, `config/service_accounts.sql`. Exposure outside the instance: `database-exposure`.

- **Sysadmin members.** Count and identity; service and application accounts in sysadmin are HIGH. The vendor page suggests considering a lower-privilege administrative grant for human DBAs, noting that sysadmin ignores denies.
- **SQL logins.** Weak or unchecked password policy, a built-in administrator login that is enabled and used, and shared logins are MEDIUM to HIGH. Prefer directory groups mapped to roles (vendor guidance).
- **Surface area.** Features that are enabled and unused (for example command-shell procedures) are MEDIUM; the vendor page advises against command-shell procedures in any environment.
- **Linked servers** that connect with a high-privilege fixed account are HIGH; with the caller's identity LOW.
- **Encryption.** Connection encryption and, from 2022, strict encryption; data-at-rest encryption for files and backups. Missing encryption is MEDIUM unless the compliance scope makes it HIGH. If a data-at-rest encryption certificate or key is not backed up and stored safely, the encrypted backups cannot be restored: HIGH to CRITICAL (own inference from the vendor statement that encrypted files cannot be read without the certificates).
- **Auditing.** Server-level audit in place, sensitive tables covered, backup and restore events captured: LOW to MEDIUM when absent, by compliance scope.
- **Injection surface.** Dynamic SQL built by concatenation in procedures is a code finding for `security-audit` or `schema-and-constraints` review, not an instance finding.

## 7. High availability and disaster recovery

Collectors: `ha/ha_status.sql`, `backup/backup_status.sql`, `jobs/agent_jobs.sql`.

- A secondary database is not a backup; backups are still required on the primary or an allowed secondary. A failover also does not occur because a database became suspect or its log corrupted. Both are statements from the vendor AG overview and each is a frequent wrong assumption.
- Check each replica: role, synchronization state, health, queue sizes, and that backups run on the replica the backup preference expects (otherwise no backup runs anywhere).
- Failover tests: "never tested" is MEDIUM; RTO unproven is `needs-confirmation`.
- Disaster recovery needs a copy outside the failure domain of the primary; absence is HIGH for a database with a stated RTO and RPO.
- Log shipping, mirroring, replication: confirm latency against the RPO.

## How an agent should apply this

- Walk areas in order 0 to 7, running only the collectors the question needs; record result and window per collector.
- Write each finding in the shape of the report template, with the severity from this page lowered or raised by named compensating controls or combinations.
- Treat every "typical" value you remember as unusable until a source or result shows it.
- When an area cannot be checked (permissions, managed service, no approval), list it as a coverage gap with the cause.
- Hand the owner the exact collector or proposed script for each open item; do not run changes.
