# Sources — Layered & N-Tier Architecture

Every URL below was checked during skill authoring (2026-11-27, re-fetched with a web fetch tool; earlier text was a draft).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/n-tier | 200 OK, read in full; page dated 2025-08-15, metadata updated 2026-10-11 | Layers vs tiers, closed/open and strict/relaxed models, when to use, benefits, challenges, best practices, VM reference deployment |
| https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/ | 200 OK, read in full; dated 2025-09-25 | N-tier fit (low update frequency, limits agility), styles as constraints, big ball of mud warning |
| https://engsoftmoderna.info/cap7.html | 200 OK, read (summary-level, Portuguese) | Layered and three-tier architecture, MVC dates, big ball of mud case (2.5M to 25M lines, onboarding 3 to 7 months), THE system, example business rules |
| https://learn.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures | 200 OK, read in full (English edition; the earlier draft cited the Portuguese edition) | N-layer UI/BLL/DAL, dependency direction defect, clean architecture contrast, layers vs tiers note |

## Reading limits

- Pages were read through a summarizing fetch tool, so exact wording of long passages was not compared. Numbers and named examples were checked explicitly.
- The Valente chapter is in Portuguese; its wording is paraphrased.
- Scripts or tools mentioned (`dependency-cruiser`, `ArchUnit`) were not run.

## Claims not adopted as fact

- "Sinkhole anti-pattern" with an 80/20 split of pass-through requests: the Azure guide never uses the term or a percentage; it says only that a CRUD-only middle tier adds latency and complexity. The term stays as a pack label, the percentage was dropped.
- Strict layers as the default: this is the pack's recommendation; the guide treats strict and relaxed as valid with different costs.
- The first draft's "architecture erosion" wording is not Valente's; he describes the Big Ball of Mud.
- Fixes for poor layering by moving to microservices relocating the mess (inference, not sourced).
