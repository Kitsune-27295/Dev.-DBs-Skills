# Index Health Queries Explained

Sources: https://www.postgresql.org/docs/18/catalog-pg-index.html, https://www.postgresql.org/docs/18/monitoring-stats.html, https://www.postgresql.org/docs/release/18.0/ · Last verified 2026-11-24

Covers `indexes/unused_indexes`, `duplicate_indexes`, `invalid_indexes`, `missing_fk_indexes`, `tables/seq_scan_heavy`, `io/cache_hit_ratio`.

## What the catalog fields mean

- `indisvalid = false`: the index may be incomplete. Writes still maintain it, queries cannot safely use it, and a unique one no longer guarantees uniqueness. The docs page does not mention `CREATE INDEX CONCURRENTLY`; that a failed concurrent build leaves such an index is standard behavior, not read from this page. `indisready` and `indislive` show how far a build or drop got.
- `indkey` lists table column numbers, key columns first, `INCLUDE` columns after (`indnkeyatts` marks the split); `0` stands for an expression kept in `indexprs`. `indpred` is the predicate of a partial index.
- `indisunique`, `indisprimary` and `indisexclusion` mark indexes that enforce a rule.

## Query-by-query reading

| Query | What it tests | Main pitfall |
|---|---|---|
| unused | `idx_scan = 0` since reset, unique and primary excluded | counters reset on crash; replicas count separately; month-end jobs |
| duplicate | same table, columns, opclasses, collations, expression and predicate | exact matches only: `(a)` next to `(a, b)` is not reported |
| invalid | `NOT indisvalid` | needs drop and rebuild; the skill only proposes |
| missing FK index | FK columns not leading in any valid, non-partial index | a rarely changed parent may not need one; it matters when parent deletes or key updates are frequent |
| seq scan heavy | `seq_scan` against `idx_scan` on big tables | a full-table report job is legitimate |

`idx_scan` counts index searches, so it can exceed the number of queries (array lookups, 18 skip scans). 18 skip scans also let a multi-column index serve queries that omit its leading column, so on 18 an index looking redundant or unused by column order deserves a second look (own inference).

Cache hit is hits over hits plus reads in shared buffers only; the operating system cache hides further reads, so a lower figure is not automatically slow and a high one is not proof of health.

Example (own illustration):

```
indexNames: {idx_orders_cust, idx_orders_cust_2}  duplicates: 2
```

Keep the one that backs a constraint or is referenced by the application, then propose `DROP INDEX CONCURRENTLY` for the other, with its size from `tables/table_sizes`.

## How an agent should apply this

- Require a long, representative reset window and a replica check before listing any index as droppable.
- For an invalid index, offer the owner both options, rebuild concurrently or drop, and cite the failed-build cause if a log shows it.
- Tie a missing-FK-index proposal to evidence (parent delete rate, child row count); design questions belong to `schema-and-constraints`.
- Send statement-level cost questions to `query-performance`; cross-database exposure and backup questions to `database-audit`.
- State that the duplicate script does not report prefix-redundant indexes.
