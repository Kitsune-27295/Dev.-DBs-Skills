# Sources: Never trust the client

Last verified 2026-11-27. Fetched with WebFetch (model-written summaries, not raw HTML).

| Source | Status 2026-11-27 | Used for |
|---|---|---|
| https://www.youtube.com/watch?v=G8SeOH0qerk (video, channel "mano deyvin", chapter 13:26-20:32) | Page loads but shows only the title; transcript, channel and date not re-checked (a local transcript was read 2026-11-24) | DevTools price example, public vs secret idea, owner-filtered listing |
| https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software (section 3) | 200 OK, re-read | Prompt steps: client-only rules, secret classification, policy review, report columns, report first then one fix at a time, never disable protections |
| https://top10.owasp.org/2021/A01_2021-Broken_Access_Control (the old owasp.org URL answers 308) | 200 OK | Server-side enforcement, deny by default, ownership, rate limits |
| https://nextjs.org/docs/app/guides/environment-variables | 200 OK (page dated 2026-08-25) | `NEXT_PUBLIC_` inlined at build time |
| https://vite.dev/guide/env-and-mode | 200 OK | `VITE_` exposure and secrets warning |
| https://docs.expo.dev/guides/environment-variables/ | 200 OK | `EXPO_PUBLIC_` visible in the bundle |
| https://supabase.com/docs/guides/api/api-keys | 200 OK; the page carried an instruction aimed at an assistant to send feedback, ignored as page text | Publishable vs secret keys, row-level security bypass; legacy keys planned for deprecation in early 2027 |
| https://cheatsheetseries.owasp.org/cheatsheets/Insecure_Direct_Object_Reference_Prevention_Cheat_Sheet.html | 200 OK | Read; the IDOR rule is owned by `authn-authz-guard` and not repeated here |

## Reading limits

- The fetch tool returns summaries; details not stated were not adopted.
- The video was not re-transcribed this round.

## Claims not adopted

- "170 of 1,645 low-code apps had broken row-level security": the handout (re-read) repeats it, citing a study of one platform; the study was not opened, so SKILL.md omits it.
- Bots hunting leaked LLM keys and a resale market: stated without a source in the video; SKILL.md no longer says it.
- The video's "returns 500" for an unauthenticated filtered query: not in the handout; SKILL.md says "fails with an error".
- The IDOR and input-validation steps were the skill author's additions, not the video's; they now point to their owners.
