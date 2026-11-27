# What three exposure incidents show

Sources: UpGuard https://www.upguard.com/blog/everything-everywhere-systemic-data-exposure-in-supabase-apps; Wiz https://www.wiz.io/blog/exposed-moltbook-database-reveals-millions-of-api-keys; Tecnoblog https://tecnoblog.net/noticias/fiesp-expoe-dados-pessoais/; PostgreSQL pg_hba.conf https://www.postgresql.org/docs/current/auth-pg-hba-conf.html · Last verified 2026-11-27

## 1. UpGuard: systemic exposure (as reported)

UpGuard (post dated 23 September 2026) found about 300,000 domains with signs of Supabase (via BuiltWith and the Chrome UX Report) and queried each for a `users` table. 16,326 databases exposed readable tables. Shares of those databases: any personal information 55.8%, emails 38.8%, phone numbers 25.8%, payment indicators 12.1% (mostly reference IDs and billing metadata, not card data), hard credentials 9.7%, passwords or PINs 8.2%. Causes it lists: no control at all, policies that did not restrict, public keys treated as secrets, and tables created through the API (as coding agents do) not getting RLS by default, unlike tables made in the Table Editor. Its limits: analysis mostly of schemas, only a few exposures checked by hand, industry labels assigned by a model, `users`-table bias toward personal data, dependence on two domain sources. UpGuard sells breach-risk products. Takeaway: defaults and agent-made tables are a repeated cause.

## 2. Moltbook (Wiz, 31 January to 1 February 2026)

A social network for AI agents had a Supabase key in its public JavaScript and no RLS. Exposed: about 1.5 million agent API tokens, 4,060 private conversations (some holding third-party credentials in plain text), about 4.75 million records in all, and unauthenticated write access that let anyone edit posts. Email counts: Wiz's summary says 35,000; the body itemizes 17,000+ owner emails and 29,631 early-access emails, which do not add up to that summary, so quote the body figures with their source. Wiz contacted the maintainer on 31 January at 21:48 UTC and the last fix landed at about 01:00 UTC on 1 February: several fixes, with new exposed tables found between them. Wiz recommends RLS by default, reviewing client bundles for secrets, secure defaults in AI coding tools, treating write access as the bigger risk, and re-testing every surface after each fix. Takeaway: a public key plus no policy equals a public database, and private messages are not private.

## 3. FIESP (Tecnoblog, 2018)

Found on 12 November 2018 by a security researcher, article of 22 November. Three Elasticsearch servers were reachable from the internet without login, exposing registration data (names, ID and tax numbers, birth dates, addresses, emails, phones). The headline says 180 million records, but the three per-database figures (34,817,273 + 6,986,604 + 10,558,155) sum to 52,362,032, and the article does not reconcile the gap. The researcher said he got no reply; it went offline after someone reached FIESP by phone. Takeaway: a database port open to the internet with no authentication, the first check in the audit (not an RLS problem). The article notes the LGPD was not yet in force.

## Pattern across the three

| Failure | Check in the audit |
|---|---|
| Database reachable from outside | `listen_addresses` (default is loopback only), `pg_hba.conf` addresses, firewall; `trust` over TCP |
| Secret or key shipped to the browser | search client code, public env vars, git history |
| Table readable or writable by everyone | grants, RLS, policies (`using (true)`) |

## How an agent should apply this

- Cite these incidents only as reported by the named page, with their own caveats; do not extrapolate percentages to the owner's app.
- Run the three checks in order: network, secrets, per-table access; write findings first, fix later.
- Treat unauthenticated write access as at least as serious as read access.
- After any fix, re-test from the outside (anonymous request) on a non-production copy where possible; one fix often leaves other tables open.
- Rotate any key that was ever shipped to the client or committed.
