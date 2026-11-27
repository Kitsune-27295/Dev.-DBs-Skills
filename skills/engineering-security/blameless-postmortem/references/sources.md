# Sources — Blameless Postmortem

Every URL below was checked during skill authoring (2026-11-24) and re-checked on 2026-11-27 (rebuild pass).

Pages were read with a fetch tool that returns an extracted view of each page; the PDF was converted to text locally. No text from any source is reproduced.

| Source | Retrieved status | What it contributed |
|---|---|---|
| [Google SRE book: Postmortem Culture](https://sre.google/sre-book/postmortem-culture/) | 200 OK (full page read) | Definition and blameless principle; objective triggers (downtime, any data loss, manual intervention, long resolution, monitoring failure); review and sharing; no end-user identifying information; cultural pitfalls. The page points to an example postmortem and a template without listing its sections. |
| [Google SRE workbook: Postmortem Culture](https://sre.google/workbook/postmortem-culture/) | 200 OK (full page read) | Structure of a good postmortem (header, summary, impact, root causes and trigger, timeline, went well, went poorly, got lucky, action items with type, priority, one owner and a bug); bad-versus-good example; reward closing action items; warning signs. |
| [Etsy: Debriefing Facilitation Guide (PDF)](https://extfiles.etsy.com/DebriefingFacilitationGuide.pdf) | 200 OK; the summarizing fetch could not read the PDF, so it was downloaded and converted to text locally; the first 18 pages of text (introduction, preparation, structure of the discussion, remediation items) were read, the rest of the question-asking section only by headings and a few passages | Descriptions over explanations; "how" over "why"; timeline first; objective versus subjective data; neutral facilitator; hindsight; remediation items are optional, soak time, the dashboard trap. |
| [Atlassian: Incident postmortems](https://www.atlassian.com/incident-management/handbook/postmortems) | 200 OK via a direct request (the summarizing fetch returned only navigation; the page text was extracted locally) | Four-part definition; owner, approvers and time targets for priority actions; six action categories; Actionable-Specific-Bounded wording; meeting agenda; blameless rationale and roles instead of names. |
| [PagerDuty: Postmortem Process](https://docs.pagerduty.com/ops-guides/incident-response-guide/postmortem-process) | 200 OK (page text extracted locally, first section read) | Owner designation, status values, timeline first, a source for each timeline item, commands and queries posted, review scheduling. |
| [PagerDuty: Effective Postmortems](https://docs.pagerduty.com/ops-guides/incident-response-guide/effective-postmortems) | 200 OK (page text extracted locally and read) | Dos and don'ts: accurate timeline, no changing details, no naming and shaming, avoid "human error", avoid alternate-reality statements, review criteria. |
| [PagerDuty incident response guide (response.pagerduty.com)](https://response.pagerduty.com) | 301 to docs.pagerduty.com/ops-guides/incident-response-guide, then 200 OK (index read) | Site map used to find the pages above. |
| Own vault-template skill for incident write-ups, read for ideas, no text reused | Local file read | Idea of: material first, timeline with a source id per line, known cause versus guesses, follow-ups needing an owner and a date, pending-validation markers, never reproduce secrets from logs. Its engine-specific commands were dropped. |

## Re-verification 2026-11-27

All six public sources returned 200 OK. Re-read through a fetch tool: SRE book (triggers, blameless definition, no end-user identifying data, review and sharing), SRE workbook (structure, action item fields, warning signs, reward for closing items), PagerDuty process page (owner, statuses draft / in review / reviewed / closed, timeline first, evidence per item, review within 3 days for SEV-1 or 5 business days for SEV-2) and effective-postmortems page (no "outage" overstatement, no altered details, avoid "human error" and hypotheticals, review criteria). The Etsy PDF came back as binary through the fetch tool; its text was extracted locally and the passages on "how" versus "why", remediation not being the goal, soak time, the dashboard trap and hindsight were confirmed. The Atlassian page was extracted locally (the fetch tool returned only navigation): 4 or 8 week SLO, approvers, six action categories and the "Actionable" criterion confirmed. Corrections: none that change a rule. This skill's status values (draft, in review, approved) are its own; PagerDuty's differ.

## Reading limits

- The Etsy PDF was read through a local text conversion; the section on asking questions was only partly read. Statements attributed to Etsy are limited to passages seen.
- The SRE book chapter does not list its template sections; the section list here follows the workbook and Atlassian.
- The PagerDuty process page was read up to its analysis steps; later sections (communication, closing) were not.
- "Known versus assumed", the `[PENDING VALIDATION]` marker and the redaction table are this skill's own conventions, not claims of the sources.

## Claims not adopted as fact

- Any cultural claim of effectiveness (for example that blameless reviews reduce incidents) is the sources' experience, not measured here.
- Atlassian's four or eight week targets and PagerDuty's review windows are examples of one organization's choices; the skill asks only for an owner and a date.
- The example incidents in the SRE workbook are used only as illustrations of structure.
