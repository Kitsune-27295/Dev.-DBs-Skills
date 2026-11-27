# Trigger evals

Last verified 2026-11-27

Should trigger `application-performance`:

1. "The orders page takes six seconds to load as the table grew. Make it faster."
2. "Where is the time going in this endpoint? p95 is 2 s and I do not know what to fix first."
3. "Add a performance budget to CI so this import job cannot get slower unnoticed."

Near misses (expected owner in parentheses):

1. "Yesterday's deploy made checkout slow and nobody knows why." (`diagnosing-bugs`)
2. "This SQL query does a sequential scan; which index should I add?" (`query-performance`)
3. "Design cache invalidation for the product API." (`caching-strategies`)
