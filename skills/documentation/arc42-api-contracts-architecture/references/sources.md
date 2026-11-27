# Sources - arc42, OpenAPI and AsyncAPI contracts

Every URL below was checked during skill authoring (2026-11-22; re-fetched and rewritten 2026-11-27 with WebFetch or curl).

| Source | Retrieved status (2026-11-27) | What it contributed |
|---|---|---|
| [arc42 overview](https://arc42.org/overview/) | 200 OK via WebFetch | The 12 section names, the Canvas, CC BY-SA 4.0, "since 2005", authors Hruschka and Starke |
| [docs.arc42.org home](https://docs.arc42.org/home/) | 200 OK via WebFetch | Open-source docs, 12 sections, same licence; no Canvas mention |
| [arc42 section 1](https://docs.arc42.org/section-1/) | 200 OK via WebFetch | Top three (max five) quality goals; ISO/IEC 25010:2023 as an example |
| [arc42 section 3](https://docs.arc42.org/section-3/) | 200 OK via WebFetch | Business and technical context, interfaces; no C4 mention |
| [arc42 section 10](https://docs.arc42.org/section-10/) | 200 OK via WebFetch | Quality tree, short and long scenario forms |
| [OpenAPI specification index](https://spec.openapis.org/oas/) | 200 OK via WebFetch | Versions (3.2.1, 3.1.2, 3.0.4 latest), `schema` versus `schema-base`, artifact dates, "latest date is most correct", "text is presumed correct" |
| [OAS 3.1.2 (HTML)](https://spec.openapis.org/oas/v3.1.2.html) | 200 OK via curl; grepped | `webhooks` and `jsonSchemaDialect` fields exist in 3.1 |
| [AsyncAPI specification 3.0.0](https://www.asyncapi.com/docs/reference/specification/v3.0.0) | 200 OK via WebFetch; last ~13,000 characters not read | Operation `action` send or receive, channel `$ref`, bindings, components |
| [AsyncAPI specification latest](https://www.asyncapi.com/docs/reference/specification/latest) | 200 OK via WebFetch; last ~13,600 characters not read | 3.1.0 is the top navigation entry; protocol-agnostic with listed examples (AMQP, MQTT, WebSockets, Kafka, STOMP, HTTP, Mercure) |
| [AsyncAPI Generator - document](https://asyncapi.com/docs/tools/generator/asyncapi-document) | 200 OK via WebFetch | Parser flow, plugin schemas, `originalAsyncAPI` versus `asyncapi` |
| [asyncapi/parser-js](https://github.com/asyncapi/parser-js) | 200 OK via WebFetch | Validation powered by Spectral; parser-js 3.x reads spec 2.x and 3.x; custom schema parsers |
| [Fern - AsyncAPI documentation generator](https://buildwithfern.com/post/asyncapi-documentation-generator) | 200 OK; WebFetch returned only a placeholder, so the page HTML was read with curl and a script | Dated 31 July 2026; six operational gaps, 2.x versus 3.0.0 operations, 3.1.0 current, pipeline stages. Vendor blog |
| [docToolchain discussion 1177](https://github.com/docToolchain/docToolchain/discussions/1177) | 200 OK via WebFetch | May 2023, unanswered; one workaround; 2023 tooling |
| [VickyBytes architecture documentation guide](https://vickybytes.com/blog/software-architecture-documentation-guide) | 200 OK; WebFetch returned no body, so the HTML source was read with a script | Just enough, freshness rules, common mistakes; general overview, not normative |
| [oasdiff](https://github.com/oasdiff/oasdiff) | 200 OK via WebFetch | Breaking-change and changelog commands, CI forms |
| [Spectral](https://github.com/stoplightio/spectral) | 200 OK via WebFetch | Lints OpenAPI 3.x; README and About line disagree on AsyncAPI versions |

## Reading limits

- Pages fetched with WebFetch are model-written extracts; exact wording was cross-checked only where a raw page was also read (Fern, VickyBytes, OAS 3.1.2).
- The AsyncAPI spec pages were read to about 100,000 of 113,000 characters.
- The OpenAPI 3.2 specification text itself was not read; 3.2 claims come from the registry index.
- AsyncAPI 3.0.0 versus 3.1.0 differences were not diffed.
- No validator, linter or generator was run.

## Corrections on 2026-11-27

- Removed "Server-Sent Events" from the AsyncAPI protocol list (the spec page lists other protocols; SSE was not found).
- Removed the ISO 25010 claim as a fixed rule (arc42 names it as an example) and the stimulus-response-metric phrasing (two documented forms).
- Dropped "Dr." titles, the unverified "alt text" diagram habit and the ADR and C4 notation text now owned by `adr-architecture` and `c4-model-architecture`.
- Idempotency-Key and partition-key advice moved to pointers (`idempotency-fix`); partition-key advice was an unsourced addition and is not adopted.

## Claims not adopted as fact

- Which C4 level maps to which arc42 section is this pack's convention.
- Spectral support for AsyncAPI 3.x.
- Any claim that tools in the Fern article beyond the spec-level facts are best choices; it is a vendor source.
- That generated AsyncAPI docs always omit all six gaps; the article says "consistently", which is not measured.
