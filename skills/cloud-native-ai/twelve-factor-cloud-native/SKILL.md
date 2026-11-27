---
name: twelve-factor-cloud-native
description: "Review or design a service so it runs as a portable, stateless, scalable workload: the twelve factors of the Twelve-Factor App (config in the environment, stateless processes, build/release/run separation, fast start and graceful SIGTERM, logs as stdout streams, dev/prod parity, one-off admin tasks), the three later additions (API first, telemetry, authentication and authorization), and how to classify a new environment variable (secret, deploy config, local, constant; browser-exposed prefixes are public). Read-only guidance with a failure-symptom table. Not for retry, breaker or tracing design (use circuit-breaker-retry-telemetry), login and token design (use authn-authz-guard) or secret scanning (use security-audit). Use when asked to make an app container-ready, audit config and statelessness, review shutdown or logging, or decide where a variable belongs."
---

# Twelve-Factor and Cloud-Native Design

One idea: **design the app so the platform, not the app, owns where it runs: everything that varies per deploy comes in from outside, nothing that must survive lives inside the process.** The rules come from the Twelve-Factor App site (credited to Adam Wiggins, page marked last updated 2017) and from a later 15-factor extension. Sources, retrieved statuses and claims not adopted: [references/sources.md](references/sources.md).

> **Scope boundary:** retries, breakers, bulkheads and OpenTelemetry instrumentation live in `circuit-breaker-retry-telemetry`. Login, session and token design live in `authn-authz-guard`. Secret scanning and git-history review live in `security-audit`. Moving business rules from client to server lives in `never-trust-the-client`. This skill owns the factor checklist and variable placement.

## 1. The twelve factors

Titles are the site's own wording. The right column is this skill's shorthand for the failure you will see in review (own commentary; the site pages for I, II, IV, VII, VIII and XII were not re-read in depth, see sources).

| # | Factor | Rule | Typical violation |
|---|---|---|---|
| I | Codebase | One codebase tracked in revision control, many deploys | Several deploys from diverging copies |
| II | Dependencies | Explicitly declare and isolate dependencies | Relying on packages installed system-wide |
| III | Config | Store config in the environment | Credentials in source; `if ENV == "staging"` branches |
| IV | Backing services | Treat backing services as attached resources | Local DB handled differently in code from the production one |
| V | Build, release, run | Strictly separate build and run stages | Hotfix edited on the server |
| VI | Processes | Execute the app as one or more stateless processes | Session or cart in process memory; sticky sessions |
| VII | Port binding | Export services via port binding | App only works inside an external web container |
| VIII | Concurrency | Scale out via the process model | Scaling only by bigger threads in one process |
| IX | Disposability | Fast startup, graceful shutdown | Dropped requests or jobs on restart |
| X | Dev/prod parity | Keep development, staging and production as similar as possible | SQLite locally, PostgreSQL in production |
| XI | Logs | Treat logs as event streams | App rotates its own log files |
| XII | Admin processes | Run admin and management tasks as one-off processes | Migration run inside the web start-up path |

Mechanics for III, V, VI, IX, X and XI, with a short SIGTERM example: [factor mechanics](references/factor-mechanics-and-anti-patterns.md).

## 2. Config and variables: classify before you create

Config is anything likely to differ between deploys (backing-service handles, third-party credentials, per-deploy hostnames); wiring that is identical in every deploy stays in code. Test: could the codebase be published right now without leaking a credential? Prefer one independent variable per setting over named environment bundles (`staging`, `qa`, a developer's own) which multiply.

For a new variable pick one class before writing code:

| Class | Home | In the repo |
|---|---|---|
| Secret | Secret store injected at run | Name only, empty in a template |
| Deploy config | Per-deploy config | Name, plus a sane default in code |
| Local | Untracked local env file | Example file with names only |
| Constant | Code | Not a variable |

Only names and classes travel in tickets, chat and logs, never values. A framework prefix that exposes a variable to the browser makes it public: `NEXT_PUBLIC_` values are inlined into the bundle at build time and freeze there; `VITE_` values are exposed to client code and the docs warn against API keys in them. A secret under such a prefix is an incident: remove, rotate, move the call server side. Full procedure and runtime-config caveat: [classifying a new variable](references/classifying-a-new-variable.md).

## 3. Beyond twelve: three factors for distributed systems

Kevin Hoffman's *Beyond the Twelve-Factor App* (2016), as summarized in a vendor article, adds: **API first** (a versioned OpenAPI or Protobuf contract before the implementation), **telemetry** (application metrics, health status and domain events, exposed by the app itself) and **authentication and authorization** (every request, internal calls included; short-lived identities, explicit permissions, no secrets in images or repos). Apply them when many services call each other or run on Kubernetes; a small monolith rarely needs all fifteen (this skill's judgment). Detail and what the article does not say: [beyond twelve-factor](references/beyond-twelve-factor-api-telemetry-auth.md).

## 4. Review method

1. Run the failure-symptom table in the mechanics reference against the code and manifests.
2. Grep for environment-name conditionals, hard-coded hosts, local file writes, in-memory session stores and signal handling.
3. Confirm one build is promoted unchanged through environments, with config applied at release.
4. Check SIGTERM handling and job re-entrancy before approving autoscaling or spot capacity.
5. Report findings by factor number with file and line; propose the smallest change that restores the invariant.

## When it earns its keep

Containerized or platform-hosted services (Kubernetes, ECS, Cloud Run, PaaS, serverless), multi-environment systems that scale horizontally, and any pipeline with continuous delivery. Skip a factor-by-factor audit for a throwaway script.

## Quick Decision Checklist

- [ ] Is every per-deploy value in the environment, with no credential or environment-name branch in code?
- [ ] Are processes stateless, with sessions and uploads in a backing service?
- [ ] Is one build promoted unchanged, with config joined at release and no edits on running hosts?
- [ ] Does the process stop accepting work on SIGTERM, finish or return in-flight work, and start in seconds?
- [ ] Do logs go to stdout unbuffered, with migrations and scripts as one-off processes?
- [ ] Do dev and production use the same type and version of each backing service?
- [ ] Is each new variable classified, with browser-prefixed names treated as public?
- [ ] Did I apply the extra three factors only where the system is distributed?

## Deep references

- [Factor mechanics and anti-patterns](references/factor-mechanics-and-anti-patterns.md) — read when auditing config, processes, releases, shutdown, logs or parity
- [Beyond twelve-factor](references/beyond-twelve-factor-api-telemetry-auth.md) — read when adding API-first, telemetry or zero-trust requirements
- [Classifying a new variable](references/classifying-a-new-variable.md) — read when adding a variable, key or setting and deciding its home and exposure
- [Trigger evals](references/trigger-evals.md) — read when tuning the description
- [Sources](references/sources.md) — read for retrieved statuses, reading limits and claims not adopted
