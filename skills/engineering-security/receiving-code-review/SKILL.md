---
name: receiving-code-review
description: "Handle review comments on your own pull request or patch, as author or agent: read every comment first, restate it, verify its claim against the code before editing, ask once when it is unclear, sort blocking from optional, fix the code instead of only explaining it, decline with evidence, batch fixes, re-run checks, answer every thread, file out-of-scope items and re-request review. Rejects performative agreement and blind implementation. Not for reviewing someone else's diff (use code-review) or writing the PR body (use pr-description). Use when a human or bot reviewer left comments, a comment seems wrong, unclear or out of scope, or you are drafting the reply."
---

# Receiving Code Review

One idea: review feedback is **evidence to evaluate, not an order to obey and not an attack to defend against**. Every comment gets the same loop: understand it, check it against the code, decide, act or answer with evidence, close the thread. Politeness comes from clear, specific replies, never from agreeing before checking. Sources and claims: [references/sources.md](references/sources.md).

Boundary: how to *give* a review (standards and spec axes) belongs to `code-review`; commit shape belongs to `git-atomic-commits`; proof that a fix works belongs to `verification-loop`; the rules the code must follow belong to `clean-code-for-agents`. This skill owns only the author-side handling of comments.

---

## 1. The Loop (per review round)

1. **Read everything first.** Load all comments, the review summary and the diff context before changing anything. Items interact; a fix for comment 2 may make comment 5 moot or wrong.
2. **Restate each item** in one line in your own words (what is being asked, in which file or behavior). If you cannot restate it, it is unclear (section 3).
3. **Verify against the code** (section 2). The reviewer may be missing context, reading an older revision, or simply be wrong.
4. **Classify** (section 4): blocking, optional, question, out of scope.
5. **Decide**: fix, fix differently, ask, defer with a filed issue, or decline with evidence.
6. **Act in batches** (section 6) and **re-verify** (section 7).
7. **Answer every thread** (section 8), then **re-request review** (section 9).

Never start editing between steps 1 and 3. Acting on item 1 before reading item 5 is the most common source of rework.

---

## 2. Verify Before You Act

A comment is a claim about the code or about what the code should do. Check the claim with an observation, not with memory.

| Comment type | Check before acting |
|---|---|
| "This is a bug / breaks when X" | Reproduce it: run the case, write a failing test, or trace the path. Cannot reproduce: say so and share what you ran. |
| "Remove this, it is unused / dead" | Search for callers, reflection, config and public-API use. Unused: remove it. Used: show the caller. |
| "Do it the other way / use library Y" | Does it fit this stack, version and platform? Does it break an existing behavior or documented decision? |
| "Add proper X (validation, metrics, abstraction)" | Is anything calling this path? Is the case reachable? Apply `kiss-yagni-aha` before building speculative extras. |
| "Rename / restyle" | Does it match the surrounding code and the project's written conventions? (`clean-code-for-agents`) |
| "Security or data-loss concern" | Treat as high priority; verify with the real path (`security-audit`, `never-trust-the-client`) before dismissing anything. |
| Bot or linter comment | Same loop. A bot can be wrong, and an automated suggestion has no knowledge of intent. |

A reviewer who sees only the diff lacks context you may hold: callers, constraints, earlier decisions. A reviewer may also hold context you lack. Both are reasons to check, not to defend or to defer.

If you cannot verify cheaply, say exactly what you could not verify and what you need ("I cannot confirm this without the staging data; can you share the failing input?"). Do not implement an unverified claim silently and do not reject it unseen.

---

## 3. Unclear Comments: Ask First, Once, Specifically

- If **any** item is unclear, items often interlock. Ask before implementing the related ones. Items that are clearly independent may proceed.
- Ask one concrete question per unclear item, with your best interpretation: "I read this as moving the retry into the client wrapper. Is that right, or do you mean removing the retry entirely?"
- A reviewer who did not understand some code is a signal about the **code**: fix the code (rename, simplify, extract) or add a comment that says *why*; a reply in the review tool helps only this one reader. Explain in the thread only after the code itself cannot be made clearer.
- Do not guess to avoid looking uncertain. A wrong guess costs a full extra review round.

---

## 4. Blocking Versus Optional

Sort before you plan the work. Use the reviewer's own marker when there is one; otherwise infer, and when the weight matters, ask.

| Class | Typical signals | What you do |
|---|---|---|
| **Blocking** | `(blocking)` decoration, "must", "request changes", correctness, security, data loss, broken contract, failing test (an `issue` label alone does not decide it: `issue (non-blocking)` exists) | Fix or resolve by evidence before asking for re-review |
| **Optional** | `nitpick`, `suggestion (non-blocking)`, `thought`, `polish`, `if-minor`, "consider" | Cheap and clearly better: just do it. Otherwise decide on merit and reply either way |
| **Question** | `question`, "why", "what happens if" | Answer in the thread with a fact; change the code too if the question exposed a gap |
| **Praise / note** | `praise`, `note` | No action; no thanks-ritual either |
| **Out of scope** | Real but unrelated improvement | File an issue linking the comment, reply with the link, keep the diff focused |

The Conventional Comments format `label (decoration): subject` makes this explicit; see [references/triage-and-evidence-checks.md](references/triage-and-evidence-checks.md). Reviewer labels are a hint about intent, not a binding rule; a "nitpick" that reveals a bug is blocking.

Nothing is "clean up later" by default. New complexity you introduce in this change gets fixed in this change; unrelated pre-existing problems go to a filed, assigned issue rather than a vague TODO.

---

## 5. No Performative Agreement

Agreement is something you establish by checking, not an opening move.

| Do not write | Write instead |
|---|---|
| "You are absolutely right!" / "Great catch!" before checking | Nothing yet; verify first |
| "Will do" for an item you have not understood | A restatement or a question |
| "Fixed" with no pointer | "Fixed in `abc1234`: moved the null check before the cache lookup." |
| Long apology or gratitude paragraph | One factual line |
| Silent agreement to something you believe is wrong | Evidence-backed pushback (section 6) |

When the reviewer is right, the best acknowledgment is the fix plus one precise sentence about what changed. When you pushed back and were wrong, correct it in one line ("You were right: I checked X and it does Y. Fixing.") and move on without a defense of the earlier reply.

---

## 6. Decline Politely, With Evidence

Declining a suggestion is legitimate when it breaks behavior, ignores a constraint, targets code that is not reachable, contradicts an agreed decision or is wrong for this stack. The form decides whether it lands.

Reply shape (3 to 5 sentences):

1. What you checked and what you found, with a pointer (file, test, output, doc).
2. The trade-off behind the current choice, in neutral terms.
3. A concrete alternative or the question that would change your mind.
4. If it is a design disagreement: ask whether the reviewer weighs the trade-off differently.

Example:

> I checked the callers: `export()` is only called from the nightly job, which always passes a non-empty list (see `jobs/nightly.py:41`), so the empty-list branch cannot run. I kept the function small rather than add a branch no test can reach. If the CSV endpoint is meant to call it with user input later, I will add the guard in that change. Is that planned?

Never reply "no" without a reason, and never decline on taste alone when the reviewer cites a project rule: check the rule first. If you cannot reach agreement, escalate to the project's standard for resolving conflicts (the reviewer-of-record, a maintainer, or the written standard) rather than repeating the argument. Human decisions on architecture or product scope belong to the human owner, not to you.

---

## 7. Fix in Batches, Then Prove It

- Group related fixes into coherent commits (`git-atomic-commits`): one concern per commit, message states the review reason. Use fixup commits only if the project squashes; never rewrite history reviewers have already seen unless the project allows it.
- Apply reviewer-provided suggestion blocks as a batch when the platform supports it; a batch becomes a single commit.
- Order: blocking first, then simple mechanical items, then the larger refactors. Run the relevant checks after each group, not once at the end.
- Re-run the checks that cover the changed behavior and record the evidence (`verification-loop`). A fix you did not run is a guess. Re-check that your fix did not undo an earlier fix from the same review.
- Keep the diff on topic. Do not slip unrelated cleanups into a review-fix commit.

Push once per batch, not once per comment: each push can notify reviewers and may invalidate approvals.

---

## 8. Answer Every Thread

- Reply **in the comment thread** it belongs to, not as a new top-level comment.
- Every thread ends in one of four states: fixed (with commit), answered (with fact), deferred (with issue link), declined (with evidence). Silence reads as ignored.
- Resolve a thread yourself only when your platform and the project allow the author to; otherwise leave it for the reviewer after you reply. Do not resolve a thread you only answered with a "no".
- Do not edit or delete reviewer comments. Do not argue in several places at once.
- Summarize the round at the top level once: what changed, what was declined and why, what is deferred, and which checks ran.

---

## 9. Re-request Review

Only when the blocking items are fixed or answered and the checks ran:

1. Push the batch, confirm CI or the local suite is green or state which part is not.
2. Post the round summary (section 8).
3. Re-request review from the same reviewers, using the platform's re-request control; on GitHub an approval is dismissed by a code-changing push only when required reviews and stale-review dismissal are both enabled.
4. If your change altered the approach substantially, update the pull-request description too (`pr-description`).

Do not merge. Do not mark a PR ready, approve it, or change protections unless the user explicitly asked for that action.

---

## 10. Failure Modes

| Failure | Fix |
|---|---|
| Implement first, read all comments later | Section 1 |
| "You are right!" then no change | Fix, or answer with evidence |
| Partial fix of an unclear group | Ask first (section 3) |
| One giant "address feedback" commit | Section 7 |
| Explaining in the thread what the code should say | Fix the code |
| Declining or accepting without checking | Section 2 |
| Re-requesting before the checks ran | Section 7 |

---

## Quick Decision Checklist

- [ ] Read every comment and the summary before editing anything
- [ ] Restated each item; asked about the unclear ones before touching related code
- [ ] Verified each claim against the code (reproduced, searched, traced), not from memory
- [ ] Marked each item blocking, optional, question, or out of scope
- [ ] Fixed the code where a reviewer was confused, instead of only replying
- [ ] No performative agreement, no unverified "done"
- [ ] Declined items have evidence, trade-off and an alternative or question
- [ ] Fixes batched by concern, checks re-run, evidence recorded
- [ ] Every thread answered in place; out-of-scope items filed
- [ ] Round summary posted; review re-requested; nothing merged or approved by the agent

## Deep references

- [Triage and evidence checks](references/triage-and-evidence-checks.md) — read when a comment must be classified (Conventional Comments labels, blocking markers) or verified before acting.
- [Replying, pushing back and closing threads](references/replying-pushing-back-and-closing-threads.md) — read when drafting replies, declining a suggestion, handling a disagreement or an out-of-scope item.
- [Batching fixes and re-requesting review](references/batching-fixes-and-re-requesting-review.md) — read when applying a round of fixes, using suggestion batches, or preparing the re-review request.
- [Trigger evals](references/trigger-evals.md) — read when tuning the description or checking this skill against near-miss neighbors.
