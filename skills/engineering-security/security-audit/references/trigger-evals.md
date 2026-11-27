# Trigger evals: security-audit

Last verified 2026-11-27. Mental test set for the description; rerun it after any description edit.

## Should trigger

1. "I built my SaaS with an AI tool and launch Friday. Can you check it is safe before I go live?" Expected: this skill (five classes, read-only).
2. "Review this PR for security problems; it touches the orders API and a new export endpoint." Expected: this skill (diff review mode).
3. "Could a user change the id in /invoices/105 and see someone else's data? Check the whole app." Expected: this skill (IDOR, every handler).

## Near misses

1. "Move the price calculation out of the React component to the server." Expected: `never-trust-the-client`.
2. "Our Supabase API port and grants are open to the internet; harden them." Expected: `database-exposure`.
3. "Triage this Dependabot alert and decide severity." Expected: `vulnerability-triage`.
