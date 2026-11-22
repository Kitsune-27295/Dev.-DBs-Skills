-- File size and reclaimable free space of the main database (page_count, page_size, freelist_count).
-- Read-only: a SELECT. freePct is the share of pages on the free list: VACUUM (not run here) would return that space to the
-- operating system, while auto_vacuum = INCREMENTAL does it in steps.
SELECT
    pc.page_count AS pageCount,
    ps.page_size AS pageSize,
    round(pc.page_count * ps.page_size / 1048576.0, 2) AS fileMb,
    fl.freelist_count AS freePages,
    round(fl.freelist_count * ps.page_size / 1048576.0, 2) AS freeMb,
    round(100.0 * fl.freelist_count / NULLIF(pc.page_count, 0), 2) AS freePct
FROM pragma_page_count AS pc
CROSS JOIN pragma_page_size AS ps
CROSS JOIN pragma_freelist_count AS fl
