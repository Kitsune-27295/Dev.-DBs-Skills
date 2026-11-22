-- Target: PostgreSQL 17. Tested on 17.12.
-- Rules of pg_hba.conf in the order PostgreSQL applies them, with parsing errors (pg_hba_file_rules).
-- Read-only: a SELECT over a view; it needs superuser or EXECUTE on the underlying function. Look for method = 'trust',
-- address = 'all' or a wide network, and rules before a more specific one.
SELECT
    h.rule_number AS ruleNumber,
    h.type AS connectionType,
    h.database::text AS databases,
    h.user_name::text AS userNames,
    h.address AS address,
    h.netmask AS netmask,
    h.auth_method AS authMethod,
    h.error AS error
FROM pg_hba_file_rules AS h
ORDER BY h.rule_number
LIMIT 200
