# Replying, Pushing Back and Closing Threads

Sources: https://google.github.io/eng-practices/review/developer/handling-comments.html · https://google.github.io/eng-practices/review/reviewer/pushback.html · https://docs.github.com/en/pull-requests/how-tos/review-pull-requests/commenting-on-a-pull-request · https://docs.github.com/en/pull-requests/how-tos/review-pull-requests/incorporating-feedback-in-your-pull-request · Last verified 2026-11-27

## What the sources say

**Tone and posture (Google, handling comments).** Review is meant to protect the quality of the codebase; a critique should be read as an attempt to help rather than as a personal attack. Ask what constructive message the reviewer is trying to send and act as though that is what they said. Do not answer in anger; step away until you can reply politely. If you understand a comment but disagree, the page contrasts a flat refusal with a collaborative reply that names the choice made, the trade-offs behind it, and asks whether the reviewer weighs the trade-offs differently. It adds that you may know things about users, the codebase or the change that the reviewer does not, so fix what is right and give context for the rest. If consensus fails, fall back on the project's written review standard.

**Pushback (Google, reviewer side).** The mirror advice: reviewers should consider whether the author is right and concede if so; if not, explain further while staying polite. The page also records an experience-based warning about "I will clean it up in a later change": it usually does not happen, so new complexity should be fixed before merge unless it is an emergency, and if the change exposes surrounding problems that cannot be fixed now, file a bug assigned to the author and optionally reference it from a TODO.

**GitHub conversations.** You can reply inside an existing line or file comment thread. A conversation on the Files changed tab can be resolved by whoever opened the pull request or anyone with write access; resolving collapses it and makes unresolved ones easier to find. A suggestion that is out of scope can be tracked by opening a new issue that links back to the original comment. The conversations menu lists unresolved, resolved and outdated threads.

## Reply anatomy

| Outcome | Minimum content | Example |
|---|---|---|
| Fixed | What changed + where | "Fixed in `3f2a9c1`: the null check now runs before the cache lookup." |
| Fixed differently | Why different + where | "Used a guard clause instead of the helper you suggested; the helper would add a second call site for one use. See `3f2a9c1`." |
| Answered | The fact, with pointer | "The 5 s timeout matches the upstream SLA (see `docs/adr-12`); added a comment next to the constant." |
| Deferred | Issue link + reason | "Out of scope here; tracked in the linked issue, which also covers the other call sites." |
| Declined | Evidence + trade-off + opening | See template below |
| Clarifying | Your reading + question | "I read this as 'validate at the boundary, not per call'. Is that the intent?" |

Decline template:

```text
Checked: <what you ran or read, with pointer>.
Found: <what it shows>.
Choice: <current approach> because <trade-off>.
Open to: <alternative>, if <condition>. Or: do you weigh <trade-off> differently?
```

## Pushing back well

1. Check first (see `triage-and-evidence-checks.md`). Pushback without a check is opinion.
2. Lead with what you verified, not with what you feel.
3. State the cost of the suggestion as well as the cost of the current code; reviewers rarely see the first one.
4. Offer something: an alternative, a follow-up issue, or the exact condition under which you would change course.
5. One round of reasoned pushback; if the reviewer repeats the request with an explanation that addresses yours, concede or escalate through the project's written standard. Do not loop.
6. Decisions about architecture, product scope or risk acceptance belong to the human owner: bring them the disagreement with the evidence instead of choosing alone.

## When the reviewer was right after all

Say it in one line and fix it: "You were right: the second caller does pass an empty list. Added the guard in `abc1234`." Do not apologize at length and do not re-argue your earlier reply.

## Closing threads

- Fixed, answered and deferred threads: leave them for the reviewer to resolve unless your project lets authors resolve their own. The platform allows the author to resolve; your team's habit decides whether to do so.
- Declined threads: never resolve them yourself; the reviewer's agreement closes them.
- Outdated threads (the code moved): still reply if the point stands.
- Before re-requesting review, scan the conversations list so no thread is unanswered.

## Failure modes

- Replying "done" without a commit or location.
- Pushing back on tone or on the reviewer instead of on the claim.
- Defensive explanation in the thread for code that should be clearer.
- Moving a decision to a vague "later" with no issue.
- Resolving a thread to make the count go down.

## How an agent should apply this

- Write every reply from the table above: outcome, pointer, one reason.
- For declines, use the template and include evidence you actually ran; never invent a constraint.
- Stay neutral: no gratitude rituals, no emotional language, no sarcasm.
- Escalate disagreements about scope, risk or architecture to the human owner with the evidence, and wait.
- File an issue for real out-of-scope findings and link it in the reply; do not let a "later" go unrecorded.
- Do not resolve declined threads and do not edit reviewers' comments.
