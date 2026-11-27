# Comments: Why, Not What (the Single Home for Comment Rules)

Sources: https://google.github.io/eng-practices/review/reviewer/looking-for.html · https://docs.kernel.org/process/coding-style.html (ch. 8) · https://stackoverflow.blog/2021/12/23/best-practices-for-writing-code-comments/ · https://gist.github.com/bansalankit92/6119c4f7fabe11b7a174a99f5a7bb376 · https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/TIGER_STYLE.md · Last verified 2026-11-27

All sources were read in full; text below is paraphrase (Google docs CC BY 3.0; kernel docs GPL, no copying).

## Where the sources agree

1. A comment is a cost: it must be written, read and kept true, and no compiler checks it. A wrong comment is worse than none (Stack Overflow, Google, kernel).
2. Do not narrate what the line does, or how the mechanism works. Fix unclear code instead (all four). The Stack Overflow article cites "Don't comment bad code, rewrite it" from Kernighan and Plauger.
3. Comments carry what code cannot: reasons, constraints, history, pointers (Google: "the reasoning behind a decision").

## Where they differ (resolve like this)

| Topic | Positions | Rule adopted here |
|---|---|---|
| What vs why | Google: why, not what. Kernel: never "how"; head-of-function comment says what, maybe why | Inline comments: why. Function-level: contract (purpose, usage, behavior) |
| Absolute ban | The Clean Code gist: any comment signals failure, comments should be rare | Too strict; Stack Overflow and Google keep comments for non-obvious reasons |
| TODO | Stack Overflow: use TODO to mark known incompleteness, ideally with a tracker issue. An AGENTS-style gist says avoid TODO | Allow, in the form below |
| How | TigerStyle also wants "how": a test's header states goal and method | Allowed at test or module header level, not per line |
| Exceptions to "why" | Google: regexes and complex algorithms may be explained as to what they do | Allowed |

## What to write

- Why a choice was made over the obvious one, and what breaks if "simplified" (Stack Overflow rule 5).
- A workaround for a bug in a dependency, platform or standard, with a reference to the issue or spec (rules 7, 8).
- Source of copied code and its license obligation (rule 6).
- Units, ranges, invariants and ownership that the types do not show.
- A warning about a surprising consequence.
- Intent of a hard algorithm or regex, once, at its head.
- Doc comments on public API: purpose, parameters, errors, behavior. Do not restate the signature.

## What never to write

- Restating the line (`i += 1  # add one`) or closing-brace labels.
- Journals, authorship and dates (version control has them), banners, jokes, notes to coworkers.
- Apologies or warnings to readers instead of simpler code ("do not touch").
- Commented-out code: delete it; history lives in version control.
- Task chatter ("added for ticket review", "fixed per user request"): put it in the commit message or PR.
- Comments left behind after the code changed: update or delete in the same change.

## Doc comments versus inline comments

Google separates *comments* (reasoning) from *documentation* of classes, modules and functions (purpose, usage, behavior). Document the contract on public surface so callers never read the body; keep inline comments rare and about reasons. The kernel adds: boilerplate docs that duplicate the signature are noise.

## TODO policy

A TODO is permitted when it names what is missing and why it is deferred, ideally with an owner or issue reference. An unnamed TODO is a deferred decision nobody tracks. Review existing TODOs near your change: remove those your change resolves (Google). An agent should not scatter TODOs to defer work it was asked to do; finish it or report it.

## Example

```python
# Weak: restates the code and hides the reason.
# loop over users and skip inactive
for u in users:
    if u.active: send(u)

# Strong: the reason is invisible in the code.
# Billing API rate-limits at 5 req/s (see vendor docs); send sequentially.
for user in active_users:
    send_invoice(user)
```

## How an agent should apply this

- CM-01: first try to remove the need for a comment: rename, extract a function, name a constant.
- CM-02: write a comment only for information the code cannot hold: reason, constraint, reference, surprise.
- CM-03: never leave commented-out code, task chatter, or restating comments in your diff.
- CM-04: put the contract on public functions; skip docs that mirror the signature.
- CM-05: use TODO only with a stated gap and, when possible, an issue reference; do not use it to dodge requested work.
- CM-06: when you change code, re-read the comments around it and fix or delete stale ones.
