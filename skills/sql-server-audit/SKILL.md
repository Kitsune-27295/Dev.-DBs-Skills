---
name: sql-server-audit
description: "Method for auditing a SQL Server instance or database so the verdict is something a professional would sign - scope and business inputs first, read-only evidence before opinion, one finding per issue with severity and confidence, popular myths rejected, coverage gaps reported instead of read as healthy, and a prioritized report whose fixes are proposed scripts that are never run. Covers configuration, backups and restores, integrity checks, indexes and statistics, waits and blocking, security, and HA/DR. Use when asked to audit, health-check or review a SQL Server, to judge pasted sp_Blitz or DMV output, or to turn collector results into a ranked remediation plan."
---

# SQL Server audit (method)

One idea: an audit is a chain of claims, and each claim needs a row of evidence, a severity, a confidence and a safe next step; a number from memory, a check that was not run, or a fix that was executed on the owner's behalf breaks the chain. Public sources and claims not adopted: [references/sources.md](references/sources.md).

## 1. Boundaries (one owner per rule)

| Question | Owner |
|---|---|
| Which read-only query answers it (30 scripts per version, how to read counters, version porting) | `sql-server-diagnostics` |
| Seven fundamentals of an application's database and the run order | `database-audit` |
| Do backups really restore (drill, runbook) | `backup-restore-drill` |
| Who can read or write what, open ports, leaked keys | `database-exposure` |
| Slow query, plan, index design (generic) | `query-performance` |
| Constraints, types, orphan rows | `schema-and-constraints` |
| Generic safety around any fix (branch, backup, one change at a time) | `fundamentals-audit` |

This skill owns the method between them: scoping, judging, rating, reporting. It does not duplicate a collector.

## 2. Method

1. **Scope and business inputs.** Ask for: instance and databases in scope, production or not, platform (box, Linux, VM, managed service), RPO and RTO per database or tier, maintenance windows, known pain, compliance scope. These are the owner's facts; when missing, write the assumption you used. Details: [instance, backups and integrity](references/audit-areas-instance-and-recovery.md) section 0.
2. **Context before judgment.** Version, edition, platform, uptime (`sqlStartTime`), AG role, workload type. Run `identity/server_identity.sql` of `sql-server-diagnostics` first; counters since restart mean nothing without it.
3. **Collect read-only evidence.** Pick the collectors per area from the two audit-area references ([instance, backups, integrity](references/audit-areas-instance-and-recovery.md); [indexes, waits, security, HA/DR](references/audit-areas-performance-security-ha.md)); one at a time; light scripts first, medium and heavy ones only with the owner's OK. If the First Responder Kit or Ola Hallengren's solution is already installed (`jobs/dba_tools.sql` says), reading their output is allowed; installing anything on the audited server is a change, not an audit step.
4. **Judge each area** with the rules in that reference and reject the myths in [common myths](references/common-myths-debunked.md).
5. **Write findings** (one issue each) in the format of [deliverable template](references/audit-deliverable-template.md): evidence, impact, severity, confidence, proposed change, risk, rollback, verification.
6. **Report positives and gaps.** Say what is healthy (so nobody touches it) and what was not checked and why. Nothing returned is "nothing found", never "healthy".
7. **Prioritize** by risk removed per effort, in three buckets: now, next change window, backlog. Every change stays a proposal.
8. **Self-check** with the Quick Decision Checklist below before delivering.

## 3. Severity (business impact, not interest)

| Level | Meaning | Examples |
|---|---|---|
| CRITICAL | Data loss or unrecoverability now, active corruption, open door to full compromise | No restorable backup inside the RPO, suspect pages, CHECKDB errors, encryption certificate never backed up |
| HIGH | Likely outage, exposure or major slowdown in normal operation | Full recovery model with no log backups, public login with sysadmin, log disk nearly full |
| MEDIUM | Real risk or waste; fix in the next change window | No tested restore, CHECKDB older than the target, unbounded `max server memory` |
| LOW | Hygiene, small impact | Naming, unused index on a small table, inconsistent file growth |
| INFO | Context, positives, items for human confirmation | Version and lifecycle dates, a healthy area |

Lower a level when a compensating control exists and name it; raise it when findings combine into a worse path (for example an over-privileged login that also owns a database set to trust).

## 4. Confidence (how solid the evidence is)

- `verified`: the result set proves it, you can quote the row, and the counter window is known.
- `likely`: the result fits but a plausible alternative exists; say which.
- `heuristic`: a rule of thumb applied; no workload evidence yet.
- `needs-confirmation`: depends on a business fact or a check that you could not run.

Severity and confidence are separate: a `needs-confirmation` CRITICAL is still reported first, with the one question or check that settles it.

## 5. Evidence rules

- Every finding cites the collector name and the row or value; counters carry the window (since which restart, or the two snapshot times).
- Numbers come from results, from the owner, or are labeled assumptions. Never from memory.
- Check the applicability of each recommendation to the version, edition and platform before writing it (online rebuild is an edition feature; managed services hide instance settings).
- Query text and names in results can hold personal data: summarize or mask them in the report. Full rules: [evidence and safety](references/evidence-and-safety-rules.md).

## 6. Read-only guardrails

- Run only `SELECT`-style collectors. Never run `sp_configure` with a value, `ALTER`, `DBCC` repair, `KILL`, index maintenance, `UPDATE STATISTICS`, cache clearing, counter resets, or create objects for tool output on a server the owner did not name disposable.
- Heavy diagnostics (detailed physical index stats, wide index analysis, large event files, `CHECKDB`) need consent and a quiet window.
- Secrets never go on a command line, in a report or in chat.
- Remediation is a script marked `-- PROPOSED CHANGE (review before running)` with prerequisites, risk, rollback and a verification query. A human decides and runs it.

## 7. Reject on sight

- A verdict with no evidence row, or a metric with no window.
- "No rows returned, so it is fine."
- A fix executed "because it is safe" on production.
- A fixed threshold used as a verdict (a percentage, a counter value, a ratio) without the workload evidence behind it.
- Restoring confidence from a backup job that reports success but was never restored.
- Repair options of the consistency checker proposed before a restore was considered.

## Quick Decision Checklist

- [ ] Scope, platform, version, uptime and business inputs (or stated assumptions) are in the report.
- [ ] Each finding: evidence, window, severity, confidence, proposed change, risk, rollback, verification.
- [ ] Critical and high findings have a mechanism explained in a sentence, not only a number.
- [ ] No myth from the myths file was used as a reason.
- [ ] Coverage gaps and unrun checks are listed; empty results are not called healthy.
- [ ] Positives are listed.
- [ ] Every script is marked PROPOSED CHANGE, valid for the target version, and was not executed.
- [ ] Plan ordered by risk removed per effort; one change per step.
- [ ] Sensitive values masked.

## Deep references

- [Audit areas: instance, backups, integrity](references/audit-areas-instance-and-recovery.md) — read when choosing collectors and judging scope, configuration, backups, restores and CHECKDB.
- [Audit areas: indexes, waits, security, HA/DR](references/audit-areas-performance-security-ha.md) — read when judging indexes and statistics, waits and blocking, security and availability groups.
- [Common myths debunked](references/common-myths-debunked.md) — read before accepting any rule of thumb as a finding.
- [Audit deliverable template](references/audit-deliverable-template.md) — read when writing findings, the summary and the plan.
- [Evidence and safety rules](references/evidence-and-safety-rules.md) — read before connecting, handling output, or reviewing pasted tool output.
- [Sources](references/sources.md) — read for URL status and claims not adopted.
