# Parse, Don't Validate: Mechanics and Limits

Sources: https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/ · Last verified 2026-11-27

## Core definitions (from the post)
- **Validation** inspects data and returns only pass/fail (or `void`); what it learned is discarded.
- **Parsing** consumes less-structured input and returns a more-structured type that *keeps* what was learned. A parser is a partial function and must have a failure mode.
- **Total function**: defined for every input of its declared type. The goal is to make downstream functions total by strengthening argument types, not by weakening return types.
- **Shotgun parsing**: checks scattered through processing code. The post (citing LangSec work) stresses the real harm: the program may already have acted on a valid prefix of the input when a later invalid part is found, and rollback is often impossible.

## The two fixes for a partial function
The post's example is `head` on a list. Two options:
1. **Weaken the result** (`Maybe`/`Option`): total, but every caller must handle "absent", even when an upstream check already proved non-emptiness. Costs: redundant check, possible hot-loop overhead, and a latent bug: if the upstream check is deleted, the "impossible" branch becomes reachable and nothing complains.
2. **Strengthen the argument** (`NonEmpty`): the check happens once at the edge; if someone removes it, the types stop lining up and the compiler fails. The post calls this superior on all axes; the weak version is derivable from the strong one, not the reverse.

TypeScript sketch (own example):
```ts
type NonEmpty<T> = readonly [T, ...T[]];
const parseNonEmpty = <T>(xs: readonly T[]): NonEmpty<T> | null =>
  xs.length > 0 ? (xs as NonEmpty<T>) : null;

const first = <T>(xs: NonEmpty<T>): T => xs[0]; // total, no throw
```

## Two-phase program shape
Parse everything first (invalid input may fail here), then run an execution phase with far fewer failure modes. Validation-style code makes it hard to know whether all checks have happened, so every later operation must assume it can blow up.

## The post's practical advice
- Make illegal states unrepresentable; pick the most precise structure (e.g. a `Map` rather than a list of pairs so duplicate keys cannot exist).
- Push the burden of proof upward, but no further: parse as early as the boundary allows; if a branch needs more precision later, parse at the branch and use sum types for control flow.
- Let datatypes drive code. Treat `m ()`/`void` functions whose main job is to raise an error with suspicion.
- Avoid denormalized, especially mutable, data; if unavoidable, hide it behind a small module that keeps copies in sync.
- When the type system cannot express the invariant, use an abstract/opaque type with a smart constructor so the validator "looks like" a parser.
- Authorization may legitimately precede parsing (to resist denial of service) if it is narrow and does not change state.

## Trade-offs the post admits
- Parsing moves failure to the boundary; it does not remove it.
- Early parsing can create sync problems in dynamic languages; refactoring cost ripples through call chains (a benefit and a cost).
- Some invariants (ranges, relations) are hard to encode; the principles are ideals, not strict requirements. Refactoring a whole app to delete one "impossible" branch is often not worth it: document the invariant in a comment instead.
- Note: the post does not use the term "boolean blindness"; the nearest advice is not to carry a `Bool` just because a function needs one, and to let a refined type carry the fact instead (SKILL.md's boolean-blindness rule is an inference in that spirit).

## How an agent should apply this
- When you see `validateX(): void` / `isValidX(): boolean` followed by use of the raw value, change the return type to the refined type or `Result<Refined, Error>`.
- Prefer strengthening function parameters (`NonEmpty`, `PositiveInt`, `Email`) over adding `| undefined` returns to downstream helpers.
- Put the parse at the outermost edge (HTTP handler, CLI, deserializer) and make the rest of the pipeline take refined types.
- Where the language cannot express the invariant, use an opaque class with a private constructor plus a smart constructor, and leave a comment naming the invariant.
- Do not rewrite a large module to eliminate a single provably impossible branch; document it.
