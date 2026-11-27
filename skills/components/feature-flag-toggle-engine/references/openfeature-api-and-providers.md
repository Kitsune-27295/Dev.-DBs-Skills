# OpenFeature API, Context, Providers and Hooks

Sources: https://openfeature.dev/docs/reference/intro/ · https://openfeature.dev/docs/reference/concepts/evaluation-api · https://openfeature.dev/docs/reference/concepts/evaluation-context · https://openfeature.dev/docs/reference/concepts/provider · https://openfeature.dev/docs/reference/concepts/hooks · Last verified 2026-11-27

## What it is

An open specification for feature flagging: a vendor-agnostic SDK API that plugs into open-source or commercial flag backends, self-hosted or cloud. Flags are evaluated at runtime, are often context-aware, and their configuration can change without redeploying. Building blocks: Evaluation API, Evaluation Context, Providers, Hooks, Events.

## Evaluation API

- Set a provider first. A **client** is a lightweight object; small apps use one, larger ones several, even per HTTP request.
- Basic evaluation returns boolean, string, number or object values; a **default value is mandatory** and is returned on any error.
- Detailed evaluation returns an Evaluation Details structure: key, value, and optionally reason, variant, flag metadata, error code, error message.

## Evaluation context

- Arbitrary data for dynamic evaluation. Server-side SDKs have three levels: **global**, **client**, **invocation**; merged at evaluation (duplicates overwritten per the spec; the page does not state precedence).
- Client-side SDKs use **static context** set on the API object, asynchronous and tied to provider reconciliation, then applied to all evaluations.
- **Targeting key:** a unique subject string (UUID, hashed email) enabling deterministic percentage rollouts; some providers require it.
- Avoid circular structures (providers serialize context). Limit PII; before-stage hooks can filter or anonymize.

## Providers

- Translate between the API and a flag system: wrap a vendor SDK, call REST, or read a file. **One provider registered at a time globally** (registering another overrides); with none, defaults are returned.
- **Domains:** register providers under names and bind clients by `getClient(domain)`, mixing providers in one app. The **Multi-Provider** spec lets one client combine several providers under a strategy (the page's example is first-match).
- Errors: thrown or returned per language idiom; SDK returns the default and exposes error data. A **disabled flag is not an error**: it yields a disabled reason. A backend that needs a missing targeting key may raise an error or generate one; the provider documents which. Unsupported flag types are converted (e.g. JSON in a string) or raise an error.

## Hooks

Stages: **before** (can modify context; runs before success is known), **after** (successful evaluations; validation, telemetry), **error** (missing flag, type mismatch, a before hook that throws), **finally** (always; cleanup; named `finallyAfter` in some languages). Registered at API (every evaluation), client, or invocation level. Order: before runs API → client → invocation; after/error/finally run invocation → client → API. Same-level hooks run in insertion order.

## Example (TypeScript-style, our wiring)

```ts
OpenFeature.setProvider(new FlagdProvider());                 // adapter lives at composition root
OpenFeature.addHooks(new LoggingHook());                      // telemetry for every evaluation
const c = OpenFeature.getClient("checkout");
export const useNewCheckout = (u: User) =>
  c.getBooleanValue("new-checkout", false, { targetingKey: u.id, tier: u.tier });
```

## Trade-offs

Gains: swap vendor without touching call sites; uniform telemetry via hooks; consistent targeting. Costs: lowest-common-denominator API (vendor-specific features need provider config), another dependency, and a provider outage still needs safe defaults.

## Failure modes

Risky default value; passing raw PII as context; multiple code paths creating differently-configured clients accidentally; hooks that throw in before stage and silently drop to defaults; relying on registering providers at runtime mid-request.
