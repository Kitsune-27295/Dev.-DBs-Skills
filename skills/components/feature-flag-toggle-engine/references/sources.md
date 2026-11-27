# Sources - Feature Flag & Toggle Engine

Re-fetched with WebFetch on 2026-11-27 (Firecrawl had no credits). WebFetch returns a model-produced digest, not raw text.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://martinfowler.com/articles/feature-toggles.html | 200 OK, 2026-11-27 | Four categories, longevity/dynamism, toggle point/router/configuration/context, inversion of decision, config options, testing convention, toggle debt, Knight Capital mention |
| https://openfeature.dev/docs/reference/intro/ | 200 OK, 2026-11-27 | Purpose and the five building blocks |
| https://openfeature.dev/docs/reference/concepts/evaluation-api | 200 OK, 2026-11-27 | Client, mandatory default, detailed evaluation fields, value types |
| https://openfeature.dev/docs/reference/concepts/evaluation-context | 200 OK, 2026-11-27 | Context levels, targeting key, PII advice |
| https://openfeature.dev/docs/reference/concepts/provider | 200 OK, 2026-11-27 | Provider role, one global provider, domains, multi-provider, error and disabled-flag behavior |
| https://openfeature.dev/docs/reference/concepts/hooks | 200 OK, 2026-11-27 | Hook stages, levels, ordering |

## Reading limits
- Context merge precedence, provider reason and error-code lists, and hook context fields are not stated on the pages read.
- Fowler's modulo-by-user-ID canary and signed overrides are offered as options ("perhaps", "one option"), not rules.

## Claims not adopted
- Provider authoring rules (SemVer, spec-version docs, client-side `onContextChange`) and the Tracking page: not read in this pass.
- "Long-lived kill switches behave like manual circuit breakers" and the "Champagne Brunch" label: not confirmed on the page read; removed or marked as our reading.
- Salting the cohort hash with the flag key: our inference, labeled as such.
