# PostgreSQL column-type pitfalls (from "Don't Do This")

Sources: PostgreSQL wiki https://wiki.postgresql.org/wiki/Don%27t_Do_This; video "Banco de Dados | Fundamentos para Vibe Coders #EP2" (mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI) chapter 02 06:25-11:46; handout section "1. Modelagem e constraints" · Last verified 2026-11-24

## Why this matters for AI-generated schemas

A model writing a schema will often pick the first familiar type. The wiki collects types and habits that work but bite later. The lesson cites the wiki for two of them (money, time); the page has more that are relevant to a schema audit.

## Money

- The lesson: never `float` for money. `0.1 + 0.2` in binary floating point is not exactly `0.3`, and across a million orders totals drift. Use `numeric` or integer cents.
- The wiki: do not use the `money` type either. Reasons given: fixed-point and locale-dependent, no currency stored, rounding problems, no fractional cents. Use `numeric` (or integer minor units) with the currency in an adjacent column.
- Decision: integer cents when you only add and subtract in one currency; `numeric(p,s)` when you need fractions (tax rates, unit prices); always a currency column when more than one currency is possible (the currency column is the wiki's advice).

```sql
-- weak
price real, total double precision
-- better
price_cents integer NOT NULL CHECK (price_cents >= 0),
currency    text     NOT NULL   -- plus a CHECK or domain, see below
```

## Time

- Use `timestamptz` for a point in time. Plain `timestamp` stores a wall-clock reading with no zone, so arithmetic across zones and daylight-saving changes goes wrong. The wiki also says plain `timestamp` is the wrong type for values that are UTC, because the database cannot know that.
- Avoid `timetz` and `CURRENT_TIME`; avoid `timestamp(0)` (it rounds rather than truncates, so a stored value can be up to half a second in the future); prefer `date_trunc('second', ...)`.
- `BETWEEN` on timestamps includes the end, so a row at exactly midnight lands in two daily buckets. Use `>= start AND < end`.
- Lesson's illustration: an order placed at 11 pm in Manaus appearing in the next day's report when the zone is missing.

## Text types

- `char(n)` pads with spaces, ignores trailing spaces in comparisons, is not faster. Use `text`.
- `varchar(n)` as a default adds arbitrary limits that fail in production later; use `text` and put real rules in a `CHECK`.
- For fixed-length codes (currency, country), the wiki suggests `text` with a length or format check, ideally via a domain.

```sql
CREATE DOMAIN currency_code AS text CHECK (VALUE ~ '^[A-Z]{3}$');
```

## Other items that touch schemas

- `serial`: prefer identity columns (`GENERATED ... AS IDENTITY`, PostgreSQL 10+), which manage dependencies and permissions more cleanly.
- `NOT IN (subquery)`: one NULL in the list makes it return nothing and it cannot become an anti-join; use `NOT EXISTS`. (Relevant to `query-performance` and to correctness.)
- Upper-case names: unquoted identifiers fold to lowercase; use snake_case.
- Table inheritance and rules: avoid; use foreign keys, partitioning, triggers instead.
- `trust` authentication over TCP/IP: not a schema matter, but `database-exposure` should flag it.

## How an agent should apply this

- Flag every price, balance or total typed `float`, `real`, `double precision` or `money`; propose `numeric` or integer cents plus a currency column.
- Flag every `timestamp` (without zone) holding a moment in time; propose `timestamptz` and report how existing values were interpreted before converting.
- Flag `char(n)` and arbitrary `varchar(n)`; suggest `text` plus a `CHECK` where a real rule exists.
- Treat `serial`, `NOT IN` and `BETWEEN` on timestamps as lower-risk findings worth a line.
- Cite the wiki as the source and keep conversion migrations reversible.
