# Sources — Backup restore drill

Every URL below was re-checked on 2026-11-27 (fetched through a summarizing fetch tool; the page text was not read in full).

| Source | Retrieved status | What it contributed |
|---|---|---|
| GitLab postmortem, https://about.gitlab.com/blog/postmortem-of-database-outage-of-january-31/ | 200 | Timeline, four recovery procedures and why each failed, losses, remediation list, "failed completely" quote |
| GitLab incident report, https://about.gitlab.com/2017/02/01/gitlab-dot-com-database-incident/ | 200 (some images broken) | 17:20 to 23:25 UTC window, removal stopped 23:27, 300 GB to about 4.5 GB, six-hour restore point |
| PostgreSQL pg_dump, https://www.postgresql.org/docs/current/app-pgdump.html (added 2026-11-27) | 200 | Formats, version compatibility, consistency, "generally not the right choice" note |
| PostgreSQL pg_restore, https://www.postgresql.org/docs/current/app-pgrestore.html (added 2026-11-27) | 200 | Archive formats, `-d`, `--create`, `--clean` |
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe | 200, section "Backup that comes back" re-read | The prompt: inventory, daily script, 7 daily and 4 weekly copies, restore test, runbook |
| Video "Banco de Dados / Fundamentos para Vibe Coders #EP2", mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI | Page content truncated; only the title was confirmed | Lesson framing (chapter 08); transcript from an earlier saved copy |

## Corrections made on 2026-11-27

1. "Five backup mechanisms" is not what the postmortem lists: it numbers four recovery procedures (pg_dump, LVM snapshots, Azure snapshots, replication) and notes WAL archiving was not used. Reworded; the "five" count is not adopted.
2. The 300 GB to 4.5 GB figure appears only in the incident report, not the postmortem. Attributed accordingly.
3. Loss window re-read: postmortem gives 17:20 to 23:30 UTC in one place and 00:00 in another, unreconciled; the incident report gives 17:20 to 23:25. Stated as about six hours.
4. Added: the two snapshots were about 24 and 6 hours old, the cross-account restore detail, the remediation items (backup monitoring, point-in-time recovery, hourly snapshots, recovery testing, owner) and the losses (5,000 projects, 5,000 comments, about 700 accounts).
5. `pg_dump` docs: it refuses a server newer than itself; the old "check the version" advice is now precise. Added the `--create`/`--clean` hazard and the docs' caution that dumps are not generally right for regular production backups.

## Reading limits

Pages were read through a summarizing tool. The video page returned only a title. Chapter timings were not re-verified. The 7 daily and 4 weekly retention is the handout's own recommendation, not from GitLab or PostgreSQL. The version-check shell sketch and the test anatomy are the pack's own and were not run.

## Claims not adopted as fact

- "Five backup mechanisms, none working" (postmortem lists four).
- "Lost 300 GB" (the unrecoverable data was about six hours of changes).
- Any claim of which cause applies to the owner's own system.
