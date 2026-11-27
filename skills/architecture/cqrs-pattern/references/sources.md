# Sources — CQRS Pattern

Every URL below was re-fetched with WebFetch on 2026-11-27 (rebuild pass; the first authoring pass was 2026-11-22).

| Source | Retrieved status | What it contributed |
|---|---|---|
| Martin Fowler, "Command Query Separation", https://martinfowler.com/bliki/CommandQuerySeparation.html | 200, dated 2005-12-05 | Meyer's query/command split, preference for the word "modifier", `pop` and iterator `next` as exceptions, C++ `const` as the only marking he knows |
| Martin Fowler, "CQRS", https://martinfowler.com/bliki/CQRS.html | 200, dated 2011-07-14 | Greg Young origin, "very cautious" warning, Bounded Context scope, ReportingDatabase alternative, the shapes of separation, companions; no statistics |
| Microsoft Azure Architecture Center, "CQRS pattern", https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs | 200, page date 2025-02-20 | Problems of one CRUD model, task-based commands, single store versus separate stores, outbox and idempotent consumer pointer, benefits, problems, use/avoid lists, Event Sourcing combination, C# example |

## Reading limits
- The PT-PT Azure page is the same article and was not re-read.
- Fowler's pages are short and were read in full; the Azure page was read in full.
- No scripts or data files in this skill.

## Claims not adopted as fact
- "Most CQRS projects had serious difficulties" as a numeric or proven rate: Fowler gives only a qualitative impression.
- "Zero projection lag" for single-store CQRS: no source states it; kept only as an inference (same committed data).
- Returning only an acknowledgment or ID from a command: common practice, not stated by any source here.
- A fixed read-to-write ratio (such as 100:1) as a threshold: no source gives one.
- The four-rung ladder and "start with one store" are this skill's synthesis, not source rules.
