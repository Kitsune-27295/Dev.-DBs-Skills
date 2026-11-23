# DRY as Knowledge: the Five Duplication Kinds

Sources: https://media.pragprog.com/titles/tpp20/dry.pdf · Last verified 2026-11-23

## Definition and why it matters

Thomas and Hunt define DRY as: every piece of knowledge needs a single, unambiguous, authoritative representation within a system. Their argument is about time: knowledge is unstable (requirements, regulations, algorithms change), so programmers are always in "maintenance mode". Each duplicate is a future inconsistency: "not whether you will forget, but when". The 20th-anniversary edition explicitly corrects the first edition's reading that DRY means "do not copy-paste lines".

**Acid test** (paraphrased): when one facet changes, do you edit several places, in several formats (code and docs, schema and a struct holding it)? Then it is not DRY.

## Kind 1 — Code duplication

Their `print_balance` example shows layered discovery: (1) negative-number handling copied, fixed with `format_amount`; (2) field width repeated in every call, fixed by reusing the same helper; (3) label spacing repeated five times, fixed with `print_line`/`report_line`. After each extraction a new duplication became visible. A residual link remains (separator width vs. amount width) which the authors keep because it is *customer intent*, distinct from amount formatting. Lesson: duplication hunting is iterative, and some links are deliberately not removed.

## Coincidence is not duplication

`validate_age` and `validate_quantity` have identical bodies (integer, min 0). The authors say a reviewer who calls this a DRY violation is wrong: the knowledge differs, the rules coincide. Decision rule (derived): if the business owner could change one rule without the other being affected, they are separate facts.

## Kind 2 — Documentation duplication

A comment listing fee rules above code implementing the same rules states intent twice; they will drift. The authors' fix: rename and lay out code so the comment is unnecessary (`calculate_account_fees`), leaving the code as the single statement. Comments should add what code cannot (reasons, constraints).

## Kind 3 — Data duplication

`Line { start, end, length }` stores length although it is determined by the endpoints. Make it computed. If performance requires caching, the authors accept a deliberate violation **provided its impact is localized**: only methods inside the class maintain the cache, setters recompute it. Pair this with accessor functions and Meyer's **Uniform Access Principle** (services available through one notation regardless of storage vs. computation), so you can swap the implementation later.

```
class Line:
    def __init__(s, a, b): s._a, s._b = a, b; s._len = a.dist(b)   # cache is private
    def set_end(s, p): s._b = p; s._len = s._a.dist(p)            # single place that keeps it true
    def length(s): return s._len                                  # callers cannot tell
```

## Kind 4 — Representational duplication

Any interface to the outside world (APIs, schemas, error codes) forces your code to know something the other side also knows. It is inevitable; mitigate:
- **Internal APIs:** a neutral spec format that generates docs, mocks, tests and clients, ideally in a central shared repository.
- **External APIs:** import the published spec (OpenAPI); if none exists, consider writing and publishing one.
- **Data sources:** introspect the schema and generate containers, or hold data in key/value maps plus a small table-driven validation suite that verifies required keys and formats.

## Kind 5 — Interdeveloper duplication

Hardest to detect. Their anecdote: an audit of a US state's systems found over 10,000 programs each with its own Social Security number validation. Remedies are social: frequent communication, forums, a "project librarian", a central place for utilities, reading others' code in reviews. Tip 16: make it easier to reuse than to rewrite.

## Forces and trade-offs

- Removing duplication adds indirection; worth it only when the shared fact really is one.
- Caching/denormalization is legitimate when encapsulated; unencapsulated it is a DRY bug.
- Generated artifacts shift duplication from humans to tooling; the cost is a generation step that must be enforced.

## How an agent should apply this

- State the duplicated *fact* and its locations before proposing any extraction.
- Treat comments that paraphrase code as defects; fix by renaming, not by updating the comment.
- Replace stored derived fields with accessors; if caching, keep it private to one module.
- At system edges prefer generating or validating against one spec over hand-mirroring.
- For interdeveloper duplication, search the repo for existing implementations before writing a new helper.
- Leave lookalike rules alone unless the same business owner would change both.
