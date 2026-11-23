---
name: arc42-api-contracts-architecture
description: Use when documenting software architecture with the 12-section arc42 template or designing, validating, and integrating machine-readable API contracts — OpenAPI (3.1/3.2 for synchronous HTTP/REST) and AsyncAPI (3.x for event-driven/WebSocket/Kafka channels and operations). Gives the arc42 12-section map, contract-first rules, CI drift gates, and what prose must supplement generated specs.
---

# arc42 Architecture Documentation & API Contracts (OpenAPI / AsyncAPI)

One idea: keep system architecture comprehensible with the **12-section arc42 template** (paired with C4 diagrams and ADRs), while delegating every external and inter-service interface detail in Sections 3, 5, and 6 to **machine-validated, executable API contracts — OpenAPI (3.1/3.2) for synchronous HTTP/REST and AsyncAPI (3.x) for asynchronous events, queues, and WebSockets** — enforced in CI so documentation and SDKs can never drift from the running code. Sources and their claims: [references/sources.md](references/sources.md).

## The 12-Section arc42 Map (Dr. Gernot Starke & Dr. Peter Hruschka)

Keep sections concise ("just enough" documentation); link to C4 diagrams (`c4-model-architecture`), ADRs (`adr-architecture`), and OpenAPI/AsyncAPI specs instead of duplicating code:

| # | arc42 Section | What belongs here | Linked Artifacts |
|---|---|---|---|
| **1** | **Introduction & Goals** | Business purpose, top 3-5 quality goals (ISO 25010), key stakeholders | Product vision, SLA targets |
| **2** | **Architecture Constraints** | Non-negotiable technical, organizational, regulatory, and budget limits | Compliance / regulatory rules |
| **3** | **Context & Scope** | Business & technical context: external actors, external systems, and public protocols | **C4 Level 1 (System Context)** + external **OpenAPI / AsyncAPI** links |
| **4** | **Solution Strategy** | Summary of fundamental architectural decisions and quality achievement strategies | High-level tech stack & style summary |
| **5** | **Building Block View** | Static decomposition of the system from black-box to white-box modules | **C4 Level 2 (Container)** & **Level 3 (Component)** + internal **OpenAPI / AsyncAPI** contracts |
| **6** | **Runtime View** | Behavior of building blocks across critical use cases, error paths, and startup | **C4 Dynamic / Sequence Diagrams** |
| **7** | **Deployment View** | Technical infrastructure, environments, nodes, networks, and container mapping | **C4 Deployment Diagram** + IaC links |
| **8** | **Crosscutting Concepts** | Recurring domain/technical patterns: auth, logging/OTel, error handling, transactions, migrations | Shared pattern guides |
| **9** | **Architecture Decisions** | Log of Architecturally Significant Decisions | **`docs/adr/`** (`adr-architecture`) |
| **10** | **Quality Requirements** | Quality tree and concrete, measurable quality scenarios (stimulus $\to$ response $\to$ metric) | Load / chaos / security test links |
| **11** | **Risks & Technical Debt** | Known architectural risks, bottlenecks, and prioritized technical debt items | Risk register / issue tracker |
| **12** | **Glossary** | Domain Ubiquitous Language and technical terms/acronyms | Domain glossary table |

*Tip:* For small systems, use the **arc42 Canvas** (a single-page Markdown overview covering the essential sections) before expanding into 12 separate chapter files.

## OpenAPI (REST/HTTP) & AsyncAPI (Event-Driven/WebSockets) Contract Rules

1. **Pair OpenAPI with AsyncAPI by communication style:**
   - **OpenAPI Specification (OAS 3.1 / 3.2):** For synchronous request-response HTTP/REST APIs (`paths`, `operations`, `components.schemas`, `securitySchemes`, `webhooks`). In OAS 3.1+, use the `schema-base` JSON Schema dialect so payload `Schema Objects` themselves are strictly validated.
   - **AsyncAPI Specification (3.x):** For message-driven and event-driven APIs (Kafka, RabbitMQ/AMQP, MQTT, WebSockets, Server-Sent Events). In AsyncAPI 3.x, strictly separate **`channels`** (where messages flow: topics, queues, WS paths) from **`operations`** (`action: send` or `action: receive`), making bidirectional WebSocket and pub/sub flows explicit.
2. **Treat API specs as CI build inputs, never hand-edited static wiki pages:**
   - Lint and validate `openapi.yaml` and `asyncapi.yaml` in CI on every commit.
   - Either generate typed server stubs/client SDKs and reference docs from the spec (**Contract-First**), or export the spec from typed route/message schemas in CI and fail the build on any uncommitted diff or breaking change (`oasdiff` / Spectral / AsyncAPI Parser).
3. **Author prose for the 6 operational gaps that generated AsyncAPI references leave out (Fern):**
   Generated reference pages list endpoints, channels, and JSON schemas, but not the operational protocol rules developers get stuck on. Always document alongside the generated spec (in arc42 Section 6/8 or the API guide):
   - **Connection lifecycle** (is a subscribe frame required after connect, does the server send a ready/session message first, handshake timeout, keep-alive/heartbeat frames),
   - **Authentication handshake** (where the credential goes: upgrade-URL query parameter, `Authorization` header, or first frame),
   - **Reconnection & resumption** (resume from cursor, replay from sequence, or restart with a gap; backoff rules),
   - **Error frames & close codes** (exact error envelope and custom close codes, e.g. RFC 9457 Problem Details for HTTP, or error event payloads for AsyncAPI),
   - **Ordering & delivery guarantees** (at-least-once vs at-most-once, per-channel vs global ordering, duplicates; the skill adds `Idempotency-Key` headers and partition keys as practical advice),
   - **Backpressure** (whether a slow consumer is buffered, dropped, or disconnected).

4. **Embed OpenAPI / AsyncAPI cleanly into arc42 Docs-as-Code:** Store `openapi.yaml` and `asyncapi.yaml` in the repo, reference them from arc42 Section 3 (External Interfaces) and Section 5 (Building Block Interfaces), and render them in the same doc pipeline (e.g., `docToolchain`, Redocly, Scalar, Fern, or EventCatalog).

## Building order

1. **Create the arc42 skeleton (`docs/architecture/arc42.md` or `chapters/01..12`):** Fill Sections 1 (Goals), 2 (Constraints), 3 (Context + C4 L1), 4 (Strategy), and 12 (Glossary) first.
2. **Author the machine-readable contracts (`openapi.yaml` / `asyncapi.yaml`):** Define every external endpoint, channel, operation (`send`/`receive`), message envelope, and error schema.
3. **Fill Sections 5 (Building Blocks + C4 L2/L3), 6 (Runtime Flows), 7 (Deployment), 8 (Crosscutting), and 9 (ADRs):** Link directly to the contract files and ADR folder.
4. **Wire CI contract validation and drift checks:** Fail CI if the running application routes/events diverge from `openapi.yaml` / `asyncapi.yaml` or if any Markdown link in `docs/architecture/` breaks.

## Verification strategy

| Artifact | Verification Check | Tool / Mechanism |
|---|---|---|
| OpenAPI 3.1 / 3.2 spec | Schema & dialect validation + breaking-change diff | OAS `schema-base` validation, Spectral linter, `oasdiff` in CI |
| AsyncAPI 3.x spec | Channel/operation validation & message payload schema check | `@asyncapi/parser` / AsyncAPI CLI validation in CI |
| Implementation <-> Contract Parity | Contract / integration test | Verifies real HTTP responses and emitted broker/WS events conform 100% to the declared OpenAPI/AsyncAPI schemas |
| arc42 Documentation | Link check & freshness review | Automated relative-link checker in CI; updated in the same PR as structural changes |

## Mistakes to catch

- **Duplicating JSON fields in prose tables inside arc42:** Copy-pasting request/response field lists into Word/Confluence/Markdown tables that drift within two sprints. Keep schemas in `openapi.yaml` / `asyncapi.yaml` and link/embed them.
- **Using OpenAPI hacks to document Kafka topics or bidirectional WebSockets:** OpenAPI models HTTP request-response paths (`GET/POST/PUT/DELETE`); use **AsyncAPI 3.x** (`channels` + `send`/`receive` `operations` + protocol bindings) for event streams and WebSockets.
- **Validating OpenAPI 3.1+ with the outer `schema/` instead of `schema-base/`:** As the OpenAPI Initiative notes, the plain `schema/YYYY-MM-DD` validates only the outer OAS structure and ignores errors inside `Schema Objects`; use `schema-base/YYYY-MM-DD` to validate the JSON Schema definitions too.
- **Filling all 12 arc42 chapters with boilerplate text on day one:** Leaving template help text or writing 50 pages of filler. Write "just enough" in the sections that matter and expand as decisions are made.

## Deep references

- [arc42 sections and just-enough docs](references/arc42-sections-and-just-enough-docs.md) — read when deciding which of the 12 sections to write and how C4 and ADRs fit.
- [OpenAPI schema registry and validation](references/openapi-schema-registry-and-validation.md) — read when wiring OAS validation into CI (schema vs schema-base).
- [AsyncAPI document model and pipeline](references/asyncapi-document-model-and-pipeline.md) — read when modeling events or WebSockets in AsyncAPI 3.x and choosing generator stages.
- [Generated-docs gaps and docs-as-code integration](references/generated-docs-gaps-and-docs-as-code-integration.md) — read when authoring the operational guide beside generated docs or embedding OpenAPI in arc42 builds.
