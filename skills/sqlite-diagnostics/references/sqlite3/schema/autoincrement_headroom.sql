-- Tables that use AUTOINCREMENT and how far the counter is from the 64-bit limit (sqlite_sequence).
-- Read-only: a SELECT. sqlite_sequence exists only after a table with AUTOINCREMENT was created: if this fails with "no such
-- table", the database does not use AUTOINCREMENT (see schema/object_inventory.sql). Reaching the limit is unlikely; a
-- jump in the counter after bulk deletes is the useful signal.
SELECT
    q.name AS tableName,
    q.seq AS lastValue,
    round(100.0 * q.seq / 9223372036854775807.0, 12) AS usedPct
FROM sqlite_sequence AS q
ORDER BY q.seq DESC, q.name
LIMIT 100
