# PostgreSQL column-type pitfalls (from "Don't Do This")

Sources: PostgreSQL wiki https://wiki.postgresql.org/wiki/Don%27t_Do_This (re-read 2026-11-27); author's handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe, section "1. Modelagem e constraints" (re-read); video https://www.youtube.com/watch?v=TL4T9ZESamI (not re-verified) · Last verified 2026-11-27

## Why this matters for AI-generated schemas

A model writing a schema often picks the first familiar type. The wiki collects types and habits that work but bite later. The lesson cites it for money and time; the page has more that matter in a schema audit.

## Money

- The lesson: never `float` for money. In binary floating point `0.1 + 0.2` is not exactly `0.3`, and across many orders totals drift. This is the lesson's and this skill's own claim; the wiki page does not discuss `float`.
- The wiki: `money` is a poor fit. It cannot represent fractions of a cent, its rounding can be wrong, and it takes its currency from the `lc_monetary` setting, so changing that setting changes what stored values mean. Alternative: `numeric` (or, rarely, integer), with the currency in an adjacent column. The page allows `money` for single-currency work that only adds and subtracts; this skill still prefers `numeric` or cents.
- Decision (this skill's own): integer cents when you only add and subtract in one currency; `numeric(p,s)` when you need fractions (tax rates, unit prices); always a currency column when more than one currency is possible.

```sql
-- weak
price real, total double precision
-- better
price_cents integer NOT NULL CHECK (price_cents >= 0),
currency    text    NOT NULL   -- plus a CHECK or domain, see below
```

## Time

- Use `timestamptz` for a point in time (it records one instant and displays it in the session zone). Plain `timestamp` stores a wall-clock reading with no zone, so arithmetic across zones and daylight-saving changes goes wrong; the wiki also says it must not hold UTC values, because the database cannot know they are UTC. Plain `timestamp` is acceptable for values handled abstractly with no date arithmetic.
- Avoid `timetz` (SQL-compliance leftover); prefer `timestamptz` or `date` plus `time`.
- Avoid `timestamp(0)`/`timestamptz(0)`: a precision rounds instead of truncating, so `now()` can be stored slightly in the future; use `date_trunc('second', ...)`.
- `BETWEEN` includes both ends, so a row at exactly midnight lands in two daily buckets. Use `>= start AND < end`. It is fine for discrete values such as integers and dates if you account for that.
- Lesson's illustration: an order placed at 11 pm in Manaus appearing in the next day's report when the zone is missing (illustrative, not sourced).

## Text types

- `char(n)` pads with spaces, compares surprisingly, saves nothing, offers no speed. Use `text`.
- `varchar(n)` errors on longer values; arbitrary limits can fail in production later, and it has the same storage and speed as `text`. Use `text` (or unlimited `varchar`) plus a `CHECK` where a real rule exists; `varchar(n)` is fine when the error is intended.
- For fixed-length codes (currency, country), `text` with a format check, ideally through a domain.

```sql
CREATE DOMAIN currency_code AS text CHECK (VALUE ~ '^[A-Z]{3}$');
```

## Other items that touch schemas

- `serial`: prefer identity columns (`GENERATED ... AS IDENTITY`, PostgreSQL 10+), which manage dependencies and permissions more cleanly; the wiki still accepts `serial` for older versions or shared sequences.
- `NOT IN (subquery)`: one NULL makes it return nothing and it optimizes poorly; use `NOT EXISTS`. Fine for constant lists known to hold no NULLs.
- Table inheritance: avoid; use foreign keys, and native partitioning for the old main use. Rules: avoid; use triggers.
- `trust` authentication: not a schema matter; `database-exposure` should flag it (the wiki warns against it over TCP/IP and for production in general).

## How an agent should apply this

- Flag every price, balance or total typed `float`, `real`, `double precision` or `money`; propose `numeric` or integer cents plus a currency column.
- Flag every `timestamp` (without zone) holding a moment in time; propose `timestamptz` and report how existing values were interpreted before converting.
- Flag `char(n)` and arbitrary `varchar(n)`; suggest `text` plus a `CHECK` where a real rule exists.
- Treat `serial`, `NOT IN` and `BETWEEN` on timestamps as lower-risk findings worth a line.
- Cite the wiki as the source and keep conversion migrations reversible.
