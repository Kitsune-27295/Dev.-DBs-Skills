# What three exposure incidents show

Sources: UpGuard https://www.upguard.com/blog/everything-everywhere-systemic-data-exposure-in-supabase-apps; Wiz https://www.wiz.io/blog/exposed-moltbook-database-reveals-millions-of-api-keys; Tecnoblog https://tecnoblog.net/noticias/fiesp-expoe-dados-pessoais/; video "Banco de Dados | Fundamentos para Vibe Coders #EP2" (mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI) chapter 06 24:10-26:37 · Last verified 2026-11-24

## 1. UpGuard: systemic exposure (as reported)

UpGuard gathered about 300,000 domains showing signs of Supabase and queried each for a `users` table. 16,326 databases exposed readable tables. Shares of those databases: any personal information 55.8%, emails 38.8%, phone numbers 25.8%, payment indicators 12.1% (mostly reference IDs and billing metadata, not card data), passwords or PINs 8.2%. Causes: RLS disabled or absent, policies that did not restrict, public keys treated as secrets, and tables created through the API (as AI coding agents do) not having RLS enabled by default, unlike tables created in the dashboard editor. The article lists its own limits and notes the vendor sells breach-risk products. Takeaway: defaults and agent-made tables are a repeated cause.

## 2. Moltbook (Wiz, February 2026)

A social network for AI agents had a Supabase key in its public JavaScript and no RLS. Exposed: about 1.5 million agent API tokens, about 35,000 email addresses, 4,060 private conversations (some containing third-party credentials in plain text) and write access to live content. The disclosure-to-fix timeline spans a few hours. Wiz recommends RLS on every table, reviewing client bundles for secrets, human review of AI-generated backends, and re-testing after each fix. Takeaway: a public key plus no policy equals a public database, and private messages are not private.

## 3. FIESP (Tecnoblog, 2018)

Three Elasticsearch servers were reachable from the internet without login, exposing registration data such as names, ID and tax numbers, addresses, emails and phones. The headline says 180 million records, but the body counts about 52 million across three databases; the article does not reconcile this. A researcher found it; takeaway: a database port open to the internet with no authentication, which is the first check in the audit (it is not an RLS problem). The article notes the LGPD was not yet in force then.

## Pattern across the three

| Failure | Check in the audit |
|---|---|
| Database reachable from outside | `listen_addresses`, `pg_hba.conf`, firewall; note `trust` authentication over TCP |
| Secret or key shipped to the browser | search client code, public env vars (`NEXT_PUBLIC_`, `VITE_`, `EXPO_PUBLIC_`), git history |
| Table readable or writable by everyone | grants, RLS, policies (`using (true)`) |

## How an agent should apply this

- Cite these incidents only as reported by the named page, with their own caveats; do not extrapolate percentages to the owner's app.
- Run the three checks in order: network, secrets, per-table access; write findings first, fix later.
- Treat unauthenticated write access as at least as serious as read access.
- After any fix, re-test the exposure from the outside (anonymous request) on a non-production copy where possible.
- Rotate any key that was ever shipped to the client or committed.
