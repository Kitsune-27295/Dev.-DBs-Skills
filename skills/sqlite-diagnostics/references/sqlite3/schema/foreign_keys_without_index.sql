-- Foreign keys whose referencing columns, in the same order, are not the leading columns of any non-partial index
-- (PRAGMA foreign_key_list with index_list and index_info). Read-only: a SELECT. Without that index every delete or update of
-- the parent row scans the child table. A single INTEGER PRIMARY KEY column is the rowid and counts as covered.
-- An index with the same columns in another order is reported: SQLite can use it only for some lookups.
WITH fk AS (
    SELECT
        t.name AS tableName,
        f.id AS foreignKeyId,
        group_concat(f."from", ', ') AS columnsList,
        min(CASE WHEN f.seq = 0 THEN f."from" END) AS firstColumn,
        count(*) AS columnCount
    FROM pragma_table_list AS t
    CROSS JOIN pragma_foreign_key_list(t.name) AS f
    WHERE t.schema = 'main' AND t.type = 'table' AND t.name NOT LIKE 'sqlite_%'
    GROUP BY t.name, f.id
)
SELECT
    fk.tableName AS tableName,
    fk.foreignKeyId AS foreignKeyId,
    fk.columnsList AS referencingColumns
FROM fk
WHERE NOT EXISTS (
        SELECT 1
        FROM pragma_index_list(fk.tableName) AS il
        WHERE il.partial = 0
          AND (SELECT count(*)
               FROM pragma_foreign_key_list(fk.tableName) AS f2
               JOIN pragma_index_info(il.name) AS ii
                 ON ii.seqno = f2.seq
                AND ii.name = f2."from"
               WHERE f2.id = fk.foreignKeyId) = fk.columnCount
    )
  AND NOT (fk.columnCount = 1 AND EXISTS (
        SELECT 1 FROM pragma_table_info(fk.tableName) AS ti
        WHERE ti.name = fk.firstColumn AND ti.pk = 1 AND upper(ti.type) = 'INTEGER'))
ORDER BY fk.tableName, fk.foreignKeyId
LIMIT 200
