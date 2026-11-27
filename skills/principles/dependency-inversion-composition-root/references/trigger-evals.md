# Trigger Evals

Last verified 2026-11-27. Prompts checked by reading against the description.

## Should trigger (dependency-inversion-composition-root)

1. "OrderService calls `new SmtpMailer()` inside; how do I fix it?"
2. "Should this class take its repo in the constructor or through a setter?"
3. "We call `container.resolve(...)` from handlers. Is that OK?"

## Near misses (belong elsewhere)

1. "Should the domain layer import the ORM? Lay out the layers." -> `clean-architecture` or `hexagonal-architecture`
2. "Add a new payment provider without editing the switch." -> `open-closed-principle`
3. "Do we need an interface for this single class?" -> `kiss-yagni-aha`
