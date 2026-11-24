# Postmortem Structure and Template

Sources: https://sre.google/workbook/postmortem-culture/ · https://sre.google/sre-book/postmortem-culture/ · https://www.atlassian.com/incident-management/handbook/postmortems · https://docs.pagerduty.com/ops-guides/incident-response-guide/postmortem-process · Last verified 2026-11-24

## What the public guides agree on

Four independent sources describe the same core. The SRE book says a postmortem is a written record of an incident: its impact, the actions taken to mitigate or resolve it, the root cause or causes, and follow-ups to prevent recurrence. Atlassian's handbook uses nearly the same four parts. The SRE workbook adds the structure of a strong example: a header with a single owner, collaborators, status and dates; an executive summary; impact quantified with linked data; root causes kept separate from the trigger; a timeline; lessons learned split into what went well, what went poorly and where the team got lucky; and action items with type, priority, one owner and a tracking reference. PagerDuty's process page adds practical habits: scheduling the review within days, putting the timeline first, and tying each timeline item to the metric or page where its data came from.

Where sources differ, this skill takes the stricter option. For example, the SRE book's example is built around "root cause", while Atlassian suggests iterating "why" questions to a true root cause; and an Etsy guide argues that a single cause can be a misleading frame in complex systems and that learning matters more than a list of fixes. The skill therefore asks for known versus assumed causes and a list of contributing factors, and treats a single root cause as acceptable only when the evidence supports it.

## Skeleton

```
# Postmortem: <short neutral title>
Owner: <role or handle>   Contributors: <roles>   Status: draft | in review | approved
Incident date: <date>     Published: <date>        Audience: <who will read it>

## Summary
<2-4 sentences: impact, cause (known/assumed), how it ended>

## Impact
- Duration: <start - end, source>
- Who or what was affected: <count or share, source>
- Data: <lost / at risk / none, source>
- Detection: <how it was noticed, how long after it began>
- Unknown: <item> [PENDING VALIDATION]

## Trigger and cause
- Trigger: <what set it off> (Known | Assumed) - evidence: <ref>
- Underlying conditions: <what made it possible> (Known | Assumed) - evidence: <ref>

## Timeline (times in one stated time zone)
| Time | Event | Source |
|---|---|---|
| 14:02 | Job started | job log line 118 |
| 14:20 | Alert fired for zero rows written | monitor event 7731 |

## Detection and response
<what was tried, in order, with the effect of each>

## What went well
## What went wrong
## Where we got lucky
## Contributing factors

## Follow-ups
| Action | Type | Owner | Due | Link | How we will know it worked |
|---|---|---|---|---|---|

## Open questions
- <question> - owner - [PENDING VALIDATION]
```

## A short worked fragment

```
Trigger: a deployment at 13:55 changed the default import mode (Known - commit and release note).
Underlying conditions: the import reports success when zero rows load (Known - code path and log).
  No alert exists on row count (Known - monitor list). Prior runs loaded about 40k rows (Assumed -
  taken from one earlier log; [PENDING VALIDATION] against the warehouse history).
What went well: the nightly alert on job exit status was configured, and a rollback script already existed.
Where we got lucky: the bad run happened on a Tuesday, before the weekly reports that read the table.
```

Notice the pattern: each sentence says what the evidence is and flags the weak link. That is the quality bar.

## Quality bar for review

- Could a newcomer follow it without the glossary in their head? Define jargon the first time.
- Is impact quantified, and is every number sourced? Where a figure could not be derived, is it labeled as pending?
- Is the cause stated at the level of the system (a missing check, an unclear prompt, an ambiguous default), not a person?
- Does it separate what happened from how to fix it?
- Are the follow-ups specific enough that someone can start tomorrow?
- Is it short enough to be read? Move large logs to an appendix with controlled access.
- Was it published soon enough to still be accurate? The SRE workbook contrasts a bad example published months later with a good one published within a week.

## How an agent should apply this

- Start from the skeleton; remove a section only when you can say why it does not apply.
- Fill the timeline first, from material, then the sections that depend on it.
- Write each causal sentence with its label (Known or Assumed) and evidence reference.
- Keep "what happened" and "what to change" strictly apart.
- Move bulky evidence to an appendix and keep secrets out of it.
