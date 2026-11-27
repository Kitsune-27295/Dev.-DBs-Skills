# Vacuum, Bloat and Wraparound Concepts

Sources: https://www.postgresql.org/docs/18/routine-vacuuming.html, https://www.postgresql.org/docs/18/catalog-pg-class.html, https://www.postgresql.org/docs/release/18.0/ · Last verified 2026-11-24

Covers `tables/dead_tuples_autovacuum`, `tables/table_xid_age`, `databases/database_inventory` (xid and multixact age), `tables/table_sizes` and `maintenance/prepared_transactions`.

## Dead rows

`UPDATE` and `DELETE` leave old row versions in place. A plain `VACUUM` marks that space reusable but usually does not return it to the operating system. `VACUUM FULL`, `CLUSTER` and table-rewriting `ALTER TABLE` shrink files but take an `ACCESS EXCLUSIVE` lock and need about the table's size in temporary disk. The documentation prefers frequent plain vacuums over occasional full ones.

Autovacuum starts when dead rows exceed `min(autovacuum_vacuum_max_threshold, autovacuum_vacuum_threshold + scale_factor x reltuples)`. The max cap is new in 18; before it, a very large table waited for a percentage of its rows. Insert-heavy tables are also vacuumed on an insert threshold, so visibility maps and freezing stay current.

Reading `deadPct`: a high percent on a tiny table is noise; a large absolute `deadRows` with an old `lastAutovacuum` means autovacuum is not keeping up or is blocked. Blockers the docs name in the wraparound recovery steps: long transactions, forgotten prepared transactions, stale replication slots. Commands taking conflicting locks can also keep autovacuum from finishing. Autovacuum does not process temporary tables and does not analyze partitioned parents.

## Wraparound

Transaction IDs are 32-bit and compared in a circle: about 2^31 IDs are "older" than any given one, so rows must be frozen before they reach that age.

| Setting or limit | Value |
|---|---|
| `autovacuum_freeze_max_age` | 200 million by default; forces an anti-wraparound autovacuum even if autovacuum is off |
| `vacuum_freeze_table_age` | triggers an aggressive scan; effective max is 0.95 x `autovacuum_freeze_max_age` |
| Warning | about 40 million transactions before wraparound |
| Refusal of new XIDs | about 3 million before; reads still work |

`xidAgePctOfWraparound` in the scripts divides by 2,147,483,647. At the default setting a forced freeze starts near 9.3 percent, so about 10 percent means "forced freeze imminent", not "danger". Multixact age (`mxid_age(datminmxid)`) follows the same warning and refusal logic but only blocks writes that need a row-lock multixact.

18 adds eager freezing: a normal vacuum may freeze some all-visible pages early (`vacuum_max_eager_freeze_failure_rate`), reducing the next aggressive pass. `pg_class.relallfrozen` is the matching estimate.

Example (own illustration):

```
tableName: public.events  xidAge: 180,000,000  xidAgePctOfWraparound: 8.38
```

Close to 200 million: an anti-wraparound autovacuum is about to start. If the age keeps growing past it, find what holds the horizon back (prepared transactions, slots, long transactions) before blaming autovacuum settings.

## How an agent should apply this

- Rank xid findings by age against 200 million first and about 2 billion second; escalate hard only above 1 billion (own threshold) or when "to prevent wraparound" autovacuums repeat.
- Before proposing `VACUUM`, check `maintenance/prepared_transactions`, `replication/replication_slots` and `connections/long_running` for horizon blockers.
- Prefer per-table autovacuum parameters for one hot table over global changes; the owner applies them.
- Never propose `VACUUM FULL` without naming the exclusive lock and the space it needs.
- Report dead-row percent as an estimate and confirm bloat with a size trend from `tables/table_sizes`.
