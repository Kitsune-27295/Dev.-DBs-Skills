# Sources — C4 Model Architecture

Every URL below was checked during skill rebuild (2026-11-27) with WebFetch.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://c4model.com/ | 200 OK, 2026-11-27 | Five pillars, abstraction list, core and supporting diagram names |
| https://c4model.com/introduction | 200 OK, 2026-11-27 | Ad hoc diagram problems, benefits and uses, level descriptions |
| https://c4model.info/ | 200 OK, 2026-11-27 | Person, system, container, component definitions; audiences per level |
| https://c4model.com/abstractions/container | 200 OK, 2026-11-27 | Container examples, non-examples, rulings on SPAs, managed services, shared runtimes |
| https://c4model.com/diagrams | 200 OK, 2026-11-27 | Use only levels that add value; context plus container suffice for most teams |
| https://c4model.com/diagrams/notation | 200 OK, 2026-11-27 | Title, element, relationship and key rules; one-way lines |
| https://github.com/milanm/architecture-docs | 200 OK, 2026-11-27 | Example Structurizr, arc42, AsciiDoc pipeline; Apache-2.0 |

## Reading limits

Pages were read through a summarizing fetch, not verbatim. The dynamic, deployment, landscape, microservices and queues pages were not read in detail (the diagrams page gives only examples). The DSL sketch and any scripts were not re-verified or run.

## Claims not adopted as fact

- That arc42 sections map to C4 levels: the repo README does not say so; the convention is owned by `arc42-api-contracts-architecture`.
- Dynamic diagrams use numbered steps, and deployment diagrams use deployment nodes: the pages read do not explain either.
- Mermaid C4 syntax and Structurizr or PlantUML specifics: not read here; `mermaid` owns Mermaid.
- Earlier draft claims that Level 4 includes database tables and that components are never separately deployable: not stated by the sources read; removed.
