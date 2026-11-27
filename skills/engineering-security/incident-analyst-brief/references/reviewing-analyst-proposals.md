# Reviewing Analyst Proposals and Capturing the Lesson

Sources: https://sre.google/sre-book/managing-incidents/ · https://sre.google/sre-book/emergency-response/ · https://docs.pagerduty.com/ops-guides/incident-response-guide/effective-postmortems · Last verified 2026-11-27

## A proposal is a hypothesis

The analyst's findings are a hypothesis with a patch attached. The SRE guidance puts the first priority on stopping the damage and preserving evidence; it does not say a helper's conclusion is the evidence. In practice, an analyst working from a brief can anchor on a plausible story, mistake a coincidence for a cause, or fix a symptom in the one place it looked. The lead's job is to turn the proposal into knowledge by reproducing it.

## Grades of evidence

Ask which grade each claim reaches:

| Grade | Meaning | What the lead does |
|---|---|---|
| Proven | A test or measurement fails before the fix and passes after, in a run you can repeat | Apply after review |
| Observed | The analyst saw the behavior in a log or trace but did not isolate it | Reproduce once before applying |
| Inferred | Follows from code reading; no run | Treat as a lead for the next experiment |
| Claimed | From an outside page or memory | Verify against the primary source or drop |

A "root cause" at the Inferred or Claimed grade is a theory. The analyst's write-up should label it as such; if it does not, ask.

## The lead's review in five steps

1. **Reproduce the proof** yourself: run the failing test or the measurement at the base commit.
2. **Read the diff for scope.** It should be the smallest change that fixes the cause. Reject drive-by edits, loosened assertions, skipped tests, changed thresholds, and new swallowed exceptions.
3. **Check the prevention.** There should be a test that fails without the fix, and an enforcement point where the failure would have been caught (a check, a type, a lint rule). A documentation line alone is not prevention.
4. **Check the blast-radius claim.** Rerun the search the analyst says it did; add the places it found, or note the ones it could not search.
5. **Apply and verify.** Apply in the lead's tree, one logical change per commit with the test in the same commit (`git-atomic-commits`); run the affected checks and the new guard; confirm with fresh evidence (`verification-loop`).

If the analyst changed something it should not have (a file in the shared tree, a config), stop: review status and diff, restore, and tell the human. Do not hide a boundary breach to keep the finding.

## Why the checks let it through

The most valuable section of an analysis is often the one on why existing checks missed the failure. It leads to the follow-up with real value: a missing test, a monitor on the wrong threshold, a silent failure path. Compare the Google SRE emergency cases: a change got a light canary because it was judged low risk; automation lacked a sanity check on an empty result. In both, the lesson is a check, not an exhortation. A lesson that reads "be more careful" is a sign the analysis stopped too early.

## Recording the lesson

Record while the facts are fresh, in the project's memory channel for lessons (`agent-session-memory`):

```
Lesson: <one line, the rule>
What happened: <symptom and root cause, with the proof reference>
Why it happened: <the missing check>
How to apply: <the guard now in place and where to look next time>
Source: <commit, test name, date>
```

Rules: write the fact and the guard, not the story; link the decision record rather than restating it (`adr-architecture`); no secrets, tokens or personal data; date it so a later sweep can age it out (`memory-hygiene`). If the failure was major (data loss, user impact, repeated recurrence), escalate from a lesson to a full write-up with `blameless-postmortem`.

## Language in the write-up

Public postmortem guidance for human teams asks authors to avoid naming people, avoid the idea of human error as a cause, and avoid mixing a hypothetical fix into the description of what happened. The same applies to an analyst's write-up about a prior agent's or person's change: describe the change and the gap that let it through, and keep "what we should add" in its own section.

## How an agent should apply this

- Treat the proposal as a hypothesis: grade each claim, reproduce the proof before changing anything.
- Reject patches that loosen tests or widen scope; require a failing-before test.
- Insist on the "why it escaped" section; turn it into a check, not an exhortation.
- Record the lesson with the rule, the guard and the date; link instead of restating decisions.
- Escalate to a postmortem when data was at risk or the failure keeps coming back.
