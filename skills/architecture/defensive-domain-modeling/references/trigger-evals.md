# Trigger Evals

Last verified 2026-11-27

Should trigger `defensive-domain-modeling`:
1. "Our Order class has isPaid, paidAt and receiptId all optional and bugs keep appearing. Redesign it so bad combinations cannot exist."
2. "Callers do order.getCustomer().getWallet().withdraw(x). How should I restructure this?"
3. "Refactor validateEmail(): void plus non-null assertions into something where the compiler carries the proof."

Near misses (expected skill):
1. "Add allowlist and size-limit validation to our webhook endpoint." -> `validator-input-parser`
2. "Design a Money value object with rounding and allocation." -> `value-objects-type-invariants`
3. "Return RFC 9457 problem details for domain errors." -> `error-handling-problem-details`
