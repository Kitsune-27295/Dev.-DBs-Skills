# Keys, identifiers and partitioning

Sources: https://www.postgresql.org/docs/current/ddl-identity-columns.html · https://www.postgresql.org/docs/current/datatype-uuid.html · https://www.postgresql.org/docs/current/sql-syntax-lexical.html · https://www.postgresql.org/docs/current/ddl-partitioning.html · Last verified 2026-11-24

## Primary keys

An identity column (`GENERATED ALWAYS AS IDENTITY` or `BY DEFAULT`) is filled from an implicit sequence and is `not null`. `ALWAYS` refuses an explicit value unless the insert says `OVERRIDING SYSTEM VALUE`; `BY DEFAULT` lets a supplied value win. The page says identity does not guarantee uniqueness: sequences can be reset and values inserted by hand, so still declare `PRIMARY KEY`. It does not compare identity with `serial`; the wiki (`postgres-column-type-pitfalls.md`) is the source for preferring identity. Gaps in generated values are not discussed on the page: never rely on a gapless sequence.

`uuid` stores a 128-bit value. The type page says PostgreSQL can generate UUIDv4 and UUIDv7; that `uuidv7()` appeared in version 18 and that time-ordered values insert more smoothly into a B-tree than random ones is general knowledge, not on that page (verify for your version). Keys that are guessable are an authorization problem, not a schema one: a random id supplements access checks and never replaces them (OWASP API1, see `integration-tests`).

## Identifiers

Unquoted names fold to lower case; quoted names keep their case and then must always be quoted, so `"MyTable"` and `mytable` are different objects. The docs advise either always or never quoting. Names are cut silently at 63 bytes (bytes, not characters), so two long names that differ after that collide. Rule: lower-case `snake_case`, no quotes, short names.

## Partitioning

Declarative partitioning splits one table by range, list or hash. The docs list the benefits: pruning, fast removal of old data by detaching or dropping a partition instead of a bulk `DELETE`, and tiered storage; and suggest it pays when the table would otherwise exceed server memory. Constraints that bite:

- a primary key or unique constraint must include every partition key column;
- `CREATE INDEX CONCURRENTLY` is not available on the partitioned table itself (build per partition, then attach);
- thousands of partitions raise planning time and memory; pruning must leave few;
- a regular table cannot be converted in place.

Do not use partitioning to fix a missing index (`query-performance`).

## How an agent should apply this

- Flag `serial` and missing primary keys; propose identity plus `PRIMARY KEY`.
- Flag quoted mixed-case names and over-63-byte names as findings.
- Propose partitioning only with a measured size and a retention or pruning reason, and say the key must join every unique constraint.
- Do not rename or retype keys in this skill's migrations; that is a separate change.
