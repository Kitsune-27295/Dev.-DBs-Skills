# Batching Fixes and Re-requesting Review

Sources: https://docs.github.com/en/pull-requests/how-tos/review-pull-requests/incorporating-feedback-in-your-pull-request · https://docs.github.com/en/pull-requests/how-tos/review-pull-requests/reviewing-proposed-changes-in-a-pull-request · https://google.github.io/eng-practices/review/developer/small-cls.html · https://google.github.io/eng-practices/review/developer/handling-comments.html · Last verified 2026-11-27

## What the sources say

**GitHub, incorporating feedback.** Suggested changes can be applied straight from the pull request if you have write access. Several suggestions can be added to a batch and committed together, and applying one suggestion or a batch creates a single commit on the pull request branch; people who suggested the changes are credited as co-authors, and you write the commit message. For a fresh look you re-request a review from the reviewer via the sidebar after substantial changes. Feedback that is out of scope can become a new issue. The page also mentions delegating review comments to a Copilot cloud agent where available; treat that as another author whose output you still verify.

**GitHub, reviewing proposed changes.** A review is submitted as comment, approve or request changes. "Request changes" is informational unless a ruleset or classic branch protection with "require a pull request" is configured; then, if a collaborator with write access or more requested changes, the pull request cannot merge until that same collaborator approves (or the review is dismissed). If required reviews and stale-review dismissal are both enabled, pushing a code-changing commit to an approved pull request dismisses the approval, so it must be reviewed again. Authors cannot approve their own pull requests.

**Google, small changes.** A change should be one self-contained, tested piece; refactorings are best kept apart from features and bug fixes, though trivial local cleanups can ride along. Follow-up fixes that grow into a different change are a sign to split instead of piling more into the same change.

## Procedure for a round of fixes

1. Finish triage (see `triage-and-evidence-checks.md`) so you know the whole list before the first edit.
2. Order the work: blocking correctness and security items, then mechanical items (typos, imports, names), then larger refactors. Larger refactors last because they may change line numbers and make earlier threads outdated.
3. Group by concern, not by comment number. Two comments about the same function become one commit; one comment touching three modules may become one commit if it is one idea.
4. After each group, run the checks that cover that area and note the result. Run the full relevant suite before the push.
5. Commit messages state the reason: `fix: guard empty export list (review feedback)`; keep them in the project's style (`git-atomic-commits`). Use fixup commits only when the project squashes on merge and the reviewers prefer them; otherwise add normal commits so reviewers can read only the delta.
6. Do not rewrite history the reviewers have already seen unless the project's rules allow it; force-pushing mid-review hides what changed (`git-atomic-commits` covers safe rewriting).
7. Push once per batch.

Pre-push self-check:

```text
[ ] every blocking item fixed or answered with evidence
[ ] checks for touched areas ran; output saved for the summary
[ ] no unrelated edits in the fix commits
[ ] earlier fixes from this round still hold (re-run the combined suite)
[ ] description still true? (update the pull-request text if the approach changed)
```

## Round summary template

```text
Round 2 summary
Fixed:    #1 null user on logout (3f2a9c1), #3 rename (a81b7d0)
Answered: #4 timeout rationale (comment added)
Deferred: #6 retry helper -> tracked in the linked issue
Declined: #2 extra branch (unreachable; evidence in thread)
Checks:   unit + integration suites green locally; CI pending
```

## Re-requesting

- Re-request only after the blocking items are done and the summary is posted; reviewers then know what to look at.
- Request the same reviewers; do not swap in a different one to avoid a disagreement.
- Expect a stale approval to need renewing if the repository dismisses approvals on new commits; this is a property of the protection rules, not a sign of rejection.
- An author cannot approve their own pull request, and an agent must not approve, merge, or override protections on its own authority.

## Failure modes

- Pushing after every single comment, which spams notifications and invalidates approvals repeatedly.
- One "address review feedback" commit that mixes ten changes.
- Large refactors in a fix round that bury the reviewed lines.
- Not re-running checks after merging two fixes that touch the same code.
- Re-requesting with unanswered threads.

## How an agent should apply this

- Plan the whole round first, then fix in concern-sized commits and push once.
- Verify after each group and before the push; keep the commands and outcomes for the summary (`verification-loop`).
- Post a summary with fixed, answered, deferred, declined and checks, then re-request review from the same reviewers.
- Keep the review-fix diff focused; refactors beyond the feedback go to a separate change.
- Never approve, merge or alter branch protection unless the user explicitly asks for that exact action.
