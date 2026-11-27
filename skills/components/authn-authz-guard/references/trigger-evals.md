# Trigger Evals: authn-authz-guard

Last verified 2026-11-27. Hand-written prompts; not run against a host.

## Should trigger
1. "Review our login flow: reset emails, lockout, cookie settings, and what happens to the session after a password change." -> this skill
2. "We are adding Sign in with an external identity provider using OAuth in a single-page app. What must we get right (redirects, tokens, refresh)?" -> this skill
3. "A pen tester says user 42 can read user 43's invoices by changing the id in the URL. How should authorization be structured?" -> this skill

## Near-miss (belongs to a neighbor)
1. "Audit this vibe-coded app for the most common launch-blocking flaws." -> `security-audit`
2. "The browser computes the discount and sends the final price; move that to the server." -> `never-trust-the-client`
3. "Is our Postgres port exposed, and are the public tables readable?" -> `database-exposure`
