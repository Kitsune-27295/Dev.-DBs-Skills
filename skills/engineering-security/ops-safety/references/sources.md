# Sources — Ops Safety

Every URL below was checked during skill authoring (re-verified 2026-11-27).

Pages were read with a fetch tool that returns an extracted view of each page; where a page could not be read this is stated. No text from any source is reproduced.

| Source | Retrieved status | What it contributed |
|---|---|---|
| [GitLab: Postmortem of database outage of January 31 (2017)](https://about.gitlab.com/blog/postmortem-of-database-outage-of-january-31/) | 200 OK 2026-11-27 (summary read; published 2017-02-10) | Wrong-host data deletion during a replication rebuild (primary wiped instead of secondary); pg_dump, replication and snapshot options each unusable or unfit for disaster recovery; empty dump bucket from a client/server version mismatch plus a rejected failure notification; restore from a stale snapshot over slow storage; follow-ups on restore testing, owner for durability, host-visible prompts. Basis for the recoverability card and the "never tested" backup state. |
| [Google SRE book: Emergency Response](https://sre.google/sre-book/emergency-response/) | 200 OK 2026-11-27 (summary read) | Three cases (test-, change- and process-induced emergencies): untested rollback, light canary on a low-risk change, automation that treated an empty result as "all". Basis for rollback-before-action and sanity checks on automation. |
| [Google SRE book: Managing Incidents](https://sre.google/sre-book/managing-incidents/) | 200 OK 2026-11-27 (summary read) | "Stop the bleeding, restore service, and preserve the evidence" priority, used to justify measuring before changing state. |
| [AWS Well-Architected: plan for unsuccessful changes](https://docs.aws.amazon.com/wellarchitected/latest/framework/ops_mit_deploy_risks_plan_for_unsuccessful_changes.html) | 200 OK but body not readable on 2026-11-27 (script-rendered shell returned only a generic title) | Nothing quoted. Rollback-plan guidance is cited only as general practice and labeled not read from source. |
| [Google Cloud Well-Architected: manage incidents and problems](https://cloud.google.com/architecture/framework/operational-excellence/manage-incidents-and-problems) | 301 to docs.cloud.google.com, then 200 OK 2026-11-27 (summary read) | Runbook or playbook for response, central incident tracking, blameless reviews. The page does not cover change management. Used only as supporting context. |
| Third-party skill read for ideas, no text reused (license: MIT, per owner's note) | Not re-read in this pass | Idea of a confirmation card with a recoverability checklist and a strict "yes", the honest "routing convention, not enforcement" statement, and a measure-first contract with the "needs more time versus wedged" distinction. Everything was rewritten from the public sources above. |

## Reading limits

- The summarizing fetch tool can paraphrase; claims were limited to what the page text supported, and the two AWS pages were treated as unread.
- Scripts, commands and card templates in the skill were not re-run.
- The GitLab post gives two end times for the lost-data window in different sections; this skill relies only on the general shape, not on exact counts.

## Claims not adopted as fact

- "Five backup or replication mechanisms, none usable" (earlier wording): the 2026-11-27 read listed four mechanisms (pg_dump, replication, Azure disk snapshots, LVM snapshots) and could not confirm the count of five, so the skill says "the mechanisms in place" without a number.
- "Backups nobody had ever restored" as a description of the GitLab case: the read shows backups that failed or were unfit, not an untested-restore finding; the follow-up was automated restore testing, which the skill cites only for that.
- Any statement of exact volumes lost, user counts or download speeds from the GitLab post: left out of the skill text.
- AWS rollback guidance: not read; used only as labeled general practice.
- The skill does not claim that a convention prevents destructive actions; it says the opposite.
