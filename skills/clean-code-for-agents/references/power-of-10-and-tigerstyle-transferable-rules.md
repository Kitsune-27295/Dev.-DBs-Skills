# Power of 10 and TigerStyle: Which Rules Transfer to Ordinary Application Code

Sources: https://web.eecs.umich.edu/~imarkov/10rules.pdf (Holzmann, IEEE Computer, June 2006; read in full) · https://en.wikipedia.org/wiki/The_Power_of_10:_Rules_for_Developing_Safety-Critical_Code (rule list cross-checked) · https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/TIGER_STYLE.md (raw, read in full) · Last verified 2026-11-24

Context: Power of 10 targets safety-critical C and says so; its rules were picked to be machine-checkable. TigerStyle (TigerBeetle, written in Zig) builds on them for a financial database with design goals ordered safety, performance, developer experience. Neither is a general-purpose standard. Own judgment is marked "(inference)".

## The ten rules and TigerStyle counterparts

| Rule | Source | Transferable to general application code? | Caveat |
|---|---|---|---|
| 1. Simple control flow; no goto, setjmp, recursion | P10, echoed by TigerStyle | Partly: keep flow simple and explicit | No-recursion is for provable stack bounds; recursion is fine for trees and parsers when depth is bounded |
| 2. Every loop has a fixed provable upper bound | P10; TigerStyle "limit on everything" | Partly | Bound external work (retries, pagination, queues, timeouts); do not bound `for x in items` |
| 3. No dynamic allocation after init | P10, TigerStyle | No | Real-time and embedded memory rule; garbage-collected apps should not copy it |
| 4. Function fits one printed page (about 60 lines) | P10 | Yes as a heuristic (FN-03) | TigerStyle makes it a hard limit of 70 lines; the kernel gives screens, not a number (FN-02). Numbers are conventions; which one to cite is decided in CF-09 |
| 5. At least two assertions per function | P10, TigerStyle | Partly | Assert real invariants and impossible states; never pad to hit a count, and never use an assertion for expected errors |
| 6. Smallest possible scope for data | P10, TigerStyle | Yes | Declare near first use; do not reuse a variable for two meanings |
| 7. Check return values; validate parameters | P10; TigerStyle "all errors must be handled" | Yes, with judgment | P10 itself calls it the most violated and allows an explicit ignore with a reason |
| 8. Restrict the preprocessor | P10 | Language-specific | Analog: avoid heavy metaprogramming, macros, and many feature flags (inference) |
| 9. Restrict pointers; no function pointers | P10 | No | C-specific; do not ban callbacks or higher-order functions in app code |
| 10. Strict compiler warnings, zero warnings, static analysis daily | P10, TigerStyle | Yes | Use the project's linter, type checker and formatter at their strict settings, from the first commit |

## Further TigerStyle rules

| Rule | Transferable? | Caveat |
|---|---|---|
| Centralize control flow in the parent, keep leaf helpers pure ("push ifs up, fors down") | Yes as a heuristic | Sound decomposition guidance; its 70-line limit is covered in the table above (rule 4) |
| Assert pre/postconditions and invariants; crash on corrupt state | Partly | Right for a database; web apps usually return errors or fail the request, not the process |
| Pair assertions, positive and negative space, compile-time assertions | Rarely | Strong for storage and protocol code; heavy for CRUD |
| Units or qualifiers in names, most significant word first (`latency_ms_max`) | Yes for units | Unit suffix (`timeout_ms`) is widely useful; the word-order preference is style |
| No abbreviations; related names of equal length so they align | Partly | No-abbreviation yes; same-length alignment is aesthetics |
| `index`, `count`, `size` are distinct concepts; show division intent | Yes | Off-by-one discipline applies everywhere |
| Pass explicit options; do not rely on library defaults | Yes, where defaults are risky | Skip for harmless defaults |
| Split compound conditions; state conditions positively; every `if` considers its `else` | Yes as readability guidance | Do not add empty else branches |
| Explicit-width integer types; avoid `usize` | No | Systems-language concern |
| Static allocation; no dependencies; one language for tooling | No | Organizational choices of a database team; "zero technical debt" is a policy, not a technique |
| Back-of-envelope performance sketches; batching; control versus data plane | Only when performance matters | Design-time habit for hot paths |
| Always say why; commit messages with rationale; comments as full sentences | Yes | See `comments-why-not-what.md`; the text also says to explain how for tests |
| Do not react directly to external events; run at your own pace | Rarely | Event-driven apps do the opposite by design |

## Example: bound the external loop, not the in-memory one

```python
MAX_PAGES = 200  # unbounded API pagination would hang on a server bug

def fetch_all(client):
    items = []
    for _ in range(MAX_PAGES):
        page = client.next_page()
        items += page.items
        if not page.has_more:
            return items
    raise RuntimeError("pagination did not terminate")
```

## How an agent should apply this

- Take the principles, not the numbers: small functions, narrow scope, handled errors, strict tooling, bounded external work.
- Do not import C or Zig mechanics (pointer limits, no heap, `usize`, no recursion) into other languages.
- Put limits on retries, loops over external data, queues and timeouts; fail loudly when exceeded.
- Use assertions for "cannot happen" states in internal code; validate and return errors for untrusted input.
- Add unit suffixes to names that carry units; keep index, count and size distinct.
- Everything not marked transferable above is NG-01 or NG-02 in [rule-registry.md](rule-registry.md): do not generalize it.
