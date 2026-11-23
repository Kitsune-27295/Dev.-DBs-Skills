# Money: Currency, Rounding and Allocation

Sources: https://martinfowler.com/eaaCatalog/money.html · https://martinfowler.com/bliki/ValueObject.html · Last verified 2026-11-23

## What the sources say (read)

- The catalogue page is a short overview: money is not a first-class data type in mainstream languages, which causes errors in monetary calculations.
- **Currency**: single-currency code is manageable; mixing currencies requires accounting for exchange (adding dollars to yen directly is the example).
- **Rounding**: amounts are often rounded to the smallest currency unit, which can lose small amounts (pennies).
- **Solution**: an object-oriented Money class handling currency and rounding. The page defers details to Chapter 18 of *Patterns of Enterprise Application Architecture*.
- The ValueObject article names Money as the classic small value object.

Everything below beyond those points is **background knowledge or own synthesis, not read from the pages**. Verify against PoEAA ch. 18 if exact wording matters.

## Representation

- Integer **minor units** (cents) + ISO 4217 currency code, or a decimal type with explicit scale. Never binary floats (`0.1 + 0.2`).
- Scale comes from the currency (JPY 0, EUR/USD 2, KWD 3); keep a small table or use a library.
- Overflow: use 64-bit or big integers for amounts in minor units of large currencies.

```ts
class Money {
  private constructor(readonly minor: bigint, readonly currency: "EUR" | "USD" | "JPY") { Object.freeze(this); }
  static ofMinor(minor: bigint, c: Money["currency"]) { return new Money(minor, c); }
  add(o: Money) { this.same(o); return new Money(this.minor + o.minor, this.currency); }
  private same(o: Money) { if (o.currency !== this.currency) throw new Error("currency mismatch"); }
}
```

## Arithmetic rules

1. Add/subtract/compare only within one currency; mixed currency is an error (or a typed conversion step).
2. Multiply by a rate (tax, discount) with an explicit **rounding mode** (half-up, half-even/banker's, floor) chosen by business or legal rule; round **once** at the specified step.
3. Do not round intermediate steps unless the rule says so (statutory tax rules may require per-line rounding; record which).
4. Division produces a **remainder** concern: use allocation instead of dividing and rounding each part.

## Allocation (splitting without losing cents)

Goal: split `total` by ratios so that parts sum exactly to total.

```
allocate(total_minor, ratios):
  sum = Σ ratios
  parts[i] = floor(total_minor * ratios[i] / sum)
  remainder = total_minor - Σ parts
  for i in 0..remainder-1: parts[i] += 1      // deterministic: first k parts get one extra unit
  return parts
```

Example: 100 cents split 1:1:1 -> [34, 33, 33], sum 100. Naive `round(100/3)` three times gives 99.

Rules: distribution order of the leftover cents must be deterministic and documented (first recipient, largest remainder, etc.); negative totals need symmetric handling (test it).

## Conversion

Conversion needs a rate and its date/source from outside the Money type; the result is a new Money in the target currency with explicit rounding. Keep conversion in a service, not in the value object (a value object must not do I/O).

## Anti-patterns

- `double price` fields, JSON numbers with decimals round-tripped through floats.
- Rounding in presentation code instead of the domain.
- Dividing an invoice into equal instalments by dividing and rounding each.
- Currency stored as a free string with no validation.
- Comparing Money with `==` on amount alone (ignores currency).

## Tests to write

- Allocation conserves total for many (total, ratios) combinations (property test).
- Add across currencies is rejected.
- Rounding mode examples at exact .5 boundaries.
- Zero-decimal and three-decimal currencies.
- Serialization round trip keeps minor units exactly.

## How an agent should apply this

- Flag any floating-point money and propose minor units + currency.
- Replace divide-and-round splits with a conserving allocation function and a property test for conservation.
- Require an explicit, named rounding mode wherever a rate is applied.
- Keep FX conversion outside the value object and make the rate/date an input.
- State clearly in answers which Money details come from PoEAA and which are general practice.
