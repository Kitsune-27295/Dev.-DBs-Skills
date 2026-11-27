# Failure scenarios to pattern-match while auditing

Sources: author handout (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software) and its companion video (https://www.youtube.com/watch?v=G8SeOH0qerk, not re-readable this pass) · Last verified 2026-11-27

These are generic, common failure shapes. The wording, the signals and the interactions below are my own analysis; the author's figures and anecdotes are not reproduced.

| Topic | Scenario | Audit signal |
|---|---|---|
| Race condition | Two customers see the same last item; both buy; stock goes negative | Negative stock, duplicate orders, a coupon used twice |
| Idempotency | A gateway retries a "payment approved" webhook because the receiver was slow or mid-deploy; the plan is enabled and the email sent again | Repeated emails, credit added twice, duplicate subscription |
| Client trust | Checkout price edited in the browser before submit; a secret placed behind a public-prefixed variable; one user fetching everyone's orders | Rules only in the client; secrets in client-exposed variables; always-true policies |
| Separation | One checkout file mixing screen, gateway calls, database, price lookup, email and validation | A file nobody dares to open |
| Integration tests | A new feature silently breaks an older one | No route-level tests |

## Interactions (own analysis)

- A webhook delivered twice at once is both an idempotency and a race problem; a unique event id covers both.
- A client-supplied price is worse when combined with a missing payment-status check: sensitive fields should only change server-side.
- A refactor without prior tests turns the separation scenario into a regression scenario.

## How an agent should apply this

- Turn the signals into quick greps and read-only database queries (negative quantities, duplicate rows, public-prefixed variables).
- Report each finding with its scenario name so the owner can follow the reasoning.
- Do not quote popularity statistics or anecdotes from the source material in reports; they were not re-verified.
