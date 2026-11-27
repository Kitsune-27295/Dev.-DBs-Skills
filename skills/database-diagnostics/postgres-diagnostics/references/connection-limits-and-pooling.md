# Connection limits, timeouts and pooling

Sources: https://www.postgresql.org/docs/current/runtime-config-connection.html · https://www.postgresql.org/docs/current/runtime-config-client.html · https://www.pgbouncer.org/features.html · Last verified 2026-11-24

Counting connections by state is the `connections_by_state` script; this file explains the settings behind the numbers.

## Limits

`max_connections` is fixed at server start (default usually 100) and the server sizes shared resources from it, so raising it costs memory. `superuser_reserved_connections` (default 3) keeps slots for administrators; `reserved_connections` (default 0) can reserve slots for a privileged role. A standby needs the same or a higher `max_connections` than the primary. The page does not give a per-connection memory figure, so do not quote one. Inference: many application instances each opening a pool can exceed the limit together; add up all pool sizes.

## Timeouts that prevent trouble

All four default to off (0).

| Setting | Effect | Note from the docs |
|---|---|---|
| `statement_timeout` | aborts a long statement | set per role or session; not recommended in the global config file |
| `lock_timeout` | aborts a wait for a lock | useful for DDL; pointless if not smaller than `statement_timeout` |
| `idle_in_transaction_session_timeout` | ends a session that idles inside a transaction | stops held locks and blocked vacuum |
| `idle_session_timeout` | ends an idle session with no transaction | poolers may mishandle closure; apply to specific roles |

```sql
ALTER ROLE app_user SET idle_in_transaction_session_timeout = '10min';
SET lock_timeout = '2s';  -- before a risky ALTER, in that session only
```

## Pooling

PostgreSQL itself has no pooler; an external one such as PgBouncer sits between. It has three modes: session (a server connection per client session, all features), transaction (assigned per transaction) and statement (autocommit only). In transaction mode its documentation lists features that do not work: `SET`/`RESET` session state, `LISTEN`, `WITH HOLD` cursors, SQL-level `PREPARE`/`DEALLOCATE`, temporary tables that persist and session-level advisory locks. Protocol-level prepared statements work only when `max_prepared_statements` is set above zero.

## How an agent should apply this

- When connection counts are high, check pool sizes across all instances before suggesting a larger `max_connections`.
- Recommend a pooler in transaction mode only after checking the code for session state, advisory session locks, `LISTEN` and prepared statements.
- Propose `idle_in_transaction_session_timeout` per application role when idle-in-transaction sessions appear in the results.
- Never propose changing server settings directly; hand the owner the statement.
