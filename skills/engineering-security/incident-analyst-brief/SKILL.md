---
name: incident-analyst-brief
description: "How to brief a background analyst agent when something unexpected fails during agent work (a test, build, gate or guard refusal, a fix that did not work, a regression, a user-reported defect). Write a structured brief (symptom, evidence, expected, tried so far, scope, base commit, constraints, where the result goes), search for a recorded lesson first, keep fixing the symptom meanwhile, and keep one rule: the analyst only proposes (a report and a patch), the lead applies. Not for the root-cause method itself (`diagnosing-bugs`) or the post-incident write-up (`blameless-postmortem`). Use when an unexpected failure needs a second pair of eyes in parallel, when delegating root-cause analysis to a subagent, or when a failure has resisted one focused attempt."
---

# Incident Analyst Brief

One idea: an unexpected failure gets two tracks at once, and they must not collide. The lead keeps fixing the symptom and keeps control of the shared tree; a background analyst, given a brief that stands on its own, finds the root cause and the missing safeguard and returns a proposal. The analyst proposes; the lead applies. The human-incident practice behind this (declare early, separate roles, one group changes the system, a live written state) is in [references/sources.md](references/sources.md).

Boundary: the diagnosis method itself belongs to `diagnosing-bugs`; choosing the analyst's model tier and effort, and the delegation call itself, belongs to `model-effort-routing`; saving the lesson belongs to `agent-session-memory`; the long-form write-up after a major failure belongs to `blameless-postmortem`; destructive or irreversible actions during a failure go through `ops-safety`; proving the fix worked belongs to `verification-loop`.

---

## 1. Launch criteria

Launch an analyst when any of these is true:

- The failure is unexpected and one focused attempt (a few minutes of reading and a first fix) did not explain it.
- A fix you applied did not work, or made things different but not better.
- A guard, gate or check refused something you believed was fine.
- A regression appeared in something that passed before.
- A person reports a defect you cannot reproduce from the report alone.
- A second area or team would have to be involved to fix it.

Do not launch for: a typo-level error the message already explains; a failure with a recorded lesson that still applies (apply it); a problem that needs a human decision rather than analysis.

Declare early. Human incident practice favors raising an incident as soon as a second team is needed, the impact is visible, or an hour of focused analysis has not solved it; for an agent, "early" means before the third guess.

---

## 2. Before you launch (two minutes)

1. **Write the symptom exactly:** the command, the output excerpt (secrets removed), the file and commit, what you expected, what you already tried.
2. **Search for a recorded lesson first.** Look in the project's lessons and decisions (`agent-session-memory`) and, if the project keeps one, its incident records, with two or three search terms from the error text. If a lesson exists, link it and ask why its guard did not hold. Do not open a second investigation of the same failure. Check the lesson's age and whether its claims still hold (`memory-hygiene`).
3. **Keep fixing.** The analyst is not a substitute for your own work. It is the second half: root cause and prevention while you restore progress.
4. **Check the environment is safe to share.** If the failure involves data loss or a production system, stop and use `ops-safety` before anyone runs anything.

---

## 3. The brief

The analyst starts with no memory of your session. The brief is its entire context. Fill every field; write "unknown" where true and never leave a placeholder.

```
INCIDENT BRIEF
Symptom:       <what happened, one or two sentences>
Evidence:      <exact command, output excerpt, file:line, commit, environment; no secrets>
Expected:      <what should have happened>
Tried so far:  <each attempt and its effect, including ones that made no difference>
Scope guess:   <area or component, or "unknown">
Base commit:   <the exact revision the symptom was seen on>
Constraints:   <what must not break; what is read-only; no secrets; no destructive actions>
Deliverable:   <report as the final message; patch as a diff; where each goes>
Stop rule:     <time or step budget, and when to report "not found" instead of guessing>
```

Why each field:

| Field | Reason |
|---|---|
| Evidence | An analyst that cannot see the failure reproduces a different one |
| Tried so far | Prevents repeating dead ends and shows which theories are already killed |
| Base commit | Failures are tied to a revision; without it, analysis drifts onto code that has moved |
| Constraints | Makes read-only and no-secrets part of the task, not a hope |
| Stop rule | Bounds spend and forces an honest "not found" |

Do not restate the method in the brief (the analyst can load the method skills). Do give it the pointer to the neighboring skills it should use: `diagnosing-bugs` for the loop, and the project's own docs for conventions. A detailed template with a worked example is in [references/analyst-brief-template.md](references/analyst-brief-template.md).

---

## 4. Delegate it correctly

- Run the analyst in the background so the lead keeps working. Brief it in the same turn as you decide, and do not wait on it.
- Pick the tier and effort with `model-effort-routing`: root-cause analysis is reasoning-heavy and consequential, so it is not the cheap tier by default; do not copy the lead's setting by habit either. State your choice in the delegation call.
- One analyst per root cause. Two simultaneous failures get two briefs; a fan-out of agents on one failure multiplies cost and contradictions.
- Do not forward the whole conversation. A brief that fits on one screen beats a transcript.

---

## 5. What the analyst does

1. **Reproduce or localize** the failure without touching the lead's working tree: read-only reads, or an isolated copy of the repository at the base commit.
2. **Research in order and stop at the first level that answers:** the project's own docs and decision records, the code and its history, recorded lessons, then the public web with primary sources.
3. **Find the root cause with proof,** such as a failing test or a measurement, not the first plausible story. Mark claims that are not proven.
4. **Ask why the existing checks let it through:** which test, check or doc should have caught it.
5. **Check the blast radius:** search for the same pattern elsewhere.
6. **Propose the smallest fix plus the prevention:** a test that fails before and passes after, and the enforcement point that keeps the failure from returning.

---

## 6. The report: proposal, not change

The analyst's final message is the report (a subagent often cannot write files; the lead saves it). Keep it short and structured:

| Section | Content |
|---|---|
| Symptom | One paragraph with the evidence |
| Root cause | The cause and the proof (test name, measurement, `file:line`); known versus assumed |
| Why it escaped | Which check was missing or too weak |
| Knowledge consulted | Docs, lessons, URLs; mark which are claims and not facts |
| Fix | The minimal change as a diff, not applied |
| Prevention | Enforcement point and the failing-before evidence; a doc line only after that |
| Blast radius | Other places with the same pattern, or "none found by <search>" |
| Risks and not verified | What the patch could break; what was not run and why |

---

## 7. After the report (lead)

1. **Treat the report as a proposal.** It is not evidence until you have reproduced the failing test or measurement yourself.
2. Review the diff against project rules; apply it in the lead's tree, one logical change per commit (`git-atomic-commits`), the test in the same commit as the fix. Never delete, skip or loosen a failing test to turn it green.
3. Run the checks the change can affect, and the new guard, then confirm with fresh evidence (`verification-loop`).
4. **Record the lesson:** the fact, why it happened, how to apply it (`agent-session-memory`), linking the decision record instead of restating it (`adr-architecture` if a decision changed).
5. For a major failure (data loss, user impact, repeated recurrence), write it up with `blameless-postmortem`.
6. State in your report what failed, which guard now exists, and what remains open.

---

## 8. Limits to state

- The trigger is a rule, not a hook. A harness hook can inject a reminder after a failure but, in general, cannot start a subagent for you, so launching depends on the lead following this skill. Say so if asked for a guarantee.
- "Read-only on the shared tree" is an instruction in the brief. If it must be guaranteed, enforce it with the harness (permission rules or a hook scoped to the analyst), then verify by looking at the working tree status and diff after the run.
- A guard that blocks the analyst is reported to the human, not worked around.

---

## Quick Decision Checklist

- [ ] Is this unexpected, and did one focused attempt fail? Else do not launch.
- [ ] Searched for a recorded lesson with 2-3 terms; linked it if found?
- [ ] Brief has all nine fields, no placeholders, no secrets, an exact base commit?
- [ ] Analyst runs in the background with a tier chosen via `model-effort-routing`?
- [ ] Constraints say: propose only, read-only, no destructive actions?
- [ ] I keep fixing the symptom meanwhile and do not wait?
- [ ] I reproduced the proof before applying anything from the report?
- [ ] Lesson recorded; postmortem written if the failure was major?

## Deep references

- [Analyst brief template](references/analyst-brief-template.md) — the nine fields with a worked example and common mistakes.
- [Roles and live state for agent incidents](references/roles-and-live-state.md) — lead, analyst and scribe mapped onto human incident roles; one actor changes the system; the running state note; handoff.
- [Reviewing analyst proposals and capturing the lesson](references/reviewing-analyst-proposals.md) — how the lead tests a proposal, evidence grades, and recording the lesson.
- [Trigger evals](references/trigger-evals.md) — three should-trigger and three near-miss prompts.
- [Sources](references/sources.md) — URLs read, status, claims not adopted.
