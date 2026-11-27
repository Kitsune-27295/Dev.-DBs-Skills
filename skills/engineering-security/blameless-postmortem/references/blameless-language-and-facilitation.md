# Blameless Language and Facilitation

Sources: https://sre.google/sre-book/postmortem-culture/ · https://sre.google/workbook/postmortem-culture/ · https://extfiles.etsy.com/DebriefingFacilitationGuide.pdf · https://docs.pagerduty.com/ops-guides/incident-response-guide/effective-postmortems · https://www.atlassian.com/incident-management/handbook/postmortems · Last verified 2026-11-24

## What blameless means (and does not)

The SRE book defines the blameless postmortem as one that focuses on contributing causes without indicting individuals or teams, on the assumption that everyone acted in good faith with the information they had at the time. It also says blameless is not uncritical: the document must still identify where the service can improve. Atlassian gives the working argument: when people fear for their standing, they hide or soften facts, and a person who took an action that led to an incident should prompt the question "why did the system allow this, or lead them to believe it was right?" rather than "why did they do it?". PagerDuty adds that very rarely is a failure rooted in a human performing an action; there are usually several contributing factors (a script without rate limiting, out-of-date documentation) that can be fixed.

## Wording rules

| Instead of | Write |
|---|---|
| "John deleted the table" | "The on-call engineer ran the delete against the production database; the prompt did not show the environment" |
| "The agent carelessly ran" | "The agent ran the command without verifying the target; no check required it" |
| "Human error" | The specific conditions: missing guard, ambiguous output, time pressure, stale runbook |
| "The team failed to notice" | "No alert covered this condition; detection took 40 minutes (source)" |
| "If the service had rate limited, it would not have failed" | Describe the failure in the body; put "add rate limiting" in follow-ups |
| "Outage" (when degraded) | "Degraded service: 30 percent of requests slow" |
| "Obviously", "simply", "just" | Delete them; hindsight makes things look obvious |

Refer to people by role. Keep dates and facts unambiguous even when names are omitted. The SRE workbook contrasts a bad example (named individuals, sarcasm, four owners, shared only inside the team, published months later) with a good one (neutral phrasing, one owner, broad audience, published within a week).

## Hindsight and the "should have" trap

Etsy's guide starts from the observation that many investigations produce "findings" about what people did not do, labeled human error, with the recommendation to do the right thing next time. It argues that people do what makes sense to them given their experience, tools and understanding at the time, and that the facilitator's job is to learn what people actually did and how they perceived the situation. The practical consequences for a written postmortem:

- Describe what the responder saw and what options were visible, not what they should have seen.
- Record what was different from a normal day, and what usually protects the system and was absent.
- Keep counterfactuals out of the description; capture them as ideas under follow-ups, where they can be judged on cost and benefit.

## Descriptions before explanations

In debriefs, Etsy's guide recommends asking "how" questions rather than "why": "how" invites a story, while "why" invites the facilitator's own story or a defensive justification. It also tells the facilitator to spend most of the meeting on reconstructing the timeline, ask open questions, include people who were close to the event (and to speak with those who would usually be blamed beforehand), and not to facilitate if you were involved. In a written document by one author (the common case for an agent), adapt this: reconstruct from material first, then record each decision as "at 14:34 the responder had X in view and chose Y", and ask a reviewer who was there to correct the description.

## Running a review conversation

If a human review happens, a workable agenda combining Atlassian's and Etsy's guidance:

1. State that the review is blameless, and why (one sentence).
2. Confirm the timeline; ask what is missing or different.
3. Hear descriptions from each participant; keep fixes for later and have people write ideas down as they come.
4. Ask what went well, what could have gone better, where the team got lucky.
5. Collect improvement ideas without turning them into tickets yet; Etsy suggests giving a small group a couple of working days to refine them, so that the resulting items are effective rather than rushed.
6. Confirm owners and dates for what survives.

Review reminders from PagerDuty: reviewers check for sufficient detail, depth beyond "what went wrong", separation of "what happened" from "how to fix it", and well-scoped action items; the review is not for nitpicking typos.

## Culture pitfalls (from the SRE book)

Blame drives people to hide incidents. Singling out frequent authors stigmatizes reporting. A postmortem written as a formality is forgotten. Too much toil in writing lowers participation. Unreviewed or unshared documents lose their lessons: the chapter says an unreviewed postmortem might as well never have existed. Leadership participation matters.

## How an agent should apply this

- Write about roles and systems; scan the draft for names, "error", "failed to", "should have", "obviously" and rewrite.
- Keep counterfactuals out of the description; move them to follow-ups.
- For each decision point write what was in view at the time and why the choice made sense then.
- When a human reviews, ask them to correct the description of their own steps; do not argue with their account.
- Share it widely enough to be useful (with secrets and personal data removed) and get it reviewed.
