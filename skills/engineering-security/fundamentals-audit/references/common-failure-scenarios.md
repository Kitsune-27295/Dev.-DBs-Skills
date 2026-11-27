# Failure scenarios shown in the video

Sources: video chapters at 2:51-7:11, 7:11-13:26, 13:26-20:32, 20:32-24:07 and 24:07-31:40 (https://www.youtube.com/watch?v=G8SeOH0qerk); handout "Onde quebra" and "Sinal de que você tem" lines (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software) · Last verified 2026-11-24

Use these as pattern-matching aids while auditing. The scenarios and their numbers come from the video unless marked as my analysis.

| Topic | Scenario in the video | Audit signal (handout) |
|---|---|---|
| Race condition | Two customers see the same last item; both buy; stock goes negative. Inherited systems often show a negative stock row | Duplicate orders, negative stock, coupon used twice |
| Idempotency | A gateway retries a "payment approved" webhook because the receiver was slow or mid-deploy; plan enabled and email sent again, external paid APIs called repeatedly | Repeated emails, credit added twice, duplicate subscription |
| Client trust | Checkout price edited in the browser from 79 to 1; keys hidden behind a public-prefixed variable; one user fetching everyone's orders | Rules only in the client; secrets in client-exposed variables; always-true policies |
| Separation | One checkout file mixing screen, gateway calls, database, price lookup, email and validation; productivity falling mid-project | A file nobody dares to open |
| Integration tests | A new feature silently breaks an older one; the customer reports it as "the app stopped on its own" | No route-level tests |

## Interactions (own analysis)

- A webhook duplicate delivered twice at once is both an idempotency and a race problem; the unique event id covers both.
- A client-supplied price is worse when combined with a missing payment-status check: sensitive fields should only change server-side.
- A refactor without prior tests turns the separation scenario into a regression scenario.

## Anecdotes and figures (the video's claims, not verified)

- Bots scanning for leaked LLM keys and a resale market.
- 170 of 1,645 low-code apps with broken row-level security (the handout adds who analyzed them and that only the landing page was examined).
- The speaker's 20-plus years as a developer doing maintenance work.

## How an agent should apply this

- Use the table's signals as quick greps and database queries (negative quantities, duplicate rows, public-prefixed variables).
- Report each finding with its scenario name so the owner can follow the reasoning.
- Do not quote the video's statistics in reports as facts; cite them as claims or omit them.
