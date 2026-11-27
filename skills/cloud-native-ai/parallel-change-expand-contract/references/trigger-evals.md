# Trigger evals: parallel-change-expand-contract

Last verified 2026-11-27. Prompts a description should (or should not) fire on.

## Should trigger
1. "We need to rename `users.first_name` to `given_name` on a live Postgres table with no downtime. How do we sequence it?" Expected: this skill.
2. "Our public API returns `name`; we want `givenName` and `familyName` but old mobile apps must keep working." Expected: this skill.
3. "Review this plan: one deploy adds a NOT NULL column, backfills it and drops the old one." Expected: this skill.

## Near-miss (should not trigger)
1. "Set up a migration tool with numbered files and separate dev and prod databases." Expected: `migrations-and-environments`.
2. "Find dead flags and unused endpoints we can delete from this repo." Expected: `simplification-audit`.
3. "Review whether our schema uses the right column types and constraints." Expected: `schema-and-constraints`.
