# DRY Refactoring Recipes and Detection (applied techniques)

Sources: https://media.pragprog.com/titles/tpp20/dry.pdf · https://martinfowler.com/bliki/BoundedContext.html · Last verified 2026-11-23
Note: the recipes below are the author's own application of the two sources' ideas, not text from them.

## Recipe 1 — Extract, then re-scan

1. Name the fact (e.g. "negative amounts print with trailing minus").
2. Extract one function that owns it; make callers use it.
3. Re-read the result for the *next* duplication, which becomes visible only after the first is gone (the source's balance report went through three rounds).
4. Stop when remaining links are intent, not accident, and write one line saying so.

```
# before: 5 callers each format sign and width
# after
def money(v): return f"{abs(v):10.2f}" + ("-" if v < 0 else " ")
def line(label, v): print(f"{label+':':<9}{money(v)}")
```

## Recipe 2 — Single enum / rule, many consumers

Symptom: status list in the service, in a DB CHECK, in OpenAPI, and in a UI dropdown. Choose the authority by blast radius (usually the schema or contract), then generate the others or add a test that fails if they diverge:

```
def test_status_enum_parity():
    assert set(Status) == set(openapi["components"]["schemas"]["Status"]["enum"])
```

A parity test is the cheapest SSOT when generation is not practical (inference).

## Recipe 3 — Derived fields

```
# before: order.subtotal, order.tax, order.total stored, updated in 4 places
# after
@property
def total(self): return self.subtotal + self.tax
```
If the DB must store it for queries, use a generated column or trigger-free constraint (`schema-and-constraints`). If you cache for performance, keep the cache private and recomputed in the single mutator, as in the source's `Line` example.

## Recipe 4 — Comment to name

Replace "what" comments with function names and visible structure. Keep comments only for non-obvious reasons. Delete comments that restate fee tables.

## Recipe 5 — Representational mirror

Replace hand-typed API client/DTO with generation from the spec; add a CI check that regenerates and diffs. For unstable external data, use a dict plus declarative validation:

```
REQUIRED = {"id": int, "email": str}
def validate(d): assert all(isinstance(d.get(k), t) for k, t in REQUIRED.items())
```

## Detection heuristics

| Signal | What to check |
|---|---|
| Same literal in code, tests and docs | Which one is authoritative? |
| Two files that change together in every commit | Likely one fact in two places (use git log co-change). |
| Fields suffixed `_total`/`_count` beside inputs | Derivable? |
| Parallel `switch` on the same discriminator in several files | Knowledge about the variant list is scattered (see `open-closed-principle`). |
| Validation in client and server | Server authority; share spec. |

## When NOT to apply

- Fewer than three occurrences and no shared owner: duplicate (see `pragmatic-solid-and-ssot`, `kiss-yagni-aha`).
- Occurrences are in different Bounded Contexts: translate instead.
- The "shared" version needs a mode flag: coincidence.

## How an agent should apply this

- Pick one recipe per commit; run tests between steps.
- Write down the authority for every duplicated fact in the commit message.
- Prefer generation > parity test > discipline, in that order.
- Do not delete the last copy of a rule before the owner has tests.
- Use git co-change history to find hidden duplication before reading code.
