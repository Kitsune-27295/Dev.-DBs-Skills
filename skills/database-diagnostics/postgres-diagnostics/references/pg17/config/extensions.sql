-- Target: PostgreSQL 17. Tested on 17.12.
-- Installed extensions, their version and whether a newer one is available (pg_extension, pg_available_extensions).
-- Read-only: a SELECT over catalog views. Per database: run it in each database you care about.
SELECT
    e.extname AS extensionName,
    e.extversion AS installedVersion,
    a.default_version AS defaultVersion,
    (a.default_version IS NOT NULL AND e.extversion IS DISTINCT FROM a.default_version) AS updateAvailable
FROM pg_extension AS e
LEFT JOIN pg_available_extensions AS a
  ON a.name = e.extname
ORDER BY e.extname
LIMIT 100
