# Value Object Mechanics

Sources: https://martinfowler.com/bliki/ValueObject.html · Last verified 2026-11-23

## Definition and contrast

A value object is a compound value (2D point, amount of money, date range) whose equality derives from its property values. A **reference object** is distinguished by identity (memory reference or unique ID, e.g. a sales order). Entities (DDD) are the common kind of reference object. The value/reference distinction applies to all code, "entity" only inside domain models.

## Equality across languages (from the article)

- Clojure compares maps by value; Java's `Point` overrides `equals`; Ruby uses an overridable `==`.
- JavaScript compares object references by default; a custom `equals` method is invisible to built-ins such as `includes`, so callers must use it explicitly. In Java `Object.equals` is part of the core library, so other libraries use it automatically.

Implication (own inference): in JS/TS, either compare via a canonical key (string/`JSON` key) in Sets/Maps, use a library of persistent structures, or always call `a.equals(b)` consciously; in Java/Kotlin/C#/Python prefer language records/dataclasses(frozen)/`record` types that give structural equality for free.

```ts
class DateRange {
  private constructor(readonly start: Date, readonly end: Date) { Object.freeze(this); }
  static of(start: Date, end: Date): DateRange {
    if (end < start) throw new RangeError("end before start");
    return new DateRange(new Date(start), new Date(end)); // defensive copies: Date is mutable
  }
  equals(o: DateRange) { return +this.start === +o.start && +this.end === +o.end; }
  overlaps(o: DateRange) { return this.start < o.end && o.start < this.end; }
  includes(d: Date) { return this.start <= d && d < this.end; }
}
```

## Aliasing bug and the immutability remedy

Two variables share one mutable object; changing it through one changes the other (the article's Java date example: changing a shared date moved a retirement date). Remedies, in order of preference:

1. **No setters; operations return new instances** (`range.extendTo(d)` returns a new range).
2. Enforce with the language (final fields, frozen records, `Object.freeze`, C# readonly struct); the article notes a disciplined team can maintain immutability without freezing.
3. Copy on assignment (value semantics, as with C# structs) where the language supports it.
4. Defensive copies of mutable inputs (like `Date`) in constructors and getters.

Immutability also helps reference objects (an order), but that does not turn them into value objects if equality uses their unique number.

## Range as the learning exercise

The article recommends building a Range class: the richer behavior (overlap, contains, merge, length) removes duplicated start/end logic scattered across callers. Value objects often become the focus of refactorings that simplify a codebase (article's claim). Own sketch of the payoff: callers stop comparing `start`/`end` by hand; the invariant `start <= end` is enforced once.

## Replace primitives: when and how

Benefits listed: explicitness, type checking, validation, preventing meaningless operations (arithmetic on IDs). Small candidates: points, money, ranges, phone numbers. Larger structures can be values too when they have no conceptual identity and are not shared by reference; functional languages default to this.

Context decides: an address can be a plain value in one system and a linked reference hierarchy in a mapping system. Older J2EE literature used "value object" to mean DTO; do not confuse the two.

## Decision rules

| Use a value object when | Avoid when |
|---|---|
| Concept has rules or behavior (overlap, currency) | Plain pass-through string with no rules anywhere |
| Same primitive pair is repeated (start/end, amount/currency) | One-off local variable |
| Confusable parameters of one primitive type | Persistence/ORM friction outweighs benefit and no invariant exists (record the exception) |
| Equality must be structural in collections | Concept has identity and lifecycle (use an entity) |

## Pitfalls

- Mutable fields exposed through getters (arrays, dates, lists): copy or use immutable collections.
- `equals` without `hashCode` (Java) breaks hash collections.
- Floating-point fields in equality (use integers/decimals).
- Putting persistence IDs into equality.
- Value objects that call services or the clock (side effects).

## How an agent should apply this

- When you see paired primitives or a validated string, propose an immutable, self-validating type with structural equality.
- Check equality is actually used by the collections/tests in that language (especially JS/TS).
- Reject setters and in-place mutation methods on value types; return new instances.
- Make defensive copies for mutable inputs such as dates and arrays.
- Decide value vs entity per bounded context and state the reason in the PR.
