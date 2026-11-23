# Railway-Oriented Pipelines: Composition, Validation and Limits

Sources: https://fsharpforfunandprofit.com/rop/ · https://fsharpforfunandprofit.com/posts/recipe-part2/ · https://github.com/swlaschin/railway-oriented-programming-example · Last verified 2026-11-23

## Model
A step that can fail needs one return type carrying both outcomes: a `Result` with `Success`/`Failure`. Each step is a "switch" (one input, `Result` out). Steps are chained so success flows on and a failure skips the remaining steps; once on the failure track, data does not normally return. The `/rop/` landing page frames it as a specialised `Either` (with a list of custom error types) and offers "a recipe, not a tool".

## Adapters and what each is for (recipe part 2)
| Adapter | Use |
|---|---|
| `bind` | adapt a switch to accept two-track input |
| `switch` / `map` | lift a plain one-track function into a switch / a two-track function |
| `tee` | dead-end side effect (e.g. a DB write returning unit): run it, pass the input through |
| `tryCatch` | convert thrown exceptions into `Failure`; the final version takes a handler so the caller decides how an exception becomes a failure (plain `ex.Message` loses type info) |
| `doubleMap` | one function handling both tracks, e.g. logging successes and failures |
| `plus` (`&&&`) | run two validators on the same input and merge results |

Operators `>>`, `>=>`, `>>=` compose these. Note: the `/rop/` page itself names bind, Kleisli composition, map, tee, exception mapping and `&&&`, but not `tryCatch`/`doubleMap`/`plus`; those come from recipe part 2.

## Validation: serial versus parallel
Chaining validators with `bind` stops at the first failure, so users see one error at a time. `plus` runs all validators and merges failures (example output joins messages with "; "). The merge needs a caller-supplied way to combine successes and failures, because string `+` is not universal. The failure type is fixed across a pipeline because the adapters do not change it; the article defers a richer error type to a later post.

## Pitfalls the author lists
- Operator-heavy code puts off non-experts; rely mainly on `>>` and `|>`, and define any custom operator at the top of the module that uses it.
- Many equivalent spellings exist; choose one style per codebase.
- Optional steps: substitute `id` when a step (say, debug logging) is disabled.
- Overuse: the author warns against taking it to extremes and points to a separate "Against Railway-Oriented Programming" post (not fetched).

## Example repo (C# vs F#)
Two self-hosted WebApi projects implement "get customer" and "add/update customer". The C# error-handling version nests null checks, try/catch and per-branch logging. The F# version is a flat pipeline of `R`-suffixed lifted functions (`createCustomerIdR`, `getByIdR`, `customerToDtoR`, `logFailureR`, `toHttpResult`). Other points: domain primitives are opaque and validate on creation; the DAO returns explicit failure codes (`CustomerNotFound`, `DatabaseTimeout`) and returns an event in its result instead of firing a global event; the DTO converter uses applicative operators to collect all validation errors in one pass.

TypeScript sketch (own):
```ts
type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };
const bind = <A, B, E>(f: (a: A) => Result<B, E>) =>
  (r: Result<A, E>): Result<B, E> => (r.ok ? f(r.value) : r);
const tryCatch = <A, B, E>(f: (a: A) => B, h: (x: unknown) => E) =>
  (a: A): Result<B, E> => { try { return { ok: true, value: f(a) }; } catch (x) { return { ok: false, error: h(x) }; } };
```

## How an agent should apply this
- Use a two-track pipeline for sequential workflows with expected business failures; keep pure helpers single-track and lift with `map`.
- Wrap I/O and throwing libraries with `tryCatch` at the edge, with an explicit exception-to-error mapper.
- For form/request validation, accumulate errors in parallel; use serial `bind` only when a later step depends on an earlier result.
- Use a single typed error union per pipeline, and translate to HTTP/CLI output once, at the end (`doubleMap`-style).
- Keep the combinator vocabulary small and consistent; do not introduce operator soup in a team that does not use FP idioms.
