# Comments and Docs Must Stand Alone at HEAD (Authoring-Session Leak Taxonomy)

Sources: https://google.github.io/eng-practices/review/reviewer/looking-for.html · Last verified 2026-11-27

Ownership: [comments-why-not-what.md](comments-why-not-what.md) (CMT) owns every comment rule (CM-01 to CM-06). This file adds only one rule, CM-07, and the taxonomy that makes it checkable. It does not restate what to write; it names what must not leak into the text. The taxonomy is the author's synthesis; ideas were taken from third-party agent-skill material read for ideas only (no text reused), and the position that task chatter and history belong in version control and the review tool is the one already recorded in `comments-why-not-what.md` from the Google review standard (the rest of the taxonomy is inference).

## CM-07: the single resolvability test

For every comment, docstring, README sentence or log message you wrote, ask: **could a reader at the current commit, with no access to the chat session, the PR thread, an uncommitted draft or your memory, resolve every reference and verify every claim in it?** If not, restate the surviving fact from the repository's point of view, or delete the text. Deletion alone is wrong when the passage carried a true constraint: keep the constraint, drop the narrator.

## Taxonomy of leaks

| Leak | Typical text | What to do |
|---|---|---|
| Dead-session citation | "per decision 7", "audit item C2", "plan section 4", phase labels like "step T4", "as agreed earlier" | Cite a committed owner by path or issue number; else drop the citation and state its factual clause |
| Narrating the change | "now uses X", "no longer", "the old handler", "this cut", "v2 of this" | State present behavior. A fixed regression becomes a present-tense counterfactual: "without the lock, two writers interleave" |
| Review or stack vantage | "a later PR adds", "the previous commit", "addresses the review", "reviewer asked" | State the shipped mechanism; move deferred work to a TODO with an issue (CM-05) |
| Review-advantage prose | "this cast is safe because...", "this is correct since..." aimed at a reviewer | State the invariant that makes it safe, or delete if the code shows it |
| Derivation transcript | "first we X, then Y", a proof of an obvious branch | Delete; keep only a non-obvious contract or invariant |
| Hedge or planning residue | "probably fine for now", "should be enough" | Replace by the measured or actual bound, or a TODO with a gap (CM-05) |
| Working-language slip | A fragment in another language inside otherwise single-language prose | Translate or delete |

## What is not a leak (keep)

- Issue and ticket references (`#123`, `TODO(owner): ...`): they resolve at HEAD.
- Required justification text: lint-suppression reasons, coverage-ignore reasons, empty-catch explanations. Fix a false reason; never delete a true one.
- Present-tense counterfactuals that pin a regression.
- Measured bounds ("measured: 512 nested items take about 0.15 s") where the word "measured" carries the evidence.
- Runtime old/new states ("the old connection drains before the new one accepts"): that is lifecycle, not change history.
- External references that resolve outside the repo by design: RFC or standard sections.
- Committed docs (ADRs, changelogs, postmortems) whose job is to hold change history: leaks are judged against a file's purpose, so history there is its content.

## Overcorrection traps

Before deleting, list the claims in the passage: who must do what, under which condition, in what order, with what guarantee. A trim that turns "must" into "can", promotes a hypothetical to a shipped feature, drops the one true constraint, or removes the evidence word is a regression worse than the leak.

## Example

```python
# Leaky: addresses a reviewer and narrates history.
# Per review round 2 we no longer retry here; the old loop was unsafe,
# so this is fine now and a later PR will add backoff.
return client.send(msg)

# Stands alone: state, constraint, tracked gap.
# Not retried here: send() is not idempotent (duplicate charges).
# TODO(#412): add backoff once idempotency keys land.
return client.send(msg)
```

## How an agent should apply this

- Before handoff, re-read each comment you added for session words: "now", "no longer", "earlier", "review", "later PR", step labels, decision numbers.
- Apply the resolvability test (CM-07); fix by restating from the repo's vantage, not by blind deletion.
- Keep what resolves at HEAD: issue links, suppression reasons, measured bounds, standard citations.
- Put the story of the change in the commit message or PR, not in the code (CM-03).
- Check the passage's claims before and after trimming so no obligation is weakened.
