# Server-side checks and key classification

Sources: video chapter "Por que você não deve confiar no usuário" (13:26-20:32, https://www.youtube.com/watch?v=G8SeOH0qerk); handout section "3. Nunca confie no cliente" (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software) · Last verified 2026-11-24

## Framing

"Client" means everything on the user's side: browser, app, bundle. The video's rule of thumb: run the backend as if the front end did not exist. Front-end validation depends on the user's good manners; the server decides. The speaker adds that AI-generated apps often treat the backend as a bare database and leave rules on the client (his observation, not measured).

## Three exposures from the video

1. **Price or plan sent by the client.** A checkout route that accepts a price lets anyone change 79 to 1 in DevTools. Fix: the server looks up the plan, recomputes price and discounts, ignores client values.
2. **Keys.** Allowed in the browser: publishable-style keys (the video names the database's public or anon key, with the caveat that row-level security must be configured). Never in the browser: service-role or secret keys, payment gateway tokens, and LLM provider keys. A variable whose name carries the framework's public prefix (the video names `NEXT_PUBLIC_` and `VITE_`; the handout adds `EXPO_PUBLIC_`) ships to the browser even if never hardcoded.
3. **Seeing other people's data.** An orders endpoint must return only the caller's rows: the query itself filters by the authenticated user id. The video's point: if the auth check is forgotten, the query errors instead of leaking. Contrast: a permissive rule (always-true policy) hands everything over.

## Handout checklist, condensed

| Step | Question |
|---|---|
| 1 | Which price, discount, shipping, permission, admin role, plan limit or validation exists only in the client? Move it to a server function. |
| 2 | Which keys reach the browser? Classify public by design vs secret; secrets move to the server; list those needing rotation. |
| 3 | For an API-exposed database: which tables have row-level security off? Explain each policy in plain language; flag always-true rules and rules not comparing with the authenticated user; propose minimal policies; sensitive fields (payment status, role, balance) change only server-side; the service key is never used in the browser. |
| 4 | Final report: finding, risk, file and line, proposed fix. |

Process rules: report first with no edits; then one fix at a time, policies in separate migrations, wait for approval, never switch off an existing protection to make something work.

## Own examples

```text
// Client sends { plan: "pro", price: 1 }   -> reject: price is not an input
// Server: price = catalog.lookup(plan); charge(price)
```

Rotation: a key that has already been bundled must be treated as leaked even if removed now.

## How an agent should apply this

- Start with a read-only report; do not edit before the owner chooses.
- For every key found, state public-by-design or secret, and where it is read.
- Check list endpoints for owner filtering and not just authentication.
- Keep the policy fixes in dedicated migrations.
- Leave deep scanning to `security-audit`; use this skill for remediation.
