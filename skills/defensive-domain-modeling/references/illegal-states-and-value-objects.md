# Illegal States, Union Types and Value Objects

Sources: https://fsharpforfunandprofit.com/posts/designing-with-types-making-illegal-states-unrepresentable/ · https://martinfowler.com/bliki/ValueObject.html · Last verified 2026-11-23

## Wlaschin's worked example: the Contact rule
Business rule: a contact must have an email **or** a postal address (or both).
- Both fields required: wrong, rejects valid contacts.
- Both fields optional: wrong, permits the forbidden "neither" state.
- Correct: a union of the three valid cases (email only, postal only, both). "Neither" has no representation.

Consequences described in the post:
- Construction can still fail (an invalid email), so constructors return an option/result.
- Updates must pattern-match all three cases; exhaustiveness checking forces each transition to be explicit.
- Calling `.Value` on an option is fine in a REPL but bad practice in production; match both `Some` and `None`.
- Why the extra complexity is worth it: the business logic really is that complex; the types document the rule; a rule change surfaces as compile errors where the types are used.

Own example, same shape in TypeScript:
```ts
type Channel =
  | { kind: "email"; email: Email }
  | { kind: "sms"; phone: Phone }
  | { kind: "both"; email: Email; phone: Phone };

const describe = (c: Channel): string => {
  switch (c.kind) {
    case "email": return `mail ${c.email}`;
    case "sms":   return `text ${c.phone}`;
    case "both":  return `mail ${c.email} and text ${c.phone}`;
  }
};
```
Note: the fetched page only links to the single-case-union and constrained-type posts and does not itself discuss legacy data; the SKILL.md legacy-row advice is the skill author's extension, not from this page.

## Fowler: Value Object
- **Value object** = equality by property values; **reference object** = identity by reference or ID. Entities (Evans) are the typical reference objects.
- Equality support varies: JavaScript compares references for object literals (a hand-written `equals` is invisible to `includes`); Java needs `equals` not `==`; Clojure compares compound data by value by default.
- **Aliasing bug**: two variables share one mutable object; changing it through one changes the other (Fowler's example: a date change for a party also moved a retirement date). Rule: value objects should be immutable; produce a new value instead of editing. Setter-free classes make this easiest; copying on assignment (C# structs) is another route; `freeze` helps but Fowler prefers explicit accessors.
- Immutability helps reference objects too but does not make them values if equality uses an ID.
- Context decides: an address can be a plain value in one system and a linked reference hierarchy in a mapping system.
- Small (money, range, point) and larger identity-free structures can both be values.
- Replacing primitives (a phone-number object instead of a string): clearer signatures, a natural home for validation, blocks meaningless operations like arithmetic on IDs. Fowler does not use the phrase "Primitive Obsession" on this page.
- Beware: older J2EE literature used "value object" to mean DTO.

## Decision rules
- Use a union when states have different required data; use flags/optionals only when fields are truly independent.
- Use a value object when the concept has no identity and equal fields mean "same"; use an entity when it must be tracked across changes.
- Prefer wrapper types for IDs and units when two same-typed arguments can be swapped.

## How an agent should apply this
- Rewrite "bag of optionals plus booleans" records as a discriminated union with one variant per valid combination.
- Make every `switch` on the union exhaustive (compiler `never` check) so rule changes break the build.
- Make value objects immutable, give them structural `equals`, and validate in a single factory.
- In JS/TS, remember `===` and `Array.includes` compare references; supply an `equals` and use it explicitly.
- Do not model a concept as a value object if callers need to track its identity over time.
