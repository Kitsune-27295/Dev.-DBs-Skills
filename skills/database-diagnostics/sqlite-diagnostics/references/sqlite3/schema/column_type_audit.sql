-- Columns with a risky declared type: no type at all, or REAL/FLOAT/DOUBLE on a column whose name suggests money
-- (PRAGMA table_info). Read-only: a SELECT; the name match is a heuristic, so read each hit.
-- Money belongs in INTEGER cents or in TEXT holding a decimal, never in binary floating point.
SELECT
    t.name AS tableName,
    c.name AS columnName,
    c.type AS declaredType,
    CASE WHEN trim(c.type) = '' THEN 'no declared type'
         ELSE 'floating point on a money-like name' END AS finding
FROM pragma_table_list AS t
CROSS JOIN pragma_table_info(t.name) AS c
WHERE t.schema = 'main'
  AND t.type = 'table'
  AND t.name NOT LIKE 'sqlite_%'
  AND (trim(c.type) = ''
       OR (upper(c.type) IN ('REAL', 'FLOAT', 'DOUBLE', 'DOUBLE PRECISION')
           AND (lower(c.name) LIKE '%price%' OR lower(c.name) LIKE '%amount%' OR lower(c.name) LIKE '%total%'
                OR lower(c.name) LIKE '%balance%' OR lower(c.name) LIKE '%cost%' OR lower(c.name) LIKE '%fee%')))
ORDER BY t.name, c.cid
LIMIT 200
