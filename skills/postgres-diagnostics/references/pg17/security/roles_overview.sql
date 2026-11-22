-- Target: PostgreSQL 17. Tested on 17.12.
-- Roles with powerful attributes and when their password expires (pg_roles). Read-only: a SELECT over a catalog view;
-- password hashes live in pg_authid and are not read. Built-in pg_* roles are left out.
SELECT
    r.rolname AS roleName,
    r.rolsuper AS isSuperuser,
    r.rolcreaterole AS canCreateRole,
    r.rolcreatedb AS canCreateDb,
    r.rolreplication AS canReplicate,
    r.rolbypassrls AS bypassesRowSecurity,
    r.rolcanlogin AS canLogin,
    r.rolconnlimit AS connectionLimit,
    r.rolvaliduntil AS passwordValidUntil
FROM pg_roles AS r
WHERE left(r.rolname, 3) <> 'pg_'
ORDER BY r.rolsuper DESC, r.rolname
LIMIT 200
