# AsyncAPI: Document Model, Parser Pipeline and Generator Stages

Sources: https://asyncapi.com/docs/tools/generator/asyncapi-document · https://buildwithfern.com/post/asyncapi-documentation-generator · Last verified 2026-11-23

The Fern article (dated July 2026) is a vendor blog that sells its own product; vendor-neutral claims below are those that describe the spec or the pipeline, and product claims are omitted.

## Document model (Fern, AsyncAPI 3.x)

| Object | Role | Why it matters |
|---|---|---|
| `info` | title, version, description | landing page and version label |
| `servers` | host, protocol, security | where and how to connect |
| `channels` | addresses plus parameters | navigational spine |
| `operations` | `send` / `receive` actions on channels | distinguishes client from server behavior |
| `messages` | payload schema, headers, content type, examples | what developers copy |
| `components` | reusable schemas, messages, security, traits, bindings | prevents duplicated inline shapes |
| `bindings` | protocol-specific settings (WebSocket headers/query, Kafka group/client ID, MQTT QoS/retain) | transport detail renderers often drop |

The 3.0 change: operations became top-level with an explicit `send` or `receive` action referencing a channel via `$ref`, replacing 2.x `publish`/`subscribe`, whose perspective confused people. Bi-directional flows (a WebSocket) are modeled as one `send` and one `receive` operation on the same channel. Channel `$ref` uses JSON Pointer with URL encoding (`#/channels/user~1notifications`).

## Generator pipeline

Official docs describe the AsyncAPI Generator flow: the document goes in as a string, the Parser validates it with schema plugins (OpenAPI schema, RAML data types, Avro), and a valid document is wrapped in an `AsyncAPIDocument` with helpers (`version()`, `info().title()`, `channels()`, `allMessages()`). Templates read either `originalAsyncAPI` (the raw string) or the structured `asyncapi` object. Format is JSON or YAML; the document is protocol-agnostic and machine-readable.

Fern's five stages: parse and validate, resolve `$ref`s, build an intermediate model, render via template, publish. It argues stages 1 and 5 (validation and publishing) decide long-term accuracy: a hand-run generator is accurate once; one wired into CI per PR stays accurate.

## Tool roles named by the article

AsyncAPI Generator (`asyncapi generate fromTemplate asyncapi.yaml @asyncapi/html-template`; HTML and Markdown templates), EventCatalog (event/service/domain catalog), Bump.sh (hosted portals with changelog), Modelina (typed models, not docs). Choose by role: renderer, catalog, hosted platform, or model generator; teams often combine two or three.

## OpenAPI vs AsyncAPI in one table

| Concern | OpenAPI | AsyncAPI |
|---|---|---|
| Unit | endpoint (path + method) | channel + operations |
| Direction | client asks, server answers | either side; often both |
| State | stateless per request | connection state, subscriptions, sequence |
| Failure | status codes | error frames, disconnects, redelivery, ordering |

## Failure modes

- Rendering only message schemas and ignoring bindings (docs look complete, first connection fails).
- Using 2.x `publish`/`subscribe` semantics in a 3.x document.
- Duplicated inline message shapes instead of `components`.
- Tooling that still targets only 2.6.0 chosen for a 3.x spec; confirm version support first.

## How an agent should apply this

- Model Kafka topics and WebSocket endpoints as `channels` with `send`/`receive` operations, never as OpenAPI paths.
- Put shared payloads in `components` and reference them; add bindings for every server and channel.
- Run `asyncapi validate` (or equivalent) in CI on every spec change.
- Regenerate on merge; do not commit hand-edited generated output.
- Link the spec from arc42 section 3 (context) and 5 (building blocks); never retype message fields.
