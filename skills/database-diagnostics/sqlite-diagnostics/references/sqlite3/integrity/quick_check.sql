-- Fast structural check of the main database (PRAGMA quick_check): skips the index-versus-table content comparison.
-- Read-only: a SELECT. One row 'ok' means no problem found; any other row is a finding. Run integrity/integrity_check.sql
-- for the full check when this one passes but you still suspect corruption.
SELECT
    q.quick_check AS result
FROM pragma_quick_check AS q
LIMIT 100
