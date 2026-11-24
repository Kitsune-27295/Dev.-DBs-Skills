# Triage and Evidence Checks

Sources: https://conventionalcomments.org/ · https://google.github.io/eng-practices/review/developer/handling-comments.html · https://google.github.io/eng-practices/review/reviewer/pushback.html · Last verified 2026-11-24

## What the sources say

**Conventional Comments** defines a one-line grammar for review comments: `<label> [decorations]: <subject>`, optionally followed by a discussion paragraph. The label says what kind of comment it is; decorations are parenthesized, comma-separated qualifiers; the discussion carries the "why" and the "next step". The site suggests labels such as `praise`, `nitpick`, `suggestion`, `issue`, `todo`, `question`, `thought`, `chore` and `note`, with softer optional ones such as `typo`, `polish` and `quibble`. Suggested decorations include `(non-blocking)`, `(blocking)` and `(if-minor)`; they may also be topical, for example `(security)` or `(test)`. The site says an organization should pick a minimal set and that you may diverge from the list. Its stated reasons for labels: the intent is clear, the tone softens, and the comments become machine-parseable.

**Google's author guidance** says the first question when reading a comment is "Do I understand what the reviewer is asking for?" and that the answer "no" means asking for clarification. It also says that when a reviewer did not understand the code, the first response is to change the code or add a comment, and only then to explain in the review tool.

**Google's reviewer-side pushback page** adds a useful rule for the author's side too: reviewers are told to ask themselves whether the developer is right; often the author is closer to the code. Applied in reverse, an author should expect the reviewer to be right more often than a first reaction suggests, and should check before deciding.

## Mapping labels to action

| Label or decoration | Default weight | Author action |
|---|---|---|
| `issue` | Blocking unless marked otherwise | Verify, then fix; ask for a suggestion if none was given |
| `suggestion` | Optional unless `(blocking)` | Evaluate on merit; accept, adapt or decline with reason |
| `todo`, `chore` | Required, small | Do it; a `chore` should link to the process that explains how |
| `question` | Needs an answer | Answer with a fact; check whether the code should change |
| `nitpick`, `quibble`, `polish`, `typo` | Optional | Apply if trivial and consistent with the repo; otherwise reply briefly |
| `thought`, `note` | Non-blocking | Read, reply only if it changes a plan |
| `praise` | None | Nothing required |
| `(non-blocking)` | Does not hold up approval | Do not stall on it; decide quickly |
| `(blocking)` | Holds up approval | Resolve before re-requesting review |
| `(if-minor)` | Author discretion | Apply only if the change stays small |
| No label at all | Unknown | Infer from content; ask when the weight changes the plan |

Inference rule (own judgment, not from a source): treat an unlabelled comment that asserts a defect, a security risk or a contract break as blocking until verified otherwise; treat style-only comments as optional unless a written project standard backs them.

## Evidence checks before acting

For each item, choose the cheapest observation that can falsify the reviewer's claim or yours:

| Claim | Cheapest check |
|---|---|
| Wrong result in case X | Run case X; or write the failing test first |
| Dead code | Search the repository for references, including dynamic use, config, docs and tests |
| Missing validation | Find the real entry point and trace whether the value can arrive unvalidated there |
| Performance concern | Measure or read the query plan; do not optimize from intuition |
| Style or naming | Open neighboring files and the written conventions; follow local pattern |
| API misuse | Read the library or framework documentation for the version in use |
| "This will break Y" | Search for Y's callers; run Y's tests |

Record what you ran. The evidence goes into the reply (see `replying-pushing-back-and-closing-threads.md`) and, for fixes, into the verification step.

Short example of a triage table written before touching code:

```text
1 issue      null user on logout path     -> reproduced with test_logout_no_session; BLOCKING, fix
2 suggestion extract retry helper         -> used in 1 place only; decline, offer to extract at 3rd use
3 nitpick    rename `tmp` -> `pending`    -> trivial, consistent with module; apply
4 question   why 5s timeout?              -> answer from ADR; add comment next to constant
5 (unclear)  "make this more robust"      -> ASK: against which failure?
```

## Failure modes

- Treating labels as binding: a `nitpick` that actually reveals a defect still needs a fix.
- Treating missing labels as "optional" by default and skipping real defects.
- Verifying only the claims you disagree with; verify the ones you agree with too, since a plausible fix can still be wrong.
- Letting one unclear item freeze everything: ask once, and continue with clearly independent items.

## How an agent should apply this

- Build a short triage table (item, label, claim, check, decision) before editing; keep it in the working notes or the round summary.
- Prefer the reviewer's explicit label or decoration; ask when the weight is ambiguous and would change your plan.
- Run the cheapest falsifying check for each claim and keep the command or file pointer for the reply.
- Treat the review as a source of facts about readability: when something confused a reader, change the code first.
- Never let an item silently disappear: every row ends as fixed, answered, deferred or declined.
