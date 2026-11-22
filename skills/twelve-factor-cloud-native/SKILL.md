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

## When It Earns Its Keep

- All containerized applications deployed on Kubernetes, ECS, Cloud Run, or serverless platforms.
- Multi-environment microservice systems requiring seamless horizontal autoscaling.
- Any application practicing Continuous Integration and Continuous Deployment (CI/CD).
