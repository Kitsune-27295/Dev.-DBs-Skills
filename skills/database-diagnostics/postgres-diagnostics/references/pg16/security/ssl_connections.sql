-- Target: PostgreSQL 16. Tested on 16.16.
-- Client connections by whether they use TLS, and the protocol and cipher in use (pg_stat_ssl with pg_stat_activity).
-- Read-only: a SELECT over views. A non-TLS connection from outside the host is a finding.
SELECT
    COALESCE(s.ssl, false) AS usesSsl,
    s.version AS tlsVersion,
    s.cipher AS cipher,
    count(*) AS connections
FROM pg_stat_activity AS a
LEFT JOIN pg_stat_ssl AS s
  ON s.pid = a.pid
WHERE a.backend_type = 'client backend'
GROUP BY COALESCE(s.ssl, false), s.version, s.cipher
ORDER BY count(*) DESC, 1, 2, 3
LIMIT 20
