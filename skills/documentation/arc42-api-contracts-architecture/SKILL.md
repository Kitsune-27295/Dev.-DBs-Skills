---
name: arc42-api-contracts-architecture
description: "Structure architecture documentation with the 12-section arc42 template and keep API contracts executable: OpenAPI 3.1/3.2 for HTTP request-response, AsyncAPI 3.x for channels and operations over Kafka, MQTT, AMQP or WebSockets, validated and diffed in CI, plus the operational prose generated references omit (connection lifecycle, auth handshake, resumption, close codes, delivery guarantees, backpressure). Not for drawing C4 diagrams (c4-model-architecture), writing one decision record (adr-architecture) or choosing Diataxis page forms (diataxis-documentation-architecture). Use when planning or reviewing arc42 docs, choosing OpenAPI versus AsyncAPI, or wiring contract validation and drift checks into CI."
---

# arc42 Architecture Documentation and API Contracts (OpenAPI / AsyncAPI)

One idea: keep the architecture comprehensible with the **12-section arc42 template**, and hand every interface detail in sections 3, 5 and 6 to **machine-validated contracts** (OpenAPI for synchronous HTTP, AsyncAPI for events, queues and WebSockets) that CI checks, so documentation and SDKs cannot drift from the code. Sources, retrieved statuses and unadopted claims: [references/sources.md](references/sources.md).

Boundaries: diagram notation is `c4-model-architecture`; one decision record is `adr-architecture`; page forms (tutorial, how-to, reference, explanation) are `diataxis-documentation-architecture`; the principle of one source of truth is `ssot-and-dry`. This skill owns the arc42 section map, the mapping of C4 levels and ADRs onto it, and the contract-first and CI rules for OpenAPI and AsyncAPI.

## 1. The 12-section arc42 map

Section names follow arc42.org and docs.arc42.org. The "Linked artifacts" column is this pack's convention, not arc42's: the arc42 section 3 page does not mention C4.

| # | Section | What belongs here | Linked artifacts |
|---|---|---|---|
| 1 | Introduction and Goals | Requirements overview, the top three (at most five) quality goals, stakeholders | Product vision |
| 2 | Constraints | Technical, organizational and regulatory limits | Compliance rules |
| 3 | Context and Scope | Business context (partners and data exchanged), technical context (channels), external interfaces | C4 level 1 plus external OpenAPI / AsyncAPI links |
| 4 | Solution Strategy | Fundamental decisions and quality strategies | Tech-stack summary |
| 5 | Building Block View | Static decomposition, black box to white box | C4 levels 2 and 3 plus internal contracts |
| 6 | Runtime View | Important scenarios, error paths, startup | C4 dynamic or sequence diagrams |
| 7 | Deployment View | Infrastructure, environments, mapping of blocks to nodes | C4 deployment diagram, IaC links |
| 8 | Crosscutting Concepts | Recurring patterns: auth, logging, error handling, transactions | Shared pattern guides |
| 9 | Architecture Decisions | The decision log | `docs/adr/` (`adr-architecture`) |
| 10 | Quality Requirements | Quality tree and measurable scenarios (stimulus, response, measure) | Load, chaos, security test links |
| 11 | Risks and Technical Debt | Known risks and prioritized debt | Risk register |
| 12 | Glossary | Domain and technical terms | Glossary table |

arc42 also offers a one-page **Canvas** for small systems. Write "just enough": document what readers need and skip what the code already shows. Details: [arc42 sections and just-enough docs](references/arc42-sections-and-just-enough-docs.md).

## 2. Contract rules

1. **Pair the spec with the communication style.**
   - **OpenAPI (3.2.1, 3.1.2 and 3.0.4 are the latest patches per the registry):** synchronous request-response HTTP (`paths`, `components.schemas`, security schemes, and `webhooks` since 3.1). For 3.1 and later validate with the `schema-base` artifact, which also checks Schema Objects; plain `schema` checks only the outer structure.
   - **AsyncAPI 3.x (3.1.0 is the newest version in the spec navigation):** message-driven APIs; the spec calls itself protocol-agnostic (AMQP, MQTT, WebSockets, Kafka, STOMP, HTTP, Mercure and others). Keep `channels` (where messages flow) apart from `operations` (`action: send` or `receive` referencing a channel). Do not model topics or WebSockets as OpenAPI paths; do not use 2.x `publish`/`subscribe` semantics in a 3.x document.
2. **Treat specs as build inputs, not wiki pages.** Lint and validate on every commit; either generate stubs, SDKs and reference docs from the spec (contract-first) or export the spec from typed route and message schemas and fail the build on an uncommitted diff or a breaking change. Tools to consider: a spec linter, `oasdiff` for breaking-change diffs, `asyncapi validate` or `@asyncapi/parser` for AsyncAPI.
3. **Write the six operational gaps by hand** beside the generated reference (arc42 section 6 or 8, or an API guide):
   - **Connection lifecycle**: is a subscribe frame required, does the server speak first, handshake timeout, heartbeats.
   - **Authentication handshake**: credential in the upgrade URL, an `Authorization` header or the first frame. The token and authorization rules themselves belong to `authn-authz-guard`.
   - **Reconnection and resumption**: resume from a cursor, replay from a sequence, or restart with a gap; backoff rules.
   - **Error frames and close codes**: the exact envelope and custom close codes; HTTP error bodies follow `error-handling-problem-details`.
   - **Ordering and delivery**: at-least-once or at-most-once, per-channel or global order, duplicates; consumer-side duplicate handling is `idempotency-fix`.
   - **Backpressure**: whether a slow consumer is buffered, dropped or disconnected.
4. **Embed contracts in the docs build.** Store `openapi.yaml` and `asyncapi.yaml` in the repo, link them from sections 3 and 5, and render them in the same pipeline (an arc42 toolchain, an OpenAPI renderer, or an event catalog). Retyping field lists in prose is the duplication `ssot-and-dry` forbids.

Details and sources: [OpenAPI schema registry and validation](references/openapi-schema-registry-and-validation.md), [AsyncAPI document model and pipeline](references/asyncapi-document-model-and-pipeline.md), [generated-docs gaps and docs-as-code integration](references/generated-docs-gaps-and-docs-as-code-integration.md).

## 3. Building order

1. Create the arc42 skeleton (`docs/architecture/` single file or one file per chapter). Fill 1, 2, 3, 4 and 12 first.
2. Author the contracts: every external endpoint, channel, operation, message envelope and error schema.
3. Fill 5 to 9 and link the contract files and the ADR folder.
4. Wire CI: spec validation, breaking-change diff, implementation-versus-contract tests, and a relative-link check for `docs/architecture/`.

## 4. Verification

| Artifact | Check | Mechanism |
|---|---|---|
| OpenAPI 3.1 / 3.2 | Structure plus Schema Object validation; breaking-change diff | `schema-base` validation, a linter, `oasdiff` |
| AsyncAPI 3.x | Channel and operation validation; payload schema check | `asyncapi validate` or `@asyncapi/parser` |
| Implementation versus contract | Contract or integration test: real responses and emitted events match the schemas | Test suite against a staging instance |
| arc42 docs | Link check; updated in the same PR as structural changes | Relative-link checker in CI |

A green schema check proves the document is well formed, not that the service matches it.

## 5. Mistakes to catch

- Copying request and response fields into prose tables that drift (link the spec).
- Documenting Kafka topics or bidirectional WebSockets with OpenAPI hacks (use AsyncAPI).
- Validating OpenAPI 3.1+ against `schema` and believing the schemas were checked.
- Filling all 12 chapters with boilerplate on day one; start with the sections a reader needs.
- Choosing doc tooling that only supports AsyncAPI 2.x for a 3.x spec; confirm version support first.

## Quick Decision Checklist

- [ ] Are schemas kept in the spec files and linked, not copied into prose?
- [ ] OpenAPI for HTTP request-response, AsyncAPI 3.x for events, queues and WebSockets?
- [ ] OpenAPI 3.1+ validated with `schema-base`?
- [ ] Does CI lint the specs and fail on breaking changes or implementation drift?
- [ ] Are the six operational gaps written next to the generated reference?
- [ ] Goals, constraints, context, strategy and glossary filled first?
- [ ] Do sections link to C4 diagrams, ADRs and contract files, with a link check in CI?

## Deep references

- [arc42 sections and just-enough docs](references/arc42-sections-and-just-enough-docs.md) - read when deciding which of the 12 sections to write and how C4 and ADRs fit.
- [OpenAPI schema registry and validation](references/openapi-schema-registry-and-validation.md) - read when wiring OpenAPI validation into CI (schema versus schema-base).
- [AsyncAPI document model and pipeline](references/asyncapi-document-model-and-pipeline.md) - read when modeling events or WebSockets in AsyncAPI 3.x and choosing generator stages.
- [Generated-docs gaps and docs-as-code integration](references/generated-docs-gaps-and-docs-as-code-integration.md) - read when authoring the operational guide beside generated docs or embedding OpenAPI in arc42 builds.
- [Trigger evals](references/trigger-evals.md) - read when tuning or checking the description.
- [Sources](references/sources.md) - retrieved statuses, reading limits and claims not adopted.
