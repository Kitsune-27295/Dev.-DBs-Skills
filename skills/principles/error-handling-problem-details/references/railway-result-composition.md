# Railway-Oriented Programming: Result Composition

Sources: https://fsharpforfunandprofit.com/rop/ · https://fsharpforfunandprofit.com/posts/recipe-part2/ · https://github.com/swlaschin/railway-oriented-programming-example · Last verified 2026-11-27

## What the pages say

- The landing page frames ROP as a recipe for the "happy path vs real-world failures" problem (validation, logging, network/service errors). It is *not* a monad tutorial, uses `Either` specialized with a list of custom error types, and warns "don't take it to extremes" (linking an "Against ROP" post). Aim: a consistent template, "basically only one way to write the code", not the only valid approach.
- The recipe components: **bind**, **Kleisli composition** (`>=>`), **map**, **tee** (for unit-returning functions such as logging), **exception mapping**, **`&&&`** (parallel validation), custom error types for domain modeling, extensions (logging, domain events, compensating transactions).
- The landing page does not name `tryCatch`, `doubleMap` or `plus`; the recipe part 2 page does, and defines the mechanics below.

## Mechanics

- A **result** has two cases: success (value) and failure (error). A step is a **switch**: one input, two-case output.
- Tracks must match when composing: two-track output feeds two-track input only through an adapter.
- **Failure is sticky**: after the first failure the remaining steps are bypassed.

| Combinator | Role |
|---|---|
| `bind` | Adapter: run a switch on success; pass failure through unchanged (this is the short-circuit) |
| `>=>` | Compose two switches into one: `switch1 >> bind switch2` |
| `switch` | Lift a plain function into a switch (success always) |
| `map` | Lift a plain function into a two-track function (success mapped, failure untouched) |
| `tee` | Make a dead-end (side-effect) function pass its input through |
| `tryCatch` | Like switch but turns thrown exceptions into failures |
| `doubleMap` | Apply one function per track (e.g. log both) |
| `succeed` / `fail` | Constructors so the representation can change later |
| `plus` / `&&&` | Run two switches on the same input; on success combine values, on failure **combine errors** (caller supplies the combine functions) — gives accumulating validation |

The series states the failure type must be identical along the whole pipeline because bind/map pass failures along without transforming them; for non-expert teams, prefer `>>`/`|>` or locally defined operators over exotic ones (series guidance).

## Pitfalls and example repo

- `tryCatch` takes a handler so the caller decides how an exception becomes a failure; plain `ex.Message` loses type info.
- Operator-heavy code puts off non-experts; define any custom operator at the top of the module that uses it, and choose one spelling per codebase.
- Optional steps (say, debug logging): substitute `id` when the step is disabled.
- Serial `bind` stops at the first failure; use `plus` when users should see every error at once, with a caller-supplied way to merge successes and failures.
- The example repo (swlaschin/railway-oriented-programming-example) contrasts a C# version nesting null checks, try/catch and logging with a flat F# pipeline of lifted functions; its DAO returns explicit failure codes and its DTO converter collects all validation errors in one pass.

## TypeScript sketch (own code)

```ts
type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };
const ok  = <T>(value: T): Result<T, never> => ({ ok: true, value });
const err = <E>(error: E): Result<never, E> => ({ ok: false, error });
const bind = <A, B, E>(f: (a: A) => Result<B, E>) => (r: Result<A, E>): Result<B, E> => r.ok ? f(r.value) : r;
const map  = <A, B, E>(f: (a: A) => B) => (r: Result<A, E>): Result<B, E> => r.ok ? ok(f(r.value)) : r;
const tee  = <A>(f: (a: A) => void) => (a: A): A => (f(a), a);
const tryCatch = <A, B, E>(f: (a: A) => B, onThrow: (e: unknown) => E) => (a: A): Result<B, E> => {
  try { return ok(f(a)); } catch (e) { return err(onThrow(e)); } };

// Accumulating validation (the `plus` idea): collect all field errors
const all = <T>(rs: Result<T, string>[]): Result<T[], string[]> => {
  const errs = rs.filter(r => !r.ok).map(r => (r as any).error as string);
  return errs.length ? err(errs) : ok(rs.map(r => (r as any).value as T));
};
```

Use pipeline: `parse -> validate -> loadAccount -> debit -> persist -> notify` where each step is `bind`; `notify` is a tee with its own error policy; infrastructure exceptions are `tryCatch`-ed only at the boundary adapters that can translate them.

## Error type design (own synthesis)

- One sealed union per layer: `ValidationError | NotFound | Conflict | Forbidden | Unavailable`.
- Translate at layer borders (repository errors -> domain errors -> problem details; see the mapping in `SKILL.md`).
- Errors carry data (field, id), not prebuilt messages; messages belong to presentation/problem details.
- Accumulate **only** where independent (validation); sequential steps stop at the first failure.

## Result vs exceptions
The decision table lives in `SKILL.md` section 4. Rule kept here: do not do both for the same failure, and catch exceptions to create `Err` only in deliberate boundary adapters.

## Failure modes

- Error type sprawl: dozens of cases nobody handles — group by caller-actionable decisions.
- `Result<T, string>` everywhere: loses structure; clients branch on text.
- Swallowing failures with `.unwrap()`/`.value!`.
- Over-applying ROP to trivial code (the author's own caution) — a guard clause and early return is often clearer.
- Mixed async/exception semantics: promise rejections escaping a Result pipeline.

## How an agent should apply this

- Return `Result` from use-case functions; keep exceptions for bugs and infrastructure, mapped at boundary adapters.
- Use one error union per layer and a single total mapping to problem details.
- Accumulate errors for independent validations; short-circuit for dependent steps.
- Use `tee` for logging/notifications so side effects do not disturb the data flow.
- Prefer guard clauses over a pipeline when only one or two steps can fail; do not take ROP to extremes.
- Do not let exceptions escape a Result pipeline untyped; test one failing step per branch.
