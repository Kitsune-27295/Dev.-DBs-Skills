# OpenAPI Schema Registry: schema vs schema-base and What Validation Proves

Sources: https://spec.openapis.org/oas/ · Last verified 2026-11-23

## What the index page lists

- Specification versions: v3.2.1 and v3.2.0; v3.1.2, 3.1.1, 3.1.0; v3.0.4 down to 3.0.0; v2.0. Other OAI publications (Arazzo, Overlay, registries for formats, media types, extensions and so on) sit alongside.
- Each minor release has up to four published JSON Schema artifacts, each identified by a revision date:

| Artifact | Purpose (from the page) |
|---|---|
| `schema/YYYY-MM-DD` | Validates the OAS document structure; makes no assumption about the JSON Schema dialect, so it does not validate Schema Objects |
| `schema-base/YYYY-MM-DD` | Also validates Schema Objects; if `jsonSchemaDialect` or `$schema` is present it must use the matching `dialect/` |
| `meta/YYYY-MM-DD` | Meta-schema for the OAS dialect |
| `dialect/YYYY-MM-DD` | The "base dialect": JSON Schema plus OAS extensions |

At retrieval, 3.2 listed `schema` and `schema-base` at 2026-11-12, `meta` and `dialect` at 2026-02-26; 3.1 listed `schema`/`schema-base` at 2026-11-05. 3.0 and 2.0 publish `schema` only (3.0: 2024-10-18 and 2021-09-28; 2.0: 2017-08-27). Dates will move; read the page, do not hard-code.

## Rules the page states

- All schemas of a minor release apply to its patch releases; dates identify revisions, not patch releases.
- The latest date within a minor release is the most correct schema; earlier revisions are obsolete.
- Schemas are not guaranteed to catch every violation; where the schema and the specification text disagree, the text wins.
- Open issues the page links: alternative JSON Schema dialects, programmatic access to latest schemas, and possible linting schemas.

## Consequences

- Passing `schema/` validation proves only that the envelope (paths, operations, components) is well-formed. A typo inside a `schema:` block can pass.
- `schema-base/` is the stricter check for 3.1 and 3.2 and is the one to automate in CI.
- Schema validation is necessary but not sufficient: it says nothing about whether the running service matches the document, nor about style (naming, missing `operationId`), which a linter covers.
- Pin the spec minor version in the doc (`openapi: 3.1.x`) and the validator to the matching latest schema revision.

## Example CI step (generic, my own sketch)

```
# validate envelope + schema objects against schema-base for the declared minor
validate-oas --schema schema-base --version 3.1 openapi.yaml
# then lint style rules
lint-oas openapi.yaml
# then run contract tests against a staging instance
contract-test --spec openapi.yaml --target $STAGING_URL
```

Tool names are placeholders; pick the validator your toolchain supports.

## Failure modes

- Validating 3.1+ documents with `schema/` and believing schemas are checked.
- Using an old schema revision, so new-version fields are rejected or missed.
- Treating a green schema check as proof of implementation parity.
- Hand-copying schemas into arc42 prose, creating a second source of truth.

## How an agent should apply this

- In CI use `schema-base` for 3.1/3.2 documents, then a linter, then contract tests.
- Record the OAS minor version and the validator's schema revision date in the repo.
- Reference the spec file from arc42 sections 3 and 5; never duplicate field tables.
- When schema and spec text conflict, follow the text and open a note in the risks section.
- Re-check the registry page when upgrading minor versions instead of assuming dates.
