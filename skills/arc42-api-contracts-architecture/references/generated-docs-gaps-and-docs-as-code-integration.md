# What Generated API Docs Omit, and Wiring Specs into arc42 Builds

Sources: https://buildwithfern.com/post/asyncapi-documentation-generator · https://github.com/docToolchain/docToolchain/discussions/1177 · Last verified 2026-11-23

## Part 1: the operational gaps (Fern article)

Generating from a spec yields a message catalog, not integration documentation. The article lists six gaps, in the order developers hit them:

| Gap | What must be written by hand |
|---|---|
| Connection lifecycle | Is a subscribe frame required after connect? Does the server send a ready/session message first? Handshake timeout? |
| Authentication handshake | Where the credential goes: upgrade-URL query parameter, `Authorization` header, or first frame; each needs different client code |
| Reconnection and resumption | Resume from cursor, replay from sequence, or fresh with a gap; undocumented, every consumer invents its own and some lose messages silently |
| Error frames and close codes | Channel error messages and custom WebSocket close codes (an undocumented 4003 becomes a support ticket) |
| Ordering and delivery | At-least-once vs at-most-once, per-channel vs global ordering, duplicates, so consumers know if they need idempotency |
| Backpressure | Whether a slow consumer is buffered, dropped or disconnected |

Note: the skill's SKILL.md and sources.md name four of these; the article text lists six, adding ordering/delivery and backpressure.

Recommended pipeline from the same article (generic, not product-specific): write the spec first; model both directions explicitly; fill bindings; add realistic examples, ideally frame sequences; validate and lint in CI so broken refs and missing `operationId`s fail the build; regenerate on merge, never by hand; author the integration guide beside the generated reference; publish the raw spec. If docs and a generated client come from different spec copies they diverge, so both must build from one document in one pipeline (the single-source-of-truth argument).

## Part 2: OpenAPI inside arc42 with docToolchain (Discussion #1177)

A May 2023 Q&A, marked unanswered, with one comment and one reply. The asker generated AsciiDoc from `petstore-v3.0.yaml` via `exportOpenApi` (output `build/OpenAPI/index.adoc`) and wanted it in the Building Block View (`05_building_block_view.adoc`) as a black box's interface description. Problems raised: how to include the generated file (relative `include::` into `build/` vs copying into `chapters/`), the generated `:toc:`/`:numbered:` header attributes disrupting the host document, and heading levels not fitting the chapter.

Workaround from the commenter: a custom Gradle task using the OpenAPI Generator plugin (version 6.5.0 in the thread) with the `asciidoc` generator, `headerAttributes:false` to suppress header attributes, output under `target/`, an `include::` pointing at the generated `index.adoc`, and a shell loop that exports several specs into separate `target/<apiName>` folders. Gaps the asker listed in docToolchain: pass the spec path on the command line, define the output directory, forward custom generator properties, support multiple specs. The heading-level question was not answered in the thread.

## Trade-offs

| Approach | Pro | Con |
|---|---|---|
| `include::` generated output at build time | Never drifts | Heading/attribute clashes; needs build step |
| Copy generated file into chapters | Simple | Stale after next spec change |
| Link to hosted reference from the chapter | No clash | Reader leaves the document; link rot |

## How an agent should apply this

- In arc42 section 5 (and 3), include or link generated output; never paste field tables.
- When including AsciiDoc output, suppress header attributes and plan heading offsets; test the full docs build.
- Add an authored "connecting to the API" page covering the six gaps next to the generated reference.
- Handle multiple specs with one output folder per API and a loop in CI.
- Treat Discussion #1177 as a pattern source, not an official recipe: it is unanswered and tied to 2023 tooling versions.
