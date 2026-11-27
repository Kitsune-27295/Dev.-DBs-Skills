# Common Myths Debunked

Sources: https://www.sqlskills.com/blogs/paul/a-sql-server-dba-myth-a-day-3030-backup-myths/ · https://www.sqlskills.com/blogs/paul/a-sql-server-dba-myth-a-day-2730-use-backup-with-checksum-to-replace-dbcc-checkdb/ · https://www.sqlskills.com/blogs/paul/why-you-should-not-shrink-your-data-files/ · https://www.sqlskills.com/blogs/paul/tempdb-configuration-survey-results-and-advice/ · https://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/ · https://learn.microsoft.com/en-us/sql/relational-databases/indexes/reorganize-and-rebuild-indexes · https://learn.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-checkdb-transact-sql · https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/server-memory-server-configuration-options · https://ola.hallengren.com/sql-server-index-and-statistics-maintenance.html · Last verified 2026-11-27

A myth in an audit is a rule of thumb used as a verdict. Each entry below states the belief, what the sources say, and what to report instead. Only entries traced to a page read during authoring are here; widely repeated claims that were not verified are listed at the end as "not adopted".

## Backups and recovery

| Myth | What the sources say | Report instead |
|---|---|---|
| "The backup job succeeds, so we can restore." | A good backup does not guarantee a good restore; restores must be validated regularly (the myth series). The vendor backup page says there is no restore strategy until each backup type in use has been restored and the result checked. | Finding on missing restore evidence; ask for date and proof; hand to `backup-restore-drill`. |
| "Backup with checksum replaces CHECKDB." | Checksum verification covers only pages that carry a checksum and are read; pages that survived an upgrade from very old versions may lack one; a differential reads only changed extents; memory corruption before the write gets a valid checksum, so only a consistency check finds it. | Report checksum as a plus, and the consistency-check schedule as a separate check. |
| "A full or differential backup clears the log." | Only log backups free the inactive log (and only the part not held by anything else). | If the log grows under full recovery, look for missing log backups first, then long transactions or replication and availability holds. |
| "Switching between full and bulk-logged breaks the log chain." | Per the series, only switching to the simple model breaks it. | Check the chain from backup history before declaring a break. |
| "Differential backups are incremental." | They are cumulative since the last full. | Restore plan uses the last differential, not every one. |
| "Delete the old backup when the new one finishes." | Keep a rolling window; a bad newest backup needs an older one. | Retention finding with the window stated. |
| "A secondary replica is a backup." | The vendor AG page says secondary databases are not backups and failover is not triggered by database-level corruption. | Backup finding stands even with an AG. |
| "Shrink before backup makes it smaller." | Shrink moves pages and can bloat differentials. | Remove it from the job; see the shrink entry. |
| "Plan the backups first." | The series says plan the restore strategy first (what to restore, how fast, to which point). | Ask for RPO and RTO before reading backup history. |
| "Only user databases need backups." | System databases need backups too. | LOW to MEDIUM finding if missing. |

## Integrity and repair

| Myth | What the sources say | Report instead |
|---|---|---|
| "If CHECKDB reports errors, run the repair option." | The vendor page: restore from the last known good backup is the primary recovery; the data-loss repair level is an emergency last resort and can lose more than a restore; foreign keys are not maintained by repair; take copies of all files first. | Finding recommends restore planning and preserving files; any repair is a separate, explicitly approved emergency action. Never propose it as a routine fix. |
| "A physical-only check is as good as a full check." | It checks page structure and allocation, skips logical and column-value checks; recommended for frequent use with a full run periodically. | Report the mix of runs, not only the last run. |
| "A clean index rebuild repairs corruption." | An online rebuild reuses the existing index and carries inconsistency over; an offline rebuild or drop-and-recreate can replace a nonclustered index from the table. | Only a nonclustered index problem; confirm with the consistency check first. |

## Indexes, statistics, files

| Myth | What the sources say | Report instead |
|---|---|---|
| "Reorganize between 5% and 30%, rebuild above 30%, always." | The maintenance solution documents 5% and 30% as its defaults and attributes them to the vendor's guidance; the vendor page itself says decisions must not rest on fixed fragmentation or density thresholds alone, notes density matters, and that small indexes rarely improve. | Treat as a default, ask whether any query degrades with fragmentation, measure before and after (Query Store). |
| "Rebuilding indexes made the system faster because it removed fragmentation." | A rebuild also updates statistics with a full scan (not for partitioned or resumable builds; a reorganize does not); the vendor page says the gain is often from the statistics and that updating statistics is far cheaper. | Test statistics update first; explain the mechanism in the finding. |
| "Shrink data files regularly to reclaim space." | Shrink reverses index order (example: about 0.4% to 99.3% fragmentation), costs I/O, CPU and log, and files regrow; auto-shrink should never be enabled. Exceptions: after a huge deletion with no regrowth, emptying a file for removal, a one-off log fix. | Finding when auto-shrink is on or a shrink job exists; alternative is moving objects to a new filegroup. |
| "Unused-index DMV says drop it." | Counters reset at restart and other events; a short window proves nothing. | See `sql-server-diagnostics` `references/index-dmvs-and-reset-semantics.md`; propose a drop only after a full business cycle. |
| "Missing-index DMV is the index plan." | Suggestions are capped, unmerged and not persisted. | Leads for the top queries only. |
| "Always a fill factor below 100 for performance." | The vendor page does not recommend values other than 100 or 0 except for indexes with many page splits, because lower density means more I/O and memory. | Check page splits before proposing a fill factor. |

## Configuration and performance

| Myth | What the sources say | Report instead |
|---|---|---|
| "Max server memory caps everything SQL Server uses." | It limits the buffer pool only; other components allocate outside it. | Leave headroom; start from the vendor formula and monitor. |
| "MAXDOP 0 is the best default." | The vendor page says it is not the recommended value for most cases and gives a table by NUMA layout. | Compare with the table; change only with plan or wait evidence. |
| "One tempdb data file per core." | A survey post found over half of the systems used a single file regardless of core count; it advises first checking I/O latency and avoidable tempdb use, keeping files equal in size, and links a myth entry on the per-core rule. The exact ratio is not stated by the fetched page. | Judge by allocation contention waits and sizes, not by a ratio. |
| "High wait X means problem X." | A wait names a resource, not a root cause; waits always occur; no universal percentage defines a problem; some waits are client-side. | Follow with the second check named in the areas file. |
| "Counters since restart describe now." | They accumulate; a spike disappears in the average. | Use a window (two snapshots) before concluding. |
| "No rows returned, so there is no problem." | The script may lack permission or the feature may be off. | Report "nothing found" and the permission context, or a coverage gap. |

## Security

| Myth | What the sources say | Report instead |
|---|---|---|
| "DBAs must be sysadmin." | The vendor page suggests considering a narrower administrative grant, since sysadmin ignores denies, and separating duties. | MEDIUM finding with a least-privilege proposal. |
| "Dynamic data masking secures the column." | The vendor page prefers client-side column encryption when possible and states the two are not compatible; masking is for when encryption is unavailable. | Describe masking as a convenience layer, not an access control. |

## Not adopted (not verified in this pass)

These are often repeated; no fetched source confirmed or refuted them, so do not state them as fact in a report: a page life expectancy target such as 300; NOLOCK as a performance feature or as always unsafe in every case; local variables as a general fix for parameter sniffing; the claim that parallelism waits at the top always mean a bad cost threshold; fixed implicit-conversion rules. If a case needs one of them, prove it with a plan or a measurement and mark the finding `heuristic` until then.

## How an agent should apply this

- Before writing a finding, ask whether its reason is on this list; if yes, rewrite the reason with the evidence the sources require.
- When the owner repeats a myth, answer with the mechanism in one sentence and the check that settles it, not with authority.
- Where a default comes from a tool (a maintenance solution), say it is that tool's default, not a standard.
- Keep the "not adopted" items out of reports unless measured.
