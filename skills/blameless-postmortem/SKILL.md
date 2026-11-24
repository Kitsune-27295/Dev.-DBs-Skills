---
name: blameless-postmortem
description: "Write a blameless incident postmortem an agent or team can trust: impact quantified from sources, a timeline where every entry names its source, known cause kept apart from assumed cause, trigger versus contributing factors, what went well, where we got lucky, follow-ups each with one owner and a date, [PENDING VALIDATION] markers for anything unproven, and no secrets or personal data copied from logs. Systems, signals and decisions are described, never a person named as the cause. Use when something broke and has been mitigated, when an outage ended, when data was lost or a guard failed, or when asked for a post-mortem, an incident write-up or 'what went wrong'."
---

# Blameless Postmortem

One idea: a postmortem is a written record that lets the next person (or agent) see what happened, why the system allowed it, and what will change, built only from evidence and owned follow-ups. It describes systems, signals and decisions; it never names a person as the cause. Sources and their limits: [references/sources.md](references/sources.md).

Boundary: finding the cause while the failure is live belongs to `diagnosing-bugs`, and parallel analysis to `incident-analyst-brief`; safe handling of destructive steps during the incident belongs to `ops-safety`; recording a one-line lesson in project memory belongs to `agent-session-memory`; recording a lasting design decision that comes out of it belongs to `adr-architecture`; proving a follow-up works belongs to `verification-loop`.

---

## 1. When to write one

Write a postmortem when any of these happened (agree the triggers before the next incident, so the choice is not made in a bad moment):

- User-visible downtime or degradation beyond a threshold you set.
- Any data loss, or a near miss on data.
- Someone had to intervene by hand (a rollback, a reroute, a restore).
- Resolution took longer than a threshold.
- A monitor, test or guard failed to catch it, or a guard blocked work wrongly.
- The same class of failure has happened before.

A smaller lesson goes to `agent-session-memory`. Do not write a postmortem as a ritual; a form filled to tick a box teaches nothing.

---

## 2. Rules that hold for the whole document

1. **Blameless by construction.** Refer to roles ("the on-call engineer", "the agent session"), not names. Ask "why did the system allow this action, or make it look right?", never "why did X do this?". Avoid "human error" as a cause; it ends analysis where it should start.
2. **Every timeline entry has a source** (log line, command output, ticket, chat message, commit, graph). No source, no entry, or the entry is marked `[PENDING VALIDATION]`.
3. **Known is not assumed.** Label each causal statement as Known (proved by evidence you can point to) or Assumed (plausible, not proved). Never let an assumption sit in a sentence that reads like a fact.
4. **Describe first, improve second.** Keep "what happened" free of "if only". Hypothetical fixes go under follow-ups.
5. **Never reproduce secrets.** No tokens, keys, passwords, connection strings, personal data or customer content from logs. Redact with a marker such as `[REDACTED: api key]` and say where the original lives (access-controlled).
6. **Neutral language.** No sarcasm, no loaded adjectives, "outage" only when it was one.
7. **One owner for the document, one owner per follow-up,** and a date for each. An unowned follow-up is a wish.

---

## 3. Structure

Use this order. Details and a skeleton: [references/postmortem-structure-and-template.md](references/postmortem-structure-and-template.md).

| Section | Content | Evidence rule |
|---|---|---|
| Header | Title, owner, contributors, status (draft, in review, approved), incident date, publication date, audience | Dates as written in the sources |
| Summary | Two to four sentences: impact, cause (labeled known or assumed), how it ended | Matches the sections below |
| Impact | Who or what, how long, how much (users, requests, data, money, time), how it was detected | Each number has a source; unknown numbers stay `[PENDING VALIDATION]` |
| Trigger and cause | The trigger (what set it off) separate from the underlying conditions | Known or assumed for each |
| Timeline | Clock-ordered entries, one per event: time, event, source | See [references/timeline-evidence-and-redaction.md](references/timeline-evidence-and-redaction.md) |
| Detection and response | How it was found, who or what responded, what was tried and its effect | Sourced |
| What went well | Things that limited the damage or sped recovery | Sourced |
| What went wrong | Gaps in detection, tooling, documentation, process | Systems language |
| Where we got lucky | Things that could have made it worse and did not, by chance | Honest, even when uncomfortable |
| Contributing factors | Conditions that made the incident possible or worse, beyond the trigger | Known or assumed |
| Follow-ups | Table: action, type, owner, due date, tracking link, validation | See section 5 |
| Open questions | What is not yet known, and who will find out | Each a `[PENDING VALIDATION]` item |

---

## 4. Method: build it from material, not from memory

1. **Collect the material** (logs, chat, tickets, commits, dashboards, session notes) and keep the originals where access is controlled. Write from the material, not from a recollection of the conversation.
2. **Draft the timeline first.** It anchors everything. Put one source next to each entry. Separate observed facts (a log shows X at 14:02) from what people said they believed at the time (a message says "I thought the job had finished"): label the second kind as such, and keep them.
3. **Ask for descriptions before explanations.** For each decision point, record what the responder saw, what options they considered, and what made the choice reasonable at that moment. Hindsight makes decisions look careless; the postmortem must not inherit that distortion.
4. **Then name the trigger and the contributing factors.** Several factors are normal. Do not collapse to a single root cause unless the evidence supports it; mark which statements are proven.
5. **Record what went well and where you got lucky** before the follow-ups, so recovery strengths are protected, not rebuilt by accident.
6. **Then write follow-ups** (section 5) and give each an owner and a date, or list it as proposed and ask for an owner. Do not invent an owner or a date.
7. **Review before it is final:** the owner and one person who was not in the incident read it for completeness, tone and evidence. Check every number against its source.
8. **Close the loop:** link the postmortem from the lesson in `agent-session-memory`, from any decision record it changes (`adr-architecture`), and from `incident-analyst-brief` material if an analyst was used.

When you are the agent writing it, the same rule applies to you: you describe your own earlier steps as system behavior ("the agent ran the delete against the wrong environment because the target was not shown") and mark what you cannot verify.

---

## 5. Follow-ups that get done

A good follow-up is Actionable (starts with a verb, produces a usable outcome), Specific (scope is narrow, what is excluded is clear) and Bounded (you can tell when it is finished). Cover the types below (at least one aimed at the cause):

| Type | Question it answers | Example |
|---|---|---|
| Investigate | What happened and why? | Reproduce the stalled job with the saved input and attach the trace |
| Mitigate (this time) | How did we limit this occurrence? | Roll back the release (done) |
| Repair | How do we undo the damage? | Restore the missing rows from the verified backup |
| Detect | How do we notice sooner? | Alert when the nightly load writes zero rows |
| Mitigate (future) | How do we reduce size or duration next time? | Add a restore runbook and rehearse it |
| Prevent | How do we stop recurrence? | Add a pre-merge check that rejects a schema change without a rollback script |

Rules: at least one Prevent or future-Mitigate item aimed at the cause, not only the symptom; prefer changing the system (a check, a guard, a default) over "be more careful" or "train people"; one owner and a due date each; a tracking link; a validation step saying how you will know it worked (`verification-loop`). Review the open list on a schedule; a postmortem whose follow-ups never close has taught nothing.

Do not generate remediation items to satisfy the urge to "do something". An item that adds another dashboard to watch can make the system harder to read. If learning is the main outcome, say so, and list only items you can defend. Detail: [references/action-items-and-follow-through.md](references/action-items-and-follow-through.md) and [references/blameless-language-and-facilitation.md](references/blameless-language-and-facilitation.md).

---

## 6. Anti-patterns

- Naming a person or a team as the cause, or writing "operator error".
- A timeline from memory, with no sources; a precise-looking number with no source.
- A single root cause stated as fact when the evidence is an assumption.
- "Alternate reality" sentences in the description ("if the service had rate limited, it would not have failed").
- Follow-ups with no owner, no date, or a verb like "improve" or "investigate" with no bound.
- Copying a log excerpt that contains a token, a connection string or a customer's data.
- Writing it months later, or never reviewing it, or never sharing it.
- Skipping "where we got lucky" because it is awkward.

---

## Quick Decision Checklist

- [ ] Did a trigger from section 1 apply, and is there material to write from?
- [ ] Is every timeline entry sourced, and every missing fact marked `[PENDING VALIDATION]`?
- [ ] Is each causal claim labeled known or assumed?
- [ ] Are trigger and contributing factors separate? Is the description free of "if only"?
- [ ] Roles, not names; no "human error"; neutral tone?
- [ ] Secrets and personal data redacted from every excerpt?
- [ ] Did-well, went-wrong and got-lucky all present?
- [ ] Each follow-up has type, one owner, a date, a link and a validation step (or is listed as proposed)?
- [ ] At least one follow-up targets the cause?
- [ ] Reviewed by someone outside the incident; linked from memory and decision records?

## Deep references

- [Structure and template](references/postmortem-structure-and-template.md) — the sections, a fill-in skeleton, a worked fragment, quality bar.
- [Timeline, evidence and redaction](references/timeline-evidence-and-redaction.md) — sourcing entries, known versus assumed, pending validation, keeping secrets out.
- [Blameless language and facilitation](references/blameless-language-and-facilitation.md) — wording rules, descriptions before explanations, running a review conversation.
- [Action items and follow-through](references/action-items-and-follow-through.md) — types, wording, owners and dates, review and closing.
- [Sources](references/sources.md) — URLs read, status, claims not adopted.
