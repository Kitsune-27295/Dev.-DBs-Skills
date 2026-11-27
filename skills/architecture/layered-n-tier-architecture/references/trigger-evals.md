# Trigger Evals

Last verified 2026-11-27. Starting-point set (3 + 3), not a scored run.

| Prompt | Expected skill |
|---|---|
| "Review our Spring app: controllers call repositories directly and the service layer just forwards calls. Should we add a layer rule?" | `layered-n-tier-architecture` |
| "Do web, business and data access each need their own VMs, or can they share one deployment?" | `layered-n-tier-architecture` |
| "When is a relaxed (open) layer acceptable, and how do I document it?" | `layered-n-tier-architecture` |
| "Make the domain independent of the database with ports and adapters." | `hexagonal-architecture` or `clean-architecture` |
| "checkout.tsx is 1,800 lines mixing UI, pricing and Stripe calls; split it safely." | `layered-refactor` |
| "Explain how MVC differs from a three-tier web app's controller." | `mvc-architecture` |
