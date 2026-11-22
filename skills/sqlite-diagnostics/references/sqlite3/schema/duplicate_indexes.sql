-- Indexes on the same table with exactly the same ordered key columns, sort order and collation, same uniqueness and the same
-- partial or full kind (PRAGMA index_list with index_xinfo). Read-only: a SELECT. Indexes with an expression key column are
-- left out because PRAGMA index_xinfo does not show the expression, so two different expressions could look equal.
WITH idx AS (
    SELECT
        t.name AS tableName,
        il.name AS indexName,
        il."unique" AS isUnique,
        il.partial AS isPartial,
        (SELECT group_concat(k.part, ',') FROM (
            SELECT x.name || ' ' || x.desc || ' ' || x.coll AS part
            FROM pragma_index_xinfo(il.name) AS x
            WHERE x.key = 1
            ORDER BY x.seqno) AS k) AS keyColumns,
        (SELECT count(*) FROM pragma_index_xinfo(il.name) AS x WHERE x.key = 1 AND x.cid = -2) AS expressionColumns
    FROM pragma_table_list AS t
    CROSS JOIN pragma_index_list(t.name) AS il
    WHERE t.schema = 'main' AND t.type = 'table' AND t.name NOT LIKE 'sqlite_%'
)
SELECT
    a.tableName AS tableName,
    a.keyColumns AS keyColumns,
    group_concat(a.indexName, ', ') AS indexNames,
    a.isUnique AS isUnique,
    a.isPartial AS isPartial,
    count(*) AS duplicates
FROM idx AS a
WHERE a.keyColumns IS NOT NULL
  AND a.expressionColumns = 0
GROUP BY a.tableName, a.keyColumns, a.isUnique, a.isPartial
HAVING count(*) > 1
ORDER BY a.tableName, a.keyColumns
LIMIT 100
