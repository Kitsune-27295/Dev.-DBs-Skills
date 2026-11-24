# Evidence and Safety Rules

Sources: https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit · https://ola.hallengren.com/sql-server-backup.html · https://ola.hallengren.com/sql-server-integrity-check.html · https://ola.hallengren.com/sql-server-index-and-statistics-maintenance.html · https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/back-up-and-restore-of-sql-server-databases · https://learn.microsoft.com/en-us/sql/relational-databases/security/sql-server-security-best-practices · https://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/ · Last verified 2026-11-24

This page holds the rules that make an audit trustworthy and safe: how evidence is recorded and rated, what may be run, how pasted output from community tools is read, and what to hand over instead of executing.

## 1. The evidence ledger

Keep one line per piece of evidence while auditing, and cite its id in findings.

| Field | Content |
|---|---|
| id | E1, E2, ... |
| source | collector file name of `sql-server-diagnostics`, tool name and version, or an owner statement |
| window | restart time (`sqlStartTime`), or the two snapshot times, or "point in time" for configuration |
| scope | instance, database, replica |
| result | the row or value, with names masked if needed |
| confidence | verified, likely, heuristic, needs-confirmation |

Rules:

- A claim without a ledger line is an opinion; delete it or label it `heuristic`.
- Counters since restart are `verified` only for the statement "this accumulated over this period". A statement about "now" needs a delta window or another source.
- Business facts (RPO, RTO, windows, compliance scope, sensitivity) are ledger entries with source "owner statement". If you assumed one, the line says "assumed" and the finding depends on it.
- A collector that returned nothing gets a line too: "ran, nothing found, permission context X". An error gets a line: "failed, reason, coverage gap".

## 2. Confidence rules

- `verified`: result proves the claim and the window is known.
- `likely`: result fits, a named alternative remains; add the check that separates them.
- `heuristic`: a rule of thumb, tool default or inference; say so ("this is the tool's default, not a standard").
- `needs-confirmation`: depends on an owner fact or a check not run.

A finding with only `heuristic` or `needs-confirmation` evidence may be rated by the worst plausible impact, but the report states the single action that would upgrade or retire it. Never convert a gap into health: "not checked" and "healthy" are different words in the report.

## 3. What is allowed to run

Allowed by default (read-only): catalog views, DMVs, `msdb` history reads, error-log reads, the `SELECT`-only scripts of `sql-server-diagnostics`, and reading output of community tools the owner already runs.

Needs the owner's consent first: heavy scripts (detailed physical index scan, deadlock history from large event files, wide index analysis across many databases, a consistency check), anything that samples for a period, and any tool that must be installed.

Not allowed on a server the owner did not name disposable, even if it looks harmless:

- configuration changes (`sp_configure` with a value, `RECONFIGURE`, trace flags);
- index and statistics maintenance, shrink, `DBCC` repair options, cache or counter clearing (clearing counters destroys the evidence of the period);
- killing sessions (the First Responder Kit session killer only kills when its execute switch is set; do not set it);
- creating event sessions, tables, jobs or procedures to hold tool output (installing community procedures is a change to the audited server);
- running a tool's self-update that downloads and executes code from the internet (the kit's update procedure does that; the project advises pinning a release tag instead of the main branch).

Maintenance solutions generate commands; the integrity-check procedure documents a switch that prints the commands without running them (`Execute = 'N'`, default `Y`), and the same pattern is expected in its sibling procedures (not read for each one). That is the safe way to show the owner what would run.

## 4. Least-privilege audit login

- Ask the owner for a login with read access to server and database metadata and performance views, not sysadmin. The First Responder Kit documents a one-time grant script (view server state, connect any database, view any definition, plus execute on its procedures) and notes that some checks still need sysadmin and that saving results needs more permissions.
- Permissions per collector differ by version: see `sql-server-diagnostics` `references/sql2019-porting.md` and `references/sql2025-porting.md`. Missing permission is a coverage gap, not a finding about the database.
- If only sysadmin is available, say so in the report (INFO or LOW), proceed read-only, and never use it to change anything.
- Credentials: environment or the client's secure prompt; never on a command line, in a report, in a ticket or in chat. Never print connection strings.

## 5. Sensitive output

- Results hold host names, accounts, database names and statement text with literals that may be personal data.
- Keep raw output in the owner's controlled folder. In the report, mask or summarize: "statement on table X filtered by a customer identifier" rather than the literal.
- Do not paste output to external services without the owner's approval.
- Do not read business data. Evidence is metadata and counters.

## 6. Reading pasted output (community tools)

When the owner pastes output instead of giving access, first identify, then judge.

1. **Identify** the tool and its version, the sample window and the server uptime (the output often states it; if not, ask). Output without a window is `heuristic` at best.
2. **Know what the tool is.** The First Responder Kit's main health procedure returns a prioritized list (priority 1 most urgent) with a details column; its real-time procedure samples counters, waits a few seconds (default 5) and reports what changed, so it describes that interval only; with its since-startup mode it describes the whole uptime. Its cache procedure ranks cached statements by a chosen sort order; its index procedure has modes (0 high-priority advice, 4 detailed, 1 summary, 2 usage, 3 missing) and mode changes what is shown.
3. **Tool priorities are not your severity.** Re-rate with this skill's scale and context; downgrade or drop items that do not apply (version, platform, compensating control), and say why.
4. **Tool defaults are not standards.** A maintenance solution's defaults (for example its fragmentation thresholds or its choice not to verify backups unless asked) are choices; say "default of the tool".
5. **Platform limits.** The kit states support for Windows and Linux instances and managed RDS; for Azure SQL Database it says some procedures work but support is not a goal. Note any item that depends on unavailable features as a coverage gap.
6. **Check completeness.** A procedure that skips user databases above a database-count limit unless a "bring the pain" switch is given leaves a gap; record it.

## 7. Heavy and risky diagnostics: protocol

1. State why the heavy script is needed and what it costs (it reads many pages, takes time, may add I/O).
2. Get the owner's OK and a quiet window.
3. Run once, one database at a time, keep the output, do not repeat for a nicer number.
4. Record start and end time in the ledger.

## 8. Proposed changes: shape

Every remediation is a text block in the report:

```
-- PROPOSED CHANGE (review before running). Not executed by the audit.
-- Target: <instance / database>, version <n>, edition <x>
-- Why: finding F7 (evidence E12)
-- Prerequisites: <backup taken, window, approvals>
-- Risk: <what can go wrong, who is affected>
-- Rollback: <exact way back>
-- Verify: <query that proves the change and the expected value>
<statement>
```

Rules: valid for the target version; no secrets; one change per block; if a change is not reversible (drop, repair), say so in the first line and point to the backup that protects it.

## How an agent should apply this

- Open a ledger at the start and cite ids in every finding.
- Decline or hand over any step that writes; produce the proposed block instead.
- Before judging pasted output, ask for tool version, window and uptime; mark missing ones as gaps.
- Re-rate tool priorities with the skill scale; never forward a tool's priority as your severity.
- Keep raw output out of the report; mask names and literals.
