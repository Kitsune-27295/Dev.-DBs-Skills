# Parse, Don't Validate at the Edge

Sources: https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/ · Last verified 2026-11-23

Type-level modeling (Value Objects, sum types, `Result`) is covered in `defensive-domain-modeling`. This file keeps only what drives **boundary design decisions**.

## Core argument

A *parser* takes less-structured input and returns more-structured output, with a failure mode. A *validator* checks a property and discards the evidence (`void` or `boolean`). The knowledge gained is lost, so downstream code must either re-check or assume.

Two ways to make a partial operation total (Alexis King's `head` example):
- **Weaken the result** (`Maybe`/`null` for an empty list): every caller must handle the impossible case, and removing the upstream check produces no compile error.
- **Strengthen the argument** (`NonEmpty`): the check happens once at the boundary, the function becomes trivially total, and removing the upstream parse breaks compilation. The author judges this better on every axis; the weak form is recoverable from the strong one, not vice versa.

## Shotgun parsing

Definition (LangSec, as cited): validation scattered through processing code, hoping some check catches each bad case. Consequences: the program may act on part of the input before discovering another part is bad, rollback is hard, and state is unpredictable. Remedy: **stratify** into a parsing phase (input failures happen here) and an execution phase (failures are rare and manageable).

## Rules for edge design

1. **Push the burden of proof upward, but no further.** Parse at the boundary; if only one branch needs a refined form, parse at the branch.
2. **Make illegal states unrepresentable** in the data structure you parse into (a map instead of a list of pairs forbids duplicate keys by construction).
3. **Distrust `m ()` / `void validate()` functions** whose job is to raise errors; their result is easy to forget. Return the refined value so the check cannot be skipped.
4. **Multi-pass parsing is fine:** one field may determine how another is parsed.
5. **Avoid denormalized, mutable duplicates;** if needed, hide them behind a small trusted module.
6. **When the type system cannot express an invariant,** use an opaque wrapper with a smart constructor so the validator behaves like a parser (in TypeScript: a branded type produced only by `parseX`).
7. **Authorization may precede parsing** to limit denial-of-service surface, but keep it small and free of state changes (author's footnote).
8. **Be pragmatic:** do not re-architect an application to remove one "impossible" branch; document the invariant in a comment (author's guidance).

## Example: validate vs parse at an HTTP edge

```ts
// Validator: proof discarded
function validateQty(q: unknown): void { if (!Number.isInteger(q) || (q as number) < 1) throw new Error("bad qty"); }
// Parser: proof kept in the type
type Quantity = number & { readonly __brand: "Quantity" };
function parseQuantity(q: unknown): Result<Quantity, "not_integer" | "below_min"> {
  if (!Number.isInteger(q)) return err("not_integer");
  return (q as number) < 1 ? err("below_min") : ok(q as Quantity);
}
```

## Failure modes

- Parsing deep inside the domain: each function re-checks; behavior diverges between copies.
- Returning the same raw type after "validation": later refactors silently skip the check.
- Parsing too early for data that is rarely used (cost) or too late (partial side effects already happened). Choose the earliest point where the refined type is needed.

## How an agent should apply this

- Locate every `validate*`/`is*` function; if callers keep using the raw value, change the signature to return the parsed type.
- Put parsing in adapters/controllers; domain function signatures take parsed types only.
- Reject code that performs side effects before the complete input is parsed.
- Use branded/opaque types with a single constructor when full type encoding is impractical.
- Document unencodable invariants next to the parse function.
- Defer value-object design to `defensive-domain-modeling`.
