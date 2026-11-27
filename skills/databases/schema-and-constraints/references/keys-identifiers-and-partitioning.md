# Keys, identifiers and partitioning

Sources: https://www.postgresql.org/docs/current/ddl-identity-columns.html · https://www.postgresql.org/docs/current/datatype-uuid.html · https://www.postgresql.org/docs/current/sql-syntax-lexical.html · https://www.postgresql.org/docs/current/ddl-partitioning.html · https://api-security.owasp.org/editions/2023/en/0xa1-broken-object-level-authorization (all re-read 2026-11-27; the PostgreSQL pages served were the version 19 docs) · Last verified 2026-11-27

## Primary keys

An identity column (`GENERATED ALWAYS AS IDENTITY` or `BY DEFAULT`) is filled from an implicit sequence and is `not null`. `ALWAYS` accepts an explicit value only with `OVERRIDING SYSTEM VALUE` (that clause is not shown on the page); `BY DEFAULT` lets a supplied value win. The page says identity does not guarantee uniqueness: the sequence can be reset or values inserted by hand, so still declare `PRIMARY KEY` or `UNIQUE`. Partitions inherit identity columns from the partitioned table; child tables of classic inheritance do not. The page does not compare identity with `serial`; the wiki (`postgres-column-type-pitfalls.md`) is the source for preferring identity. Gaps in generated values are not discussed on the page: never rely on a gapless sequence (general knowledge).

`uuid` stores any 128-bit UUID. The type page says PostgreSQL can generate UUIDv4 and UUIDv7 and points to the functions section; it says nothing about ordering or B-tree behavior, and it does not name the release that added `uuidv7()`. That a time-ordered UUID inserts more smoothly into a B-tree than a random one is general knowledge, not on the page: verify for your version. A guessable key is an authorization problem, not a schema one: OWASP API1 lists random, unpredictable ids as one prevention step and authorization checks on every object-level request as the main one, so a random id supplements access checks and never replaces them (`integration-tests`).

## Identifiers

Unquoted names fold to lower case; quoted names keep their case and then must always be quoted, so `"MyTable"` and `mytable` are different objects. The docs advise always or never quoting. Names are cut silently at 63 bytes (NAMEDATALEN default 64 minus one; bytes, not characters), so two long names that differ after that collide. Rule (this skill's): lower-case `snake_case`, no quotes, short names.

## Partitioning

Declarative partitioning splits one table by range, list or hash. The docs list the benefits: less index depth in memory, sequential scans of one partition, fast removal of old data by detaching or dropping a partition instead of a bulk `DELETE` (and less `VACUUM` work), and tiered storage. They say it normally pays only when the table would otherwise be very large, with a rule of thumb of larger than server memory. Constraints that bite:

- a primary key or unique constraint must include every partition key column, and the partition key cannot use expressions or function calls there; exclusion constraints follow the same rule;
- `CREATE INDEX CONCURRENTLY` is not available on the partitioned table itself: create the index `ON ONLY` the parent, build each partition's index concurrently, then attach them;
- thousands of partitions raise planning time and memory unless pruning leaves few ("never assume more partitions are better");
- a regular table cannot be converted in place; you can `ATTACH PARTITION` an existing table whose columns match (a matching `CHECK` added first avoids a long scan under lock).

Do not use partitioning to fix a missing index (`query-performance`).

## How an agent should apply this

- Flag `serial` and missing primary keys; propose identity plus `PRIMARY KEY`.
- Flag quoted mixed-case names and over-63-byte names as findings.
- Propose partitioning only with a measured size and a retention or pruning reason, and say the key must join every unique constraint.
- Do not rename or retype keys in this skill's migrations; that is a separate change.
