---
name: twelve-factor-cloud-native
description: Use when designing, reviewing, or refactoring cloud-native applications and microservices against the 12-Factor App methodology (Heroku/Adam Wiggins) and modern 15-Factor extensions (API first, telemetry, authentication & authorization). Gives the 12 core factors, operational invariants, containerization best practices, and common violations.
---

# 12-Factor & Cloud-Native Architecture

One idea: build applications designed from day one to run as **portable, scalable, resilient, stateless workloads** in modern containerized and cloud environments (Docker, Kubernetes, AWS, GCP, Azure) without environment coupling or configuration drift. Sources and their claims: [references/sources.md](references/sources.md).

## The 12 Canonical Factors (Adam Wiggins / Heroku)

| # | Factor | Core Invariant | Common Violation |
|---|---|---|---|
| I | **Codebase** | One codebase tracked in version control, many deploys | Splitting an app into multiple repos without independent releases |
| II | **Dependencies** | Explicitly declare and isolate dependencies | Relying on system-wide globally installed packages |
| III | **Config** | Store configuration in the environment (`process.env`) | Hardcoding credentials or keeping environment-specific config files in Git |
| IV | **Backing Services** | Treat backing services (DB, cache, queues) as attached resources | Treating local MySQL differently from production RDS in application logic |
| V | **Build, Release, Run** | Strictly separate build, release, and run stages | Modifying running code directly on a live production server |
| VI | **Processes** | Execute the app as one or more stateless, share-nothing processes | Storing user session state in process local memory across requests |
| VII | **Port Binding** | Export services via direct port binding | Injecting web apps into external web containers (e.g. Apache/Tomcat) |
| VIII | **Concurrency** | Scale out via the process model (horizontal scaling) | Relying solely on internal thread pooling instead of adding worker processes |
| IX | **Disposability** | Maximize robustness with fast startup and graceful shutdown (SIGTERM) | Leaving dangling connections or dropping in-flight requests on container restart |
| X | **Dev/Prod Parity** | Keep development, staging, and production as similar as possible | Using SQLite in dev while deploying PostgreSQL in production |
| XI | **Logs** | Treat logs as unbuffered event streams emitted to stdout | Writing logs to local disk files with internal log rotation scripts |
| XII | **Admin Processes** | Run admin/management tasks (migrations, scripts) as one-off processes | Bundling migration execution inside web server request startup loops |

---

## Modern Extensions (15-Factor Cloud Native)

- **Factor XIII (API First):** Design public interfaces and OpenAPI contracts before implementing backend code.
- **Factor XIV (Telemetry & Observability):** Emit OpenTelemetry traces, Prometheus metrics, and structured JSON logs out of the box.
- **Factor XV (Authentication & Authorization):** Enforce zero-trust security; authenticate and authorize every interaction at the network and service boundary.

---

**Adding a variable?** Classify it first (secret, deploy config, local, or code constant), put it in its home, share names and never values, and treat browser-exposed prefixes (`NEXT_PUBLIC_`, `VITE_`) as public. Details: [classifying a new variable](references/classifying-a-new-variable.md).

## When It Earns Its Keep

- All containerized applications deployed on Kubernetes, ECS, Cloud Run, or serverless platforms.
- Multi-environment microservice systems requiring seamless horizontal autoscaling.
- Any application practicing Continuous Integration and Continuous Deployment (CI/CD).

## Quick Decision Checklist

- [ ] Is configuration in the environment, with no hardcoded credentials or per-environment files in Git?
- [ ] Are processes stateless and share-nothing, with no user session state in process memory?
- [ ] Are backing services treated as attached resources, and build, release and run kept separate?
- [ ] Does the app handle SIGTERM with fast startup and graceful shutdown?
- [ ] Do logs go to stdout as event streams, and admin tasks like migrations run as one-off processes?
- [ ] Is dev kept as close to prod as possible, with no SQLite in dev and PostgreSQL in prod?
- [ ] Is a new variable classified (secret, deploy config, local, code constant), with browser-prefixed variables treated as public?

## Deep references

- [Factor mechanics and anti-patterns](references/factor-mechanics-and-anti-patterns.md) — read when auditing config, processes, releases, shutdown, logs or parity
- [Beyond twelve-factor](references/beyond-twelve-factor-api-telemetry-auth.md) — read when adding API-first, telemetry or zero-trust auth requirements
- [Classifying a new variable](references/classifying-a-new-variable.md) — read when adding a variable, key or setting and deciding its home and exposure