# Sources — Backup restore drill

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Banco de Dados | Fundamentos para Vibe Coders #EP2", channel mano deyvin, published 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI — chapter 08 "Backup que volta" (28:48-30:37) | Transcript read from a saved copy; video page not re-fetched | The GitLab story as told, "never restored means unknown", `pg_dump` and `pg_restore` into a test database, daily and off-server, same-server backup dies with the server |
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe — section "7. Backup que volta" | Saved copy read; page not re-fetched | The prompt (inventory, daily script with 7 daily and 4 weekly copies, restore test with row counts, short runbook) |
| GitLab postmortem, https://about.gitlab.com/blog/postmortem-of-database-outage-of-january-31/ | 200 (read through a summarizing fetch tool) | Timeline, why each backup method failed, losses, remediation list |
| GitLab incident report, https://about.gitlab.com/2017/02/01/gitlab-dot-com-database-incident/ | 200 (read through a summarizing fetch tool) | Live-notes style account: db1/db2 mix-up, 300 GB to 4.5 GB, six-hour-old restore point |

## Claims and caveats

- Verified: about 300 GB deleted on the primary by mistake, about 18 hours of downtime, roughly six hours of database changes lost, five backup and replication mechanisms none working reliably; the S3 bucket was empty; `pg_dump` ran as 9.2 against a 9.6 server; failure emails were rejected (DMARC); Azure snapshots covered NFS but not database servers; LVM snapshot existed only because of a manual copy about six hours earlier.
- The two pages differ slightly on the loss window (postmortem: loss window starting 17:20 UTC, with 23:30 given as the end in one place and 00:00 in another; incident report: 5:20 pm to 11:25 pm) and on the cause of the load. I did not reconcile them.
- Verified counts of loss from the postmortem: at least 5,000 projects, 5,000 comments and roughly 700 user accounts; repositories and wikis were stored separately and not lost.
- The video's "lost 300 GB" refers to the data directory removed on the primary; the data actually unrecoverable was about six hours.

## Discrepancies with SKILL.md (not edited)

- `SKILL.md` quotes that finding and using the backups "failed completely" per the postmortem. The summary of the page read here confirms the substance (none worked reliably) but did not surface that exact phrase (resolved 2026-11-24: re-fetched the postmortem; it says "the process of both finding and using backups failed completely", so the `SKILL.md` quote stands; it also lists the empty S3 bucket, the pg_dump version mismatch with silent failure, and broken replication).
- `SKILL.md` says "only a six-hour-old snapshot not meant for disaster recovery saved the data"; consistent with the pages (a manually taken LVM snapshot used for staging).
- The 7 daily and 4 weekly retention rule is the handout's own recommendation, not from GitLab.
