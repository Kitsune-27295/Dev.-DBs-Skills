# Action Items and Follow-Through

Sources: https://www.atlassian.com/incident-management/handbook/postmortems · https://sre.google/workbook/postmortem-culture/ · https://sre.google/sre-book/postmortem-culture/ · https://extfiles.etsy.com/DebriefingFacilitationGuide.pdf · Last verified 2026-11-27

## Why follow-ups decide whether it was worth writing

The SRE workbook says to reward closing action items, not just writing postmortems, and lists recurring incidents as a warning sign: ask whether action items close too slowly or whether feature work always outweighs reliability. Atlassian tracks postmortem actions as real work items in the owning team's backlog, links them from the postmortem as priority actions (fixes for root causes) or improvement actions (other improvements), and attaches an agreed time target (four or eight weeks, depending on the service) with reminders and reports. Approvers sign off both on the findings and on the claim that the priority actions address the cause, and they often ask for more.

## Types of follow-up

Atlassian, drawing on Google authors, lists six categories to make sure the document covers short and long term. The SRE workbook uses a similar set of types (prevent, detect, mitigate, repair, investigate).

| Type | Use it for |
|---|---|
| Investigate this incident | Open questions about what happened and why |
| Mitigate this incident | What was done now to limit the damage (record it; usually already done) |
| Repair damage | Restoring data, fixing machines, removing temporary reroutes |
| Detect future incidents | Shortening time to notice: monitoring, alerting, plausibility checks |
| Mitigate future incidents | Reducing severity or duration: graceful degradation, playbooks, process changes |
| Prevent future incidents | Stopping recurrence: code stability, validation, tests, provisioning |

Atlassian's rule of thumb: the "mitigate future" and "prevent future" categories are the most likely to address the cause, so make sure you have at least one.

## Wording that gets done

Actionable, Specific, Bounded (the Google authors' criteria, as cited by Atlassian):

| From | To |
|---|---|
| Investigate monitoring for this scenario | Add alerting for every case where this service returns more than 1 percent errors |
| Fix the issue that caused the outage | Handle an invalid postal code in the address form without crashing |
| Make sure engineers check the schema parses before updating | Add an automated pre-merge check for schema changes |

Start with a verb; produce an outcome, not a process; say what is out of scope; say how to tell it is finished.

## The follow-up table

```
| Action | Type | Owner | Due | Link | How we will know it worked |
| Add alert on zero rows written by nightly load | Detect | on-call lead | 2026-12-08 | TICKET-123 | Synthetic zero-row run pages within 10 min |
| Add pre-merge rejection of schema changes with no rollback script | Prevent | platform owner | 2026-12-15 | TICKET-124 | Test PR with a missing script fails the check |
| Restore the 3 missing days from the verified backup | Repair | data owner | 2026-11-27 | TICKET-125 | Row counts match the source; sample queries pass |
```

Rules:

- **One owner per item** (a role or person), not "the team"; the SRE workbook's bad example has several owners and one tracking bug, which blurs accountability.
- **A date**, and a tracking link where work is actually tracked.
- **A validation step**: how you will observe that it worked (`verification-loop`). Prefer a test or a measurable signal over "done".
- **Priority**: say which items address the cause. Items that merely mitigate should not crowd them out.
- **Do not invent owners or dates.** If none was agreed, list the item as "proposed, owner needed" and tell the human.
- **Prefer system changes** over reminders, training and "be more careful"; the SRE workbook classes changing human behavior as less reliable than changing systems.
- **Beware the dashboard trap.** Etsy warns that adding one more graph to check can make signal harder to find. Ask whether a follow-up reduces the need to look, or adds to it.
- **Remediation is not mandatory.** Etsy's guide says a good debrief need not end with remediation items, and that quick fixes made out of the urge to do something can add complexity. List only items you can defend; record the rest as learning.

## Review and closing

- Review open items on a schedule (weekly for new ones, then monthly), and report the count of overdue items.
- An item closes only with its validation evidence, linked.
- When the last priority item closes, update the postmortem's status and add a short closing note: what changed, how it was verified.
- Link the postmortem from any decision record that changed (`adr-architecture`) and from the lesson entry in `agent-session-memory`, so the next session finds it.

## How an agent should apply this

- Draft follow-ups by type, check that at least one targets the cause, and reword each to Actionable, Specific, Bounded.
- Give each an owner, a date, a tracking link and a validation step, or mark it "proposed, owner needed" and ask.
- Prefer a check, a default or a guard to a reminder or a training item.
- Create or propose the tracking items, but do not publish tickets externally without confirmation.
- Report the open items and overdue count in each later session until closed.
