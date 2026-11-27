-- Full integrity check of the main database (PRAGMA integrity_check). Heavy: it reads the whole file and checks every index
-- against its table, so run it off-peak or on a copy. Read-only: a SELECT. One row 'ok' means no problem found.
SELECT
    c.integrity_check AS result
FROM pragma_integrity_check AS c
LIMIT 100
