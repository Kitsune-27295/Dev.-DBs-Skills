# Acceptance Criteria and the Evidence Ledger

Sources: https://scrumguides.org/scrum-guide.html · https://code.claude.com/docs/en/best-practices · https://en.wikipedia.org/wiki/Verification_and_validation · https://martinfowler.com/bliki/SelfTestingCode.html · Last verified 2026-11-27

## Why numbered criteria

Two public sources point at the same gap. The Scrum Guide treats the Definition of Done as a formal statement of the state work must reach, and says an item that does not meet it does not count as part of the increment. Claude Code's best-practices page says an agent stops when work "looks done" unless it has something to run that returns pass or fail. In both cases "done" is only meaningful when it is written down before the work and tested after it. An AC (acceptance criterion) with an ID is that written-down, testable statement. The ledger is where each one is closed with proof.

Verification asks "did we build it to the stated requirement?" and validation asks "does it meet the real need?" (Wikipedia's V&V article). Both can fail independently: a product can pass every AC and still be the wrong product. So write at least one AC from the user's outcome, not only from the implementation.

## AC format

`AC-<n>: <observable subject> <does/shows/returns> <exact expected result> under <condition>. Check: <command or observation>.`

A criterion is acceptable only if all four hold:
1. **Falsifiable**: a specific observation would make it false. "Works well" is not.
2. **Observable**: a command, request, file diff, screenshot or log line shows the result.
3. **Bounded**: one behavior per AC; split "and" clauses.
4. **Owned**: it traces to the user's request or an existing spec, not to the agent's taste.

Four examples (own, generic):

```
AC-1: `GET /orders/42` for a user who does not own order 42 returns 404 with an empty body.
      Check: curl -s -o /dev/null -w "%{http_code}" with that user's token -> 404.
AC-2: `parse_price("1.299,50", locale="de")` returns Decimal("1299.50").
      Check: new unit test test_parse_price_de passes; same test FAILS on the pre-change code.
AC-3: The settings page shows the saved email after a full reload and no console errors.
      Check: observe in a real browser run; screenshot read; console log has 0 error lines.
AC-4: `npm run build` exits 0 and the bundle for /checkout is no larger than before (+2% max).
      Check: build exit code; size line before and after quoted.
```

Rewrite vague requests into ACs, then show them to the user when intent is unclear; do not invent scope to make a criterion easier.

## Ledger schema

One row per AC per run of its check. Keep it in the working notes, the PR text or the final report; it does not need a file.

```
AC | check command                        | observed output excerpt               | verdict | run time
AC-1 | curl ... /orders/42 (user B)       | "404"                                  | PASS    | 14:02:11
AC-2 | pytest tests/test_price.py -k de   | "1 passed in 0.04s"                    | PASS    | 14:03:40
AC-3 | browser run, reload /settings      | email shown; console: 0 errors (shot)  | PASS    | 14:05:02
AC-4 | npm run build                      | "exit 1: Module not found './tax'"     | FAIL    | 14:06:30
```

Verdicts: `PASS` (check ran this session, output satisfies the AC), `FAIL` (ran, does not satisfy), `UNVERIFIED` (could not run or observe; say why), `BLOCKED` (cannot proceed without something outside your control). There is no "probably passes".

Rules for the ledger:
- Every AC has at least one row before completion is claimed. An AC with no row is `UNVERIFIED`.
- A PASS row needs a command or observation run **in this session**, after the last edit that could affect it. If a later edit touches code the check depends on, the row is stale: re-run.
- The excerpt is copied, not recalled. Quote the signal lines (counts, exit code, the assertion message, the status line), not the whole log.
- Add a regression AC when a prior behavior must be preserved ("existing suite still green"), and name the exact command.

## What counts as evidence

| Counts | Does not count |
|---|---|
| Output of a command you ran after the final edit, with exit code or count read | "Should pass", "I changed X so Y" |
| A test that you saw fail without the change and pass with it | A test that was only ever seen green |
| A screenshot or response body you opened and read | A screenshot taken but not looked at |
| A diff showing the intended lines and nothing else (for refactors, config, docs) | A subagent saying it succeeded |
| Runtime observation of the real behavior (user-visible change) | A passing typecheck or build as proof of behavior |

A passing suite is also weak evidence for a new behavior unless a test targets it; Fowler's note on self-testing code stresses that the suite earns confidence by catching a new bug quickly, which only holds for behavior the suite actually exercises. For proving a check can fail see [anti-cheating-and-weak-checks.md](anti-cheating-and-weak-checks.md).

## Evidence hygiene

- **Redact**: replace tokens, passwords, cookies, keys, emails and internal hostnames with `<redacted>` before quoting. If an output is mostly secrets, quote only the exit code and counts.
- **Quote signal only**: pass/fail counts, the first failing assertion, the status code. Elide with `[...]`; never edit the text inside the quote.
- **Label inference**: write `observed:` for what the command printed and `inferred:` for anything you concluded. Do not blend them.
- **Keep reproduction**: the check command must be copy-runnable by someone else. Pin the working directory and any env var that matters (names only, not values).
- **Time-stamp**: a time (or run counter) per row is enough to spot stale rows after later edits.

## How an agent should apply this

- Write ACs before the first edit; if the request is ambiguous, ask which outcome the user will check, then write the ACs from that.
- Give every AC a runnable check or a named observation; if none exists, say so and mark it `UNVERIFIED` rather than inventing a weaker proxy.
- Fill the ledger as checks run, copying excerpts; re-run any row made stale by a later edit.
- Put the ledger summary in the final report using the completion states in `SKILL.md`; never report `Validated` with an `UNVERIFIED` row.
- Redact secrets in every quoted excerpt, and keep inference visibly separate from observed output.
