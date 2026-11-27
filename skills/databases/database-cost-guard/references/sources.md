# Sources — Database cost guard

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Banco de Dados | Fundamentos para Vibe Coders #EP2", channel mano deyvin, published 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI — chapter 05 "Susto no final do mês" (21:28-24:10) | Transcript read from a saved copy; video page not re-fetched | Meter vs rent pricing, the runaway-scraper story, N+1 (501 reads), listeners, offset billing, "alert is not a cap", the prompt's steps |
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe — section "4. Susto no final do mês" | Saved copy read; page not re-fetched | The prompt (billing model, loops/listeners/offset/unbounded, 10x estimate, simplest fix, real cut-off) |
| The Register, 2020-12-10, https://www.theregister.com/2020/12/10/google_cloud_over_run/ | 200 (read through a summarizing fetch tool) | The 116 billion reads, about US$72,000 bill, US$7 budget, waived once |
| Firebase "Avoid surprise bills", https://firebase.google.com/docs/projects/billing/avoid-surprise-bills | 200 (read through a summarizing fetch tool) | Budget alerts do not pause services; spend caps only for a few named services |
| Firestore pricing, https://firebase.google.com/docs/firestore/pricing | 200 (read through a summarizing fetch tool) | What counts as a read, offset billing, listener billing, free quota |

## Claims and caveats

- Verified at The Register: Milkie Way, about 116 billion Firestore reads and 33 million writes, bill about US$72,000, budget US$7, Google waived the bill as a one-time gesture, bill rose for about two hours at the end before settling.
- The video says "2 hours, 116 billion reads"; the article says the cost built up overnight after a day of testing and the bill kept rising for about two hours before settling. Not the same claim; the article's wording is the safer one (resolved 2026-11-24: re-fetched; the overnight run built the bill, and the total settled at just under US$72,000 about two hours after the founder woke to roughly US$5,000; `SKILL.md` and the case reference make no "two hours of reads" claim).
- The video says the cause was a scraper in a loop; the article says infinite recursion from pages linking to each other, high Cloud Run defaults (1,000 max instances, concurrency 80) and background services left running. Also an article note: billing data and the Firebase dashboard lagged by about a day.
- Verified at the Firebase page: "Budget alerts do not pause services"; spend caps exist only for Firebase AI Logic, App Hosting, Cloud Functions for Firebase and Extensions; Firestore and Realtime Database are not on that list; Firestore usage is calculated daily.
- Verified at the pricing page: offset skipped documents are billed; per-document reads for listener updates; 30-minute disconnect rule; free daily quota. The video's "listener listens to the whole collection" is an oversimplification: you are billed per document added or updated in the result set.
- The video's "same thing happened at AWS" is unsourced (resolved 2026-11-24: it appears in no SKILL.md or reference file of this pack; it stays an unverified anecdote of the video and is not cited as fact).

## Discrepancies with SKILL.md (not edited)

- `SKILL.md` says "a little short of US$72,000 after a runaway Cloud Run job"; the article supports this (Cloud Run plus Firestore reads). The video attributes it to a scraper only. No conflict with the page.
- `SKILL.md` suggests "a quota, an alert wired to a manual or scripted shutdown, a per-key limit"; the Firebase page mentions using budget notifications to disable billing on a project and Pub/Sub for custom logic, but not a per-key limit; that item is `SKILL.md`'s own suggestion.
