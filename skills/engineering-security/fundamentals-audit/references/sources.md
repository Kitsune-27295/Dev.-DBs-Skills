# Sources — Fundamentals audit and run order

Every URL below was re-checked on 2026-11-27 (WebFetch; Firecrawl unavailable).

| Source | Retrieved status | What it contributed |
|---|---|---|
| Author's handout, https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software | 200, article text read through a summarizing fetch (2026-11-27) | The four pre-run safety rules, the run order, the combined read-only audit prompt (five steps) and the report shape (top five risks first, one table per step, "not verified" rule, which fix to run first) |
| Companion video, https://www.youtube.com/watch?v=G8SeOH0qerk | 200, but only the page title loaded; no transcript, channel or date (2026-11-27) | Nothing re-verified; used earlier only for framing and failure scenarios |
| Martin Kleppmann, https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html | 200, read (2026-11-27) | Why leases plus process pauses make lock-only protection unsafe, and why fencing tokens or database constraints are needed; backs the "database alone" check |
| Vitest guide, https://vitest.dev/guide/ | 200, read (2026-11-27) | Background for the test-tool check: `vitest run` runs once, plain `vitest` watches |
| Playwright, https://playwright.dev/ | 200, read (2026-11-27) | Background only: cross-browser end-to-end tool |

## Reading limits

- The video transcript could not be re-fetched in this pass, so video-only content (timestamps, numbers, anecdotes) was removed or demoted. The handout was read through a summarizing fetch, not raw HTML.
- No scripts exist in this skill.

## Claims not adopted as fact

- Statistics and anecdotes from the video or handout (low-code row-level-security figures, a market for leaked keys, the mid-project productivity dip, the author's years of experience): unverified, not reproduced.
- Video chapter timestamps and the video's separate ordering of race and idempotency: not re-verified; SKILL.md follows the handout grouping.
- `AUDIT.md` is an English rename of the handout's Portuguese report file name; intentional.
- The pointers to `security-audit`, `database-exposure` and `database-audit`, and the "database alone" check in step 3, are this pack's additions, not source claims.
