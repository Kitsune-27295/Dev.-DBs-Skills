# Sources — Background Worker & Job Scheduler

Every URL below was checked during skill authoring (2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://learn.microsoft.com/en-us/azure/architecture/best-practices/background-jobs | 200 OK (WebFetch; Firecrawl had no credits). Page dated 2026-03 | Job types, event vs schedule triggers, returning results, idempotency, hosting options, partitioning, conflicts, coordination, reliability (checkpoints, graceful shutdown, poison messages, transient vs permanent failures), security, observability, scaling |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/competing-consumers | 200 OK (WebFetch). Page dated 2026-04 | Pattern definition, benefits, considerations (ordering, resiliency, poison messages, results, scaling/reliability of messaging), when to use, PeekLock/Functions example |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/leader-election | 200 OK (WebFetch). Page dated 2026-11 | Election mechanisms (mutex, ZooKeeper/etcd, Kubernetes Lease), issues and considerations (fencing, failover target, monitoring), blob lease example and its limitations |
