# Sources — Incident Analyst Brief

Every URL below was checked during skill authoring (re-verified 2026-11-27).

Pages were read with a fetch tool that returns an extracted view of each page; where a page could not be read this is stated. No text from any source is reproduced.

| Source | Retrieved status | What it contributed |
|---|---|---|
| [Google SRE book: Managing Incidents](https://sre.google/sre-book/managing-incidents/) | 200 OK 2026-11-27 (summary read) | Three failure modes of an unmanaged incident (tunnel focus, poor communication, freelancing); roles (commander, operations as the only group changing the system, communications, planning); the live shared state document; explicit handoff; when to declare (second team, visible impact, an hour unsolved); stop the bleeding and preserve evidence. |
| [Google SRE book: Emergency Response](https://sre.google/sre-book/emergency-response/) | 200 OK 2026-11-27 (summary read) | Cases where a check was missing (light canary, automation with no sanity check); advice to resolve the immediate issue first and write it up afterwards. Used for "why it escaped". |
| [PagerDuty incident response guide (response.pagerduty.com)](https://response.pagerduty.com) | 301 to docs.pagerduty.com/ops-guides/incident-response-guide, then 200 OK 2026-11-27 (response.pagerduty.com redirects, 301, to the docs URL) | Section map and role list (commander, deputy, scribe, subject-matter expert, liaisons). |
| [PagerDuty: Incident Commander](https://docs.pagerduty.com/ops-guides/incident-response-guide/incident-commander) | 200 OK 2026-11-27 | The commander's purpose is to keep the incident moving; the commander delegates and does not perform remediations or read logs; deep technical knowledge is not required. |
| [PagerDuty: Effective Postmortems](https://docs.pagerduty.com/ops-guides/incident-response-guide/effective-postmortems) | 200 OK 2026-11-27 | Dos and don'ts used for report language: avoid naming people, avoid "human error", keep hypothetical fixes out of the description. |
| Internal project skill read for method only, no text reused | Not re-read in this pass | The overall flow (symptom note, search for a recorded lesson, parallel analyst in the background, proposal-only analyst, lead review and lesson capture). All names, tools, models and paths were dropped; the flow was rewritten from the public sources above. |

## Reading limits

- The fetch tool summarizes; statements are limited to what the extracted text supported.
- The PagerDuty site is a documentation index; only the pages named above were read.
- The mapping of human roles onto lead and analyst agents is this skill's own adaptation, not a claim of the sources.

- The PagerDuty index (docs.pagerduty.com/ops-guides/incident-response-guide) itself was not re-fetched; the role list for scribe, deputy and liaisons is from the earlier read and not re-confirmed.

## Claims not adopted as fact

- PagerDuty role list beyond commander (deputy, scribe, subject-matter expert, liaisons): not re-confirmed on 2026-11-27, so the skill uses it only as the mapping reference file's analogy.

- Anything about agents and hooks: whether a given harness can start a subagent from a hook is harness-specific and was not verified here; the skill states it as a limit to be checked.
- Time thresholds for declaring an incident are human-team guidance (one hour in the SRE chapter) and are applied to agents only as a rough analogy ("before the third guess").
