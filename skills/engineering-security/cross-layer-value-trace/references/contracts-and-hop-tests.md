# Contracts and Hop Tests

Sources: https://martinfowler.com/bliki/ContractTest.html · https://docs.pact.io · https://www.rfc-editor.org/rfc/rfc9413 · Last verified 2026-11-27

## Why the break usually lives at a boundary

A value changes meaning most easily where one team, service or type system hands it to another: the producer says one thing in its schema, the consumer parses another. The consumer often has a test double standing in for the producer, so everyone's tests pass while the real pair disagrees. Contract tests exist to catch exactly that.

## What a contract test is

Martin Fowler's definition: a contract test checks that the calls your code makes to an external service still match what that service really does. Your ordinary tests run against test doubles (stubs or fakes) for speed and stability; the contract test verifies that the doubles' responses still have the same **format** as the real service's. Key properties from his entry:

- It checks structure, not specific data. It does not prove the data is correct, only that the shape and types the consumer relies on still hold.
- A failure means the double is stale. The reaction is to update the double and the code depending on it, possibly after talking to the service's maintainers; it need not break the build the way a normal failure does.
- It can run on the supplier's schedule (the entry suggests about daily as often enough) rather than on every commit.
- Sharing the consumer's contract tests with the supplier lets the supplier run them in their own pipeline, which is the consumer-driven contracts idea.

## Consumer-driven contracts with Pact

Pact describes itself as a code-first tool for contract-testing HTTP and message integrations. In its consumer-driven model the contract is **generated when the consumer's automated tests run**, so only the interactions the consumer actually uses are covered, and the provider can change anything unused without failing. It calls this "contract by example": each test is one concrete request and response. The stated payoffs are fewer expensive, brittle integration tests and catching mismatches without deploying the whole system. The docs' introductory page does not detail the provider-verification step; consult its "How Pact works" and concepts pages for it. Use a Pact-style tool when producer and consumer are separately owned or released; for a single deployable with in-process layers, a shared schema or a plain test of the mapper is usually enough (this scoping is a recommendation of this skill, not a statement from the docs).

## Contract checks to run at the broken hop

When the trace has located the first bad hop, compare the two sides of the boundary just before and just after it:

| Check | Looks for |
|---|---|
| Field names and casing | Renamed on one side, defaulted on the other, so the consumer silently reads nothing |
| Types and units | String vs number, ratio vs percent, seconds vs milliseconds |
| Nullability and optionality | Producer can omit or send null; consumer type or schema says required with a default |
| Enums and open sets | New producer value mapped to a catch-all by the consumer |
| Timestamps | Present, time zone, produced-at vs served-at, preserved through the boundary |
| Error shapes | Producer error vs consumer's parser expecting a success body; error returned as an empty success |
| Pagination and limits | Consumer sees the first page as the whole set; totals computed over a truncated list |
| Defaults in the parser | Where a missing field becomes `0`, `""`, `false` or `[]` (the absence family) |

For API-level contracts, the schema or specification is the source of truth for what a field means; see `arc42-api-contracts-architecture`. For translating at a boundary where the vendor model leaks into the domain, see `dto-mapper-anti-corruption-layer`.

## Prove the fix at the hop, not end to end

The first bad hop determines the test level:

1. **Pure transformation bug** (mapper, aggregation, formatter): a unit test with the captured real input and the expected output. Use the real captured payload as the fixture so the test fails for the reason observed.
2. **Boundary mismatch**: a contract test or a schema-conformance test on both sides, so the next drift is caught where it happens. Pair with a consumer-side parse test using a captured producer response.
3. **Failure disguised as data**: a test that fakes the upstream failure and asserts the hop emits a degraded or error marker, not an empty success.
4. **Staleness**: a test with a controlled clock asserting the timestamp is preserved and that expired data is flagged.

Keep one end-to-end smoke check of the visible symptom for confidence, but never as the only proof: it says something is broken, not where. Test pyramid placement is covered by `testing-pyramid-and-shapes`; integration test craft by `integration-tests`; the red-green loop by `tdd`.

## Contract tests and tolerant parsers

RFC 9413 argues against broad "be liberal in what you accept" behavior because silent tolerance lets divergence accumulate and entrenches it. For a contract this means a consumer's parser should fail loudly or flag a degraded state on an unexpected shape rather than substitute defaults, and a contract test is how both sides agree on what "unexpected" means. The RFC concerns Internet protocols; extending it to internal APIs is this skill's analogy. It also recommends designing extension and error handling together, which maps to agreeing in the contract how new fields and error cases appear.

## Example: pinning a renamed field

```text
captured producer response: {"cpu_pct": 71.0, "sampled_at": "2026-11-24T10:00:02Z"}
consumer type expects:      {"cpuPercent": number, "sampledAt": string}
parser default:             cpuPercent = 0, sampledAt = now()   # silent repair
```

Hop test: feed the captured response to the consumer parser and assert it either maps `cpu_pct` to `cpuPercent` with `sampledAt` preserved, or raises/flags a parse problem. Before the fix this test fails by returning 0 and a fresh timestamp, which reproduces the user's symptom at the smallest scope.

## How an agent should apply this

- After finding the first bad hop, diff the producer's published schema against the consumer's type and parser, field by field, using a captured real payload.
- Treat parser defaults as part of the contract; list every field that has one.
- Write the failing test at the smallest level that reproduces the break, with the captured payload as fixture.
- Recommend a consumer-driven or schema contract test when producer and consumer have separate owners or release cycles; do not add heavy tooling for in-process layers.
- Keep the end-to-end check as a smoke test only, and say which hop-level test now guards the fix.
