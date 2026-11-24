# Timeline, Evidence and Redaction

Sources: https://docs.pagerduty.com/ops-guides/incident-response-guide/postmortem-process · https://extfiles.etsy.com/DebriefingFacilitationGuide.pdf · https://sre.google/sre-book/postmortem-culture/ · Last verified 2026-11-24

## The timeline is the spine

Etsy's facilitation guide treats the annotated timeline, agreed by everyone involved, as one of the most important outputs of a debrief, and recommends building it before any discussion of fixes: any remediation based on an inaccurate timeline is less effective or even harmful. PagerDuty's postmortem process makes the timeline the first thing to write and asks that each item be tied to a metric or a page where the data came from, with queries and commands posted so others can see how the data was gathered. The SRE book adds that reviewers check that key data was captured and that impact assessments are complete.

## Entry format

One event per row: time (one time zone, stated), event (what happened, in neutral words), source (where to look). Order by clock, not by when you learned of it.

```
| 13:55 | Release 4.2 deployed | deploy log entry 2210 |
| 14:20 | Alert "zero rows written" fired | monitor event 7731 |
| 14:34 | Responder reran the job with the cache cleared; same result | session notes, line 41 |
| 14:50 | Rollback to 4.1 completed | deploy log entry 2215 |
```

Rules:

- **No source, no entry.** If an event is believed but unsourced, write it with `[PENDING VALIDATION]` and list how to confirm it.
- **Observations versus beliefs.** Keep them apart: "Log shows 0 rows at 14:02" is an observation; "responder believed the job had completed" is a statement of belief taken from a message. Both belong, labeled. Etsy separates objective data (directly observable: seen, heard, counted, measured, with no conjecture) from subjective data (opinions, judgments, assumptions, beliefs), and says the second kind provides the context for decisions.
- **Describe actions, not intentions.** "Ran the delete script against environment B" not "carelessly ran".
- **Include the quiet parts.** Gaps (for example 40 minutes before the alert was acknowledged) are data; mark them as gaps and do not fill them with guesses.
- **Time sources can disagree.** Clocks and log time zones differ; state which you used and note any skew you saw.

## Known versus assumed

For every causal or quantitative claim, ask: what could I show a skeptical reader? If the answer is a log line, a test, a diff or a measurement, it is Known. If the answer is "it fits", it is Assumed. Write the label, and for Assumed state what would settle it.

| Statement | Label | Evidence or what would settle it |
|---|---|---|
| The default mode changed in release 4.2 | Known | diff of the release |
| The change caused the zero-row loads | Assumed | rerun at 4.1 vs 4.2 with the same input |
| About 40k rows is normal | Assumed | warehouse history for the last 30 runs |

Use `[PENDING VALIDATION]` on the item itself so a search for the marker lists everything still open. At the end of the document, count the markers; a postmortem approved with markers outstanding must list an owner and date for each.

## Evidence handling

- Keep original material (logs, chat exports, traces) in a place with access control; link to it from the document and do not paste it in wholesale.
- Quote the minimal excerpt that supports the claim.
- Record how an excerpt was obtained (the command or the query) so someone else can regenerate it.
- Do not edit evidence to look better. PagerDuty's guidance on effective postmortems is blunt that details must not be changed to make things look better, because the document loses its value.

## Redaction: never reproduce secrets

Logs often contain material that must not be copied into a document that will be widely read:

| Class | Examples | Treatment |
|---|---|---|
| Credentials | API keys, tokens, passwords, private keys, signed URLs | Replace with `[REDACTED: token]`; if one was exposed, say "a credential appeared in the log" and open a rotation follow-up (owner, date) |
| Connection data | Connection strings, internal hostnames, addresses | Replace with a role label such as `[primary database host]` |
| Personal data | Names, emails, phone numbers, identifiers of end users | Remove or use a stable pseudonym; the SRE book says postmortems must not include information that could identify end users |
| Customer content | Row contents, messages, uploaded files | Describe by shape and count, not by content |

Practical steps: scan the draft for patterns such as long random strings, "Authorization", "password", "secret", "token" and address-like strings before sharing; check screenshots and attachments, which hide secrets in places text search cannot see; and if a secret was exposed in the incident itself, treat that as a finding and a follow-up, not a footnote.

## How an agent should apply this

- Build the timeline from material first, one sourced row per event, in one time zone.
- Mark every unsourced fact, unknown number or inferred cause with `[PENDING VALIDATION]` and say how it could be confirmed.
- Label causal statements Known or Assumed; give the evidence or the test that would settle each.
- Redact secrets and personal data in every excerpt, screenshot and appendix before writing the final version; add a rotation follow-up if one was exposed.
- Report counts of pending markers and who owns each in your hand-off message.
