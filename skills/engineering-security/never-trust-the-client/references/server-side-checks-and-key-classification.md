# Server-side checks and key classification

Sources: https://top10.owasp.org/2021/A01_2021-Broken_Access_Control · https://nextjs.org/docs/app/guides/environment-variables · https://vite.dev/guide/env-and-mode · https://docs.expo.dev/guides/environment-variables/ · https://supabase.com/docs/guides/api/api-keys · video chapter "Por que você não deve confiar no usuário" (13:26-20:32, https://www.youtube.com/watch?v=G8SeOH0qerk) · Last verified 2026-11-27

## Framing

"Client" means everything on the user's side: browser, app, bundle. Rule of thumb from the video: run the backend as if the front end did not exist. OWASP A01 gives the same rule in its prevention advice: enforce access checks in trusted server-side code, deny by default except public resources, check that each user owns the records they touch, and rate-limit API access. The video's remark that AI-generated apps often leave rules on the client is the speaker's observation, not measured.

## Verified facts about client-exposed keys

- Next.js: variables without the `NEXT_PUBLIC_` prefix stay server-only; prefixed ones are inlined into the bundle at `next build` and frozen at that value.
- Vite: `VITE_` variables are written into built code, and the docs say they must not hold API keys.
- Expo: `EXPO_PUBLIC_` values are inlined into the JavaScript bundle and visible in the compiled app; the docs say not to store private keys there.
- Supabase: publishable keys (legacy `anon`) are meant to be public and are limited by row-level security; secret keys (legacy `service_role`) bypass row-level security and belong only in backend code. A 401 for secret keys in browsers is a safety net, not a reason to expose them.

## Own examples

```text
// Client sends { plan: "pro", price: 1 }   -> reject: price is not an input
// Server: price = catalog.lookup(plan); charge(price)
```

Rotation: a key that has already been bundled must be treated as leaked even if removed now.

## Own guidance, not from a framework doc

The owner-filtered listing (a missing authentication check errors instead of leaking) comes from the video. Per-object checks and input validation are owned by `authn-authz-guard` and `validator-input-parser`.
