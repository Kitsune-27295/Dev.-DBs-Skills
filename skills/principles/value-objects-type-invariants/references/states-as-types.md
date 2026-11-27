# States as Types: Making Illegal States Unrepresentable

Sources: https://fsharpforfunandprofit.com/posts/designing-with-types-making-illegal-states-unrepresentable/ · Last verified 2026-11-27

## The worked example in the article

Business rule: a contact must have an email address, a postal address, or both.

1. **Naive**: a `Contact` with required name, email and postal fields — too strict; it forces both.
2. **Overcorrection**: both fields optional — the forbidden "neither" state becomes representable.
3. **Redesign**: list the legal cases (email only, postal only, both) and encode them as a union with one case per legal state. The "neither" case does not exist, so it cannot be constructed.
4. **Constructor**: a creation function validating an email string can fail, so it returns an optional/result (author's inference from the article's use of options).
5. **Update**: updating the postal address must handle all three cases — email-only becomes both; postal-only is replaced; both keeps the email and replaces the postal address.
6. The author warns that unsafe optional unwrapping (`.Value`) is for interactive experiments only; production code matches both cases.

Why the extra code is worth it (author): the business logic is genuinely complicated and simple-looking code may skip cases; the union cases document the rule; a rule change becomes a compile-time error. The phrase "make illegal states unrepresentable" is credited to Yaron Minsky.

## Recipe

1. Write the business rule as a list of **legal states** (truth table of the optional parts).
2. Give each legal state a union case containing only the fields valid there.
3. Replace boolean flags with cases (own illustration below).
4. Write transitions as functions `StateA -> StateB`; handle every case exhaustively.
5. Convert at boundaries: parse DTO -> union (`defensive-domain-modeling` covers parsing); union -> DTO with an explicit discriminator.

```ts
// Own illustration (not from the page): flag soup vs states
type Bad  = { verified: boolean; verifiedAt?: Date; token?: string };      // allows {verified:true} with no date
type Good =
  | { kind: "unverified"; email: Email; token: Token }
  | { kind: "verified";   email: Email; verifiedAt: Date };
const verify = (s: Extract<Good,{kind:"unverified"}>, now: Date): Good =>
  ({ kind: "verified", email: s.email, verifiedAt: now });   // token is gone by construction
```

Exhaustiveness in TS: `switch (s.kind) { ... default: const _x: never = s; }` forces handling of new cases.

## When to use / avoid

| Use when | Avoid when |
|---|---|
| Different states carry different data or allow different operations | A boolean is truly independent of other fields |
| A rule says "exactly one", "at least one", "if X then Y required" | The combination space explodes (>6-8 cases): extract sub-models or a state machine |
| The compiler can check exhaustiveness (sum types, sealed classes) | Wire format or ORM cannot carry the discriminator and you lack a mapping layer |
| Rule changes are expected and should surface as compile errors | One-off script with no business rule |

## Failure modes

- Encoding the union but then flattening it back to a nullable-field DTO inside the domain.
- Using `Optional` unwrapping with default values to "make it compile" (silently reinstates illegal states).
- Putting unrelated optional parts into one union (model each independent dimension separately; use product of small unions, not one giant union).
- Forgetting the database: a union persisted as nullable columns needs CHECK constraints (`schema-and-constraints`).
- Leaking union cases directly into public API without versioning; adding a case is a breaking change for exhaustive consumers (note it in the contract).

## State per type (own extension, labeled)

When states permit different **operations**, give each state its own type (`UnverifiedEmail`, `VerifiedEmail`) and expose only valid operations on each (`sendVerification` on unverified, `sendNewsletter` on verified). The compiler then rejects "send newsletter to unverified". This goes slightly beyond the page, which focuses on data-shape unions; the next post in the author's series (not read) covers state machines.

## How an agent should apply this

- Turn each business rule with "or/and/if" into a table of legal states before touching types.
- Replace flag-plus-optional records with a discriminated union; update all transitions and matches.
- Never silence exhaustiveness with defaults that return a made-up value.
- Pair every in-memory union with a boundary mapping and a DB CHECK or equivalent.
- Call out API-contract impact when adding or removing a union case.
