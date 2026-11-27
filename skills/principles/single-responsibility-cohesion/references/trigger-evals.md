# Trigger Evals: single-responsibility-cohesion

Last verified 2026-11-27 (paper test against the description; not run on a host).

## Should trigger

1. "OrderService is touched by billing, shipping and compliance tickets every week. Should I split it?" -> `single-responsibility-cohesion`
2. "A teammate says SRP means each class has one method. Is that right?" -> `single-responsibility-cohesion`
3. "Two packages change together in almost every commit; merge them?" -> `single-responsibility-cohesion` (CCP)

## Near misses

1. "Reorganize the folders into feature packages instead of controllers/services/repos." -> `package-by-feature-component`
2. "The same limit is repeated in code, docs and schema." -> `ssot-and-dry`
3. "Replace this growing switch on carrier type." -> `open-closed-principle`
