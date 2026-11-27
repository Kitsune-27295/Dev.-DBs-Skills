# Sources — Background Worker & Job Scheduler

Every URL below was re-checked during the 2026-11-27 rebuild (earlier pass: 2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://learn.microsoft.com/en-us/azure/architecture/best-practices/background-jobs | 200 OK (WebFetch, 2026-11-27); page dated 2026-03-30 | Triggers, returning results, idempotency, hosting options, WebJobs `is_singleton`, partitioning, coordination, reliability, security, observability, scaling, single-instance guards |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/competing-consumers | 200 OK (WebFetch, 2026-11-27); page dated 2026-04-02 | Pattern, benefits, considerations (ordering, poison messages, results, scaling), when to use, PeekLock example |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/leader-election | 200 OK (WebFetch, 2026-11-27); page dated 2026-11-12 | Mechanisms, fencing, failover target, monitoring, per-partition leaders, blob lease wait up to one minute |

## Reading limits

Azure-specific hosting names (Functions, Container Apps, WebJobs) are the source's; the skill generalizes them. The linked GitHub sample was not read. Code sketches are our own and were not run.

## Claims not adopted as fact

- Jittering periodic jobs across a fleet: our inference, not on the pages (labeled as such in the skill).
- Sizing prefetch/batch counts to lock duration: our inference.
- "Decision ladder" order for single-instance work (idempotent, platform guard, lock, leader election): our synthesis of the pages' advice, not a sourced ranking.
